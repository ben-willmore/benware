function runGrid(hardware, expt, grid, firstSweep)
% runGrid(hardware, expt, grid)
% 
% Run a whole grid

tic;

global state;

% start recording a log
diary(constructDataPath([expt.dataDir expt.logFilename], grid, expt));

%% Begin recording
% =================

fprintf_title('Preparing to record');

if ~isempty(hardware.dataDevice)
    hardware.dataDevice.setAudioMonitorChannel(state.audioMonitor.channel);
end

% close open files if there is an error or ctrl-c
cleanupObject = onCleanup(@()cleanup(hardware));

% make filter for spike detection
spikeFilter = makeSpikeFilter(expt.dataDeviceSampleRate);

% get first stimulus
[stim sweeps(firstSweep).stimInfo] = prepareStimulus(...
      grid.stimGenerationFunction, firstSweep, grid, expt);

% fprintf('  * Uploading first stimulus...');
% hardware.stimDevice.prepareForSweep(stim);
% fprintf(['done after ' num2str(toc) ' sec.\n']);

% set up plot
if isfield(grid, 'sweepLength')
  nSamplesExpected = floor(grid.sweepLength*expt.dataDeviceSampleRate)+1;
elseif isfield(grid, 'maxSweepLength')
  nSamplesExpected = floor(grid.maxSweepLength*expt.dataDeviceSampleRate)+1;
else
  nSamplesExpected = floor((size(stim,2)/grid.sampleRate+grid.postStimSilence)*expt.dataDeviceSampleRate)+1;
end

if isempty(hardware.dataDevice)
  plotData = [];
else
  if ~isfield(state, 'onlineData')
    state.onlineData = onlineDataInit(expt.dataDeviceSampleRate, expt.nChannels, nSamplesExpected, grid);
  end
  plotData = plotInit(expt.dataDeviceSampleRate, expt.nChannels, nSamplesExpected, grid);
end

%% run sweeps
% =============

useJamesSpikeThreshold = false;
if isfield(expt, 'jamesSpikeThreshold') && expt.jamesSpikeThreshold
  fprintf('runGrid: warning -- using waveform stats from first sweep only\n');
  state.waveformStats = [];
  useJamesSpikeThreshold = true;
end

% The following was probably a mistake -- was saving a single file for the entire data set
% but I now see that spikedetekt will accept a list of files

% if state.klustaFormat
%   % construct path for saving data
%   expt.dataFile = constructDataPath([expt.dataDir expt.dataFilename],grid,expt,0,0);
  
%   dataDir = split_path(expt.dataFile);
%   if grid.saveWaveforms
%     mkdir_nowarning(dataDir);
%   end

%   % open data file, and rewind file pointer if restarting a grid
%   if firstSweep==1
%     dataFile = fopen(dataFile, 'w'); % discard existing contents of file if it already exists

%   else
%     dataFile = fopen(dataFile, 'a'); % open existing data file

%     % get info about the previous sweep
%     lastSweepInfo = loadSingleSweepInfo(sweeps(sweepNum), grid, expt, sweepNum);

%     % rewind to wherever the data file pointer was after the end of the previous sweep
%     fseek(dataFile, lastSweepInfo.dataFilePointer.afterSweep, 'bof');

%   end

% end


