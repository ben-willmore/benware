function [nSamplesReceived, spikeTimes, lfp, timeStamp, plotData, sampleWaveforms] = runSweep(hardware, ...
  sweepLen, nChannels, stim, nextStim, spikeFilter, spikeThreshold, ...
  saveWaveforms, dataFiles, plotData, useJamesSpikeThreshold)
  %% Run a sweep, ASSUMING THAT THE STIMULUS HAS ALREADY BEEN UPLOADED
  %% Will fail if next stimulus is not on the stimulus device
  %% Upload the next stimulus at the same time, then reset the stimDevice
  %% and inform the stimDevice of the stimulus length

  global state;

  if isempty(hardware.dataDevice)
      % trigger stimulus presentation and data collection
      timeStamp = clock;
      hardware.triggerDevice.trigger();
      tic;

      endOfSweep = false;

      while ~endOfSweep
          hardware.stimDevice.workDuringSweep();

          if ~hardware.stimDevice.isPlaying() && toc > sweepLen
              endOfSweep = true;
          end
      end
      nSamplesReceived = 0;
      spikeTimes = cell(nChannels,1);
      lfp = zeros(nChannels,1000);
      sampleWaveforms = cell(nChannels,1);
      pause(0.1); % throttle to prevent writetag errors
      return
  end

  % reset data device and tell it how long the sweep will be
  try
    hardware.dataDevice.reset(sweepLen*1000);
  catch
    keyboard
  end

  % check for stale data in data device buffer
  % FIXME: This hack should not be here. If we read these values
  % immedately after a reset, we frequently get stale data errors
  % on the BSB rig machine. Pausing and/or doing countAllData an
  % extra time seem to fix it.
  %pause(0.5)
  dummy = countAllData(hardware.dataDevice, nChannels);

  if any(countAllData(hardware.dataDevice, nChannels) ~= 0)
    errorBeep('Stale data in data buffer');
  end

  % make matlab buffer for data
  nSamplesExpected = floor(sweepLen*hardware.dataDevice.sampleRate)+1;

  if hardware.dataDevice.is16Bit
      nSamplesExpected = floor(nSamplesExpected/2)*2;
  end
  data = zeros(nChannels, nSamplesExpected);
  nSamplesReceived = 0;

  filteredData = zeros(nChannels, nSamplesExpected);
  filterIndex = 0;

  % open data files
  if saveWaveforms
    % only relevant for single-file-per-expt data
    % if state.klustaFormat
    %   % save in a single, interleaved file
    %   dataFileHandles = dataFiles; % file has already been opened by runGrid
    % else

    if state.klustaFormat
      dataFileHandles = fopen(dataFiles, 'w'); % one file per sweep
    else
      dataFileHandles = nan(1,nChannels);
      for chan = 1:nChannels
        dataFileHandles(chan) = fopen(dataFiles{chan},'w');
      end
    end
  end

  % cell array for storing spike times
  spikeTimes = cell(1, nChannels);

  % keep track of how much of stimulus has been uploaded
  samplesUploaded = 0;

  if useJamesSpikeThreshold
    % waveform statistics for spike detection
    fprintf('runSweep: warning: using global state.waveformStats\n');
    waveformStats = state.waveformStats;
  end

  % trigger stimulus presentation and data collection
  timeStamp = clock;
  hardware.triggerDevice.trigger();

  fprintf(['  * Sweep triggered after ' num2str(toc) ' sec.\n']);

  plotData = plotReset(plotData);


  % while trial is running:
  % * upload next stimulus as far as possible
  % * download data as fast as possible while trial is running
  % * plot incoming data
  DEBUG = true;
  if DEBUG
      fprintf('Samples expected %d\n', nSamplesExpected);
  end

  % loop until we've received (and saved) all data
  nSamplesReceivedAlready = 0;
  endOfSweep = false;

  while ~endOfSweep

    % allow stimDevice to do something during sweep (i.e. upload stimulus)
    if ~state.slaveMode
      hardware.stimDevice.workDuringSweep;
    end

    % download data
    newdata = hardware.dataDevice.downloadAvailableData(nSamplesReceived);

    if ~isempty(newdata)
        sz = size(newdata, 2);
        data(:, nSamplesReceived+1:nSamplesReceived+sz) = newdata;
        nSamplesReceived = nSamplesReceived + sz;
    end

    % save waveforms
    if saveWaveforms
      if state.klustaFormat
        % data are interleaved automatically
        fwrite(dataFileHandles, newdata, 'float32');
      else
        for chan = 1:nChannels
          fwrite(dataFileHandles(chan), newdata(chan, :), 'float32');
        end
      end
    end

    % bandpass filter data and detect spikes
    if (nSamplesReceived-filterIndex) > (hardware.dataDevice.sampleRate*100/1000) % at least 150msec of data
      [filtData, offset] = filterData(data(:, filterIndex+1:nSamplesReceived), spikeFilter);
      filteredData(:, filterIndex+offset+1:filterIndex+offset+size(filtData,2)) = filtData;

      if useJamesSpikeThreshold
        [spikeTimes, waveformStats] = appendSpikeTimesJames(spikeTimes, filtData, filterIndex+offset+1, hardware.dataDevice.sampleRate, waveformStats);
      else
        spikeTimes = appendSpikeTimes(spikeTimes, filtData, filterIndex+offset+1, hardware.dataDevice.sampleRate);
      end
      filterIndex = filterIndex + size(filtData,2);

    end

    % check audio monitor is on the right channel
    if state.audioMonitor.changed
      hardware.dataDevice.setAudioMonitorChannel(state.audioMonitor.channel);
      state.audioMonitor.changed = false;
    end

    % plot data
    plotData = plotUpdate(plotData, data, nSamplesReceived, filteredData, filterIndex, spikeTimes);

    % check whether we're done
    if state.slaveMode
      if (nSamplesReceived == nSamplesReceivedAlready) || (nsamplesReceived>=nSamplesExpected) % no new samples
        endOfSweep = true;
      end
    else
      if nSamplesReceived>=nSamplesExpected % expected number of samples reached
        endOfSweep = true;
      end
    end

    nSamplesReceivedAlready = nSamplesReceived;

  end

  fprintf(['  * Waveforms received and saved after ' num2str(toc) ' sec.\n']);

  % allow stimDevice to do some work
  if ~state.slaveMode
    hardware.stimDevice.workAfterSweep;
  end

  if state.slaveMode
    data = data(:,1:nSamplesReceived);
  end

  % finish detecting spikes
  [filtData, offset] = filterData(data(:, filterIndex+1:nSamplesReceived), spikeFilter);
  filteredData(:, filterIndex+offset+1:filterIndex+offset+size(filtData,2)) = filtData;
  if useJamesSpikeThreshold
    [spikeTimes, waveformStats] = appendSpikeTimesJames(spikeTimes, filtData, filterIndex+offset+1, hardware.dataDevice.sampleRate, waveformStats);
  else
    spikeTimes = appendSpikeTimes(spikeTimes, filtData, filterIndex+offset+1, hardware.dataDevice.sampleRate);
  end
  filterIndex = filterIndex + size(filtData,2);

  fprintf(['  * ' num2str(sum(cellfun(@(i) length(i),spikeTimes))) ' spikes detected after ' num2str(toc) ' sec.\n']);

  % final plot
  plotData = plotUpdate(plotData, data, nSamplesReceived, filteredData, filterIndex, spikeTimes);

  % chop out sample waveforms
  sampleWaveformLength = floor(hardware.dataDevice.sampleRate/1000);
  sampleWaveforms = cell(1, nChannels);
  for chan = 1:nChannels
     r = randperm(length(spikeTimes{chan}));
     times = spikeTimes{chan}(r(1:min(length(r), 20)))/1000;
     samples = round(times*hardware.dataDevice.sampleRate)-7;
     sampleWaveforms{chan} = zeros(sampleWaveformLength, 20);
     for tmIdx = 1:length(times)
        sampleWaveforms{chan}(:, tmIdx) = filteredData(chan, samples(tmIdx):samples(tmIdx)+sampleWaveformLength-1);
     end
  end

  % close data files if not using klustaFormat single-file-per-expt
  if saveWaveforms
      if state.klustaFormat
          fclose(dataFileHandles);
      else
        for file = 1:length(dataFileHandles)
          fclose(dataFileHandles(chan));
        end
      end
  end

  % check for blank data channels
  if ~state.noData.alreadyWarned && ~isempty(data) &&  any(all(data==0,2))
    state.noData.warnUser = true;
  end

  % Check that we got the expected number of samples
  if (nSamplesReceived<nSamplesExpected)
    errorBeep('Got fewer samples than expected!');
  elseif (nSamplesReceived>nSamplesExpected)
    fprintf('  * Got %d extra samples (expected %d) after %s sec; truncating\n', nSamplesReceived-nSamplesExpected, nSamplesExpected, num2str(toc));
    nSamplesReceived = nSamplesExpected;
    data = data(:, 1:nSamplesReceived);
  else
    fprintf('  * Got expected number of samples (%d) after %s sec\n', nSamplesExpected, num2str(toc));
  end

  % get LFP (currently no filtering)
  LFPsamples = round(1:hardware.dataDevice.sampleRate/1000:nSamplesReceived);
  nLFPsamples = length(LFPsamples);
  lfp = zeros(nChannels, nLFPsamples);
  for chan = 1:nChannels
    lfp(chan, :) = data(chan, LFPsamples);
  end

  % update plots
  plotData.nSweeps = plotData.nSweeps + 1;
  plotData = plotUpdate(plotData, data, nSamplesReceived, filteredData, filterIndex, spikeTimes);
  plotData.lastSweepSpikes = spikeTimes;

  %
  if useJamesSpikeThreshold
      fprintf('runSweep: warning: saving waveformStats\n');
      state.waveformStats = waveformStats;
  end

  % optional: check data thoroughly (too slow to be used normally)
  global checkdata

  if checkdata
    fprintf('  * DATA INTEGRITY CHECK...\n');
    fprintf('  * Checking stimulus in buffer...');
    [nStimChans, nStimSamples] = size(stim);
    teststim = hardware.stimDevice.downloadStim(0, nStimSamples, nStimChans);
    d = max(max(abs(nextStim-teststim)));
    if d>10e-7
      errorBeep('Stimulus mismatch!');
    end
    fprintf([' ' num2str(size(teststim, 2)) ' samples verified.\n']);

    fprintf('  * Checking data in memory');
    testData = hardware.dataDevice.downloadAllData;

    for chan = 1:nChannels
        fprintf('.');
        diffInMem = max(abs(data(chan,:) - testData{chan}));
        if diffInMem > 0
            errorBeep('Data in memory doesn''t match data device buffer!');
        end
    end
    fprintf([' ' num2str(nChannels) ' channels verified.\n']);

    if ~saveWaveforms
      fprintf('  * No waveforms saved -- can''t check saved waveform data\n');
    else
      fprintf('  * Checking data on disk');
      for chan = 1:nChannels
        fprintf('.');
        h = fopen(dataFiles{chan}, 'r');
        savedData = fread(h, inf, 'float32')';
        fclose(h);
        diffOnDisk = max(abs(savedData - testData{chan}));
        if diffOnDisk > 0
          keyboard;
          errorBeep('Data on disk doesn''t match data device buffer!');
        end
      end
      fprintf([' ' num2str(nChannels) ' channels verified.\n']);
    end

    fprintf(['  * DATA OK. Check complete after ' num2str(toc) ' sec.\n']);
  end

