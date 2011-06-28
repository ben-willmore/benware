function tdt = runGrid(tdt, expt, grid)
%% stim/data setup: AUTO
% =======================

global dataGain;

% close open files if there is an error or ctrl-c
cleanupObject = onCleanup(@()cleanup(tdt));

% gain of scope trace
dataGain = expt.dataGain;

% check that the grid is valid
verifyGridFields(grid);

% check that stim files are there, if needed
if isequal(grid.stimGenerationFunctionName, 'loadStereo')
  verifyStimFilesExist(grid, expt);
end

% add extra fields
grid.saveName = '';
grid.nStimConditions = size(grid.stimGrid, 1);

% randomise grid
repeatedGrid = repmat(grid.stimGrid, [grid.repeatsPerCondition, 1]);
grid.nSweepsDesired = size(repeatedGrid, 1);
grid.randomisedGrid = repeatedGrid(randperm(grid.nSweepsDesired), :);
[junk grid.randomisedGridSetIdx] = ...
  ismember(grid.randomisedGrid, grid.stimGrid, 'rows');

% verify that we have the right conditions from the user
verifyExpt(grid, expt);

% check for existence of data directory.
% If it does exist, use grid.saveName to store alternative name.
grid.saveName = verifySaveDir(grid, expt);

% stimulus generation function handle
stimGenerationFunction = str2func(grid.stimGenerationFunctionName);

% save grid metadata
saveGridMetadata(grid, expt);

% start recording a log
diary(constructDataPath([expt.dataDir expt.logFilename], grid, expt));

%% Begin recording
% =================

fprintf_title('Preparing to record');
tic;

tdt = prepareTDT(tdt, expt, grid);

% make filter for spike detection
spikeFilter = makeSpikeFilter(expt.dataDeviceSampleRate);

clear sweeps stim nextStim sweepNum data sweepLen spikeTimes; % no longer needed now this is a function?

% upload first stimulus
[nextStim sweeps(1).stimInfo] = stimGenerationFunction(1, grid, expt);
fprintf('  * Uploading first stimulus...');
uploadWholeStim(tdt.stimDevice, nextStim);
fprintf(['done after ' num2str(toc) ' sec.\n']);

% set up plot -- FIXME assumes all stimuli will be the same length as the first
nSamplesExpected = floor((size(nextStim,2)/grid.sampleRate+grid.postStimSilence)*expt.dataDeviceSampleRate)+1;
plotData = feval(expt.plotFunctions.init, [], expt.dataDeviceSampleRate, nSamplesExpected);
%plotData = [];

%% run sweeps
% =============

for sweepNum = 1:grid.nSweepsDesired
  tic;
  
  stim = nextStim;
  displayStimInfo(sweeps, grid, sweepNum);
  fprintf('Progress:\n');
  
  % retrieve the stimulus for the NEXT sweep
  isLastSweep = (sweepNum == grid.nSweepsDesired);
  if ~isLastSweep
    [nextStim, sweeps(sweepNum+1).stimInfo] = stimGenerationFunction(sweepNum+1, grid, expt);
  else
    nextStim = [];
  end
  
  sweeps(sweepNum).sweepNum = sweepNum;
  
  % store stimulus duration
  sweeps(sweepNum).stimLen.samples = size(stim, 2);
  sweeps(sweepNum).stimLen.ms = sweeps(sweepNum).stimLen.samples/grid.sampleRate*1000;
  
  % actual sweep length
  sweepLen = size(stim, 2)/grid.sampleRate + grid.postStimSilence;
  fprintf(['  * sweep length: ' num2str(sweepLen) ' s\n']);
  
  % get filenames for saving data
  sweeps(sweepNum).dataFiles = constructDataPaths([expt.dataDir expt.dataFilename],grid,expt,sweepNum,32);
  dataDir = split_path(sweeps(sweepNum).dataFiles{1});
  mkdir_nowarning(dataDir);
  
  % run the sweep
  [nSamples, sweeps(sweepNum).spikeTimes, sweeps(sweepNum).timeStamp] = runSweep(tdt, sweepLen, stim, nextStim, expt.plotFunctions, ...
    expt.detectSpikes, spikeFilter, expt.spikeThreshold, sweeps(sweepNum).dataFiles, plotData);     %#ok<*SAGROW>
  
  % store sweep duration
  sweeps(sweepNum).sweepLen.samples = nSamples;
  sweeps(sweepNum).sweepLen.ms = sweeps(sweepNum).sweepLen.samples/expt.dataDeviceSampleRate*1000;
  
  % save sweep metadata
  saveSingleSweepInfo(sweeps(sweepNum), grid, expt, sweepNum);
  
  fprintf(['  * Finished sweep after ' num2str(toc) ' sec.\n\n']);
  
end

diary off