sweepNum = firstSweep;
while sweepNum<=grid.nSweepsDesired
  tic;
  
  displayStimInfo(sweeps, grid, sweepNum);
  fprintf('Progress:\n');
  
  % retrieve the stimulus for the NEXT sweep
  isLastSweep = (sweepNum == grid.nSweepsDesired);
  if ~isLastSweep
    [nextStim, sweeps(sweepNum+1).stimInfo] = prepareStimulus(grid.stimGenerationFunction, ...
                                                              sweepNum+1, grid, expt);
  else
    nextStim = [];
  end
  
  if ~state.slaveMode
    hardware.stimDevice.prepareForSweep(stim, nextStim);
  end
  
  sweeps(sweepNum).sweepNum = sweepNum;
  
  % store stimulus duration
  sweeps(sweepNum).stimLen.samples = size(stim, 2);
  if ~state.slaveMode
    sweeps(sweepNum).stimLen.ms = sweeps(sweepNum).stimLen.samples/grid.sampleRate*1000;
  end
  % actual sweep length
  if isfield(grid, 'sweepLength')
    % then use a fixed sweep length
    sweepLen = grid.sweepLength;
    % if sweep length < stimulus length, warn user
    if ~state.slaveMode && (size(stim, 2)/grid.sampleRate)>sweepLen && ~state.sweepTooShort.userWarned
      bbeep;
      fprintf_title('Stimulus length is longer than sweep length!');
      if lower(demandinput('Do you want to carry on anyway? ','yn','n',true))=='n'
        break;
        state.userQuit = true;
      end
      state.sweepTooShort.userWarned = true;
    end
  else
    % sweep length = stimulus length + post stimulus silence
    sweepLen = size(stim, 2)/grid.sampleRate + grid.postStimSilence;
  end
  fprintf(['  * sweep length: ' num2str(sweepLen) ' s\n']);

  % Only relevant for single-file data  
  % if saving in klustaFormat, get current position in data file
  % if state.klustaFormat
  %   sweeps(sweepNum).dataFilePointer.beforeSweep = ftell(dataFile);
  % end

  % get filenames for saving data
  %if ~state.klustaFormat
  sweeps(sweepNum).dataFiles = constructDataPaths([expt.dataDir expt.dataFilename], ...
    grid,expt,sweepNum,expt.nChannels);
  dataFile = sweeps(sweepNum).dataFiles;

  if isstr(dataFile) % single file
      dataDir = split_path(dataFile);
  else
      dataDir = split_path(dataFile{1});      
  end
  
  if grid.saveWaveforms
    mkdir_nowarning(dataDir);
  end
  %end

  % run the sweep
  [nSamples, spikeTimes, lfp, timeStamp, plotData, sampleWaveforms] = ...
      runSweep(hardware, sweepLen, expt.nChannels, stim, nextStim, ...
              spikeFilter, expt.spikeThreshold, grid.saveWaveforms, dataFile, plotData, useJamesSpikeThreshold);

  % Only relevant for single-file data  
  % if saving in klustaFormat, get current position in data file
  % if state.klustaFormat
  %   sweeps(sweepNum).dataFilePointer.afterSweep = ftell(dataFile);
  % end

  % check whether sweep was successful; if not, offer to repeat it
  if state.noData.warnUser
    if isfield(state, 'justWarnOnDataEmpty') && state.justWarnOnDataEmpty
      % then just warn, don't make a fuss
      fprintf_title('Some incoming channels are empty -- perhaps your Medusa batteries ran out?');
    else
      % then pause, warn the user properly, and offer to do something
      bbeep;
      fprintf_title('Some incoming channels are empty -- perhaps your Medusa batteries ran out?');
      in = lower(demandinput('Do you want to repeat the sweep (fix the problem first!), carry on anyway, or quit? [R/c/q] ','rcq','r',true));
      if in=='c'
        % carry on anyway; don't warn again
        state.noData.alreadyWarned = true;
        state.noData.warnUser = false;
      elseif in=='q'
        % quit.
        % this will leave the last sweep of waveform data on disk. perhaps this shouldn't happen, though
        % if the user has quit, she probably doesn't care much
        state.userQuit = true;
      else
        % repeat the sweep -- reset the warning, and go on to th next iteration of the while loop without
        % saving any more data (though waveforms will usually already have been saved by runGrid)
        % don't update sweepNum, so that sweep is repeated;
        state.noData.warnUser = false;

        % only relevant for single-file data
        % if state.klustaFormat
        %   fseek(dataFile, sweeps(sweepNum).dataFilePointer.beforeSweep, 'bof');
        % end
        continue; % jump to next iteration
      end
    end
  end
  
  % if the sweep was successful, move on to the next stimulus
  stim = nextStim;
  
  sweeps(sweepNum).spikeTimes = spikeTimes;
  sweeps(sweepNum).timeStamp = timeStamp;
  
  % store sweep duration
  sweeps(sweepNum).sweepLen.samples = nSamples;
  if expt.dataDeviceSampleRate > 0
      sweeps(sweepNum).sweepLen.ms = sweeps(sweepNum).sweepLen.samples/expt.dataDeviceSampleRate*1000;
  end
  
  % save sweep metadata
  saveSingleSweepInfo(sweeps(sweepNum), grid, expt, sweepNum);

  % update online data -- LFP
  %updateOnlineLFP(lfp);
  %updateOnlinePSTHes(
  %state.data.nSweeps = sweepNum;
  % state.data.lfp = updateLFP
  %plotData.nSweeps = plotData.nSweeps + 1;
  %plotData = plotUpdateLFP(plotData, lfp);
  
  %plotData.lastSweepSpikes = sweeps(sweepNum).spikeTimes;

  setIdx = grid.randomisedGridSetIdx(sweepNum);
  if ~isempty(hardware.dataDevice)
    onlineDataUpdate(setIdx, sweeps(sweepNum).spikeTimes, lfp, sampleWaveforms);
  end
  fprintf(['  * Finished sweep after ' num2str(toc) ' sec.\n\n']);
  
  % recreate main figure
%  if rem(sweepNum, 100)==0
%   recreateFigure(101);
%  recreateFigure(103);
% end
  
  % pause if requested (through key press in main window)
  if state.shouldPause
    state.paused = true;
    bbeep;
    fprintf_title('Paused -- press space to continue');
    while state.shouldPause
      pause(0.2);
    end
    state.paused = false;
  end
  
  if state.userQuit
    bbeep;
    fprintf_title('Do you really want to quit?');
    if lower(demandinput('Do you really want to terminate this grid? ','yn','n',true))=='y'
      break;
    else
      state.userQuit = false;
    end
  end
  
  try
    visualBellOff;
  end

  % successfully on to the next sweep
  sweepNum = sweepNum + 1;
end

% only relevant for single-file data
% close data file if using klustaFormat
% if state.klustaFormat
%   fclose(dataFile);
% end

% cleanup seems to happen on quit anyway, not sure why
%cleanup(hardware);
%visualBellOff;

if ~state.userQuit && isfield(state, 'bugle') && state.bugle
  [snd, fs] = audioread(['sounds/bugle-' num2str(randi(3),'%02d') '.wav']);
  soundsc(snd, fs);
end
