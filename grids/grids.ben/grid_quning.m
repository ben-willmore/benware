function grid = grid_quning()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*4;  % ~100kHz
  grid.stimGenerationFunctionName = 'makeCalibTone';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Frequency', 'Duration', 'Level'};

  % frequencies and levels
  freqs = logspace(log10(500), log10(500*2^5.75), 5.75*4+1);  
  levels = 50:20:90;
  tonedur = 50;
  
%   fprintf('Calibration only!\n');
%   freqs = [500 1000 10000 25000];
%   levels = 80;
%   tonedur = 1000;

  grid.stimGrid = createPermutationGrid(freqs, tonedur, levels);

  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 30;
  
  % set this using absolute calibration
  grid.stimLevelOffsetDB = [-104, -106]-80;
  
  % compensation filters
  grid.initFunction = 'loadCompensationFilters';
  grid.compensationFilterFile = ...
    'e:\auditory-objects\calibration\calib.expt51\compensationFilters.100k.mat';
  grid.compensationFilterVarNames = {'compensationFilters.L', 'compensationFilters.R'};
