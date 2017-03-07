function grid = grid_quning()

  % controlling the sound presentation
  grid.sampleRate = tdt100k;
  grid.stimGenerationFunctionName = 'stimgen_makeTone';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Frequency', 'Duration', 'Level'};

  % frequencies and levels
  freqs = logspace(log10(500), log10(500*2^5.75), 5.75*4+1);  
  levels = 50:20:90;
  tonedur = 100;

  global CALIBRATE;
  if CALIBRATE
    fprintf('== Calibration mode. Press a key to continue == ')
    pause;
    freqs = [1000];
    levels = 80;
    tonedur = 1000;
  end

  grid.stimGrid = createPermutationGrid(freqs, tonedur, levels);

  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 30;
  
  % set this using absolute calibration
  grid.legacyLevelOffsetDB = -20;
  
  % compensation filters
  % grid.initFunction = 'loadCompensationFilters';
  % grid.compensationFilterFile = ...
  %   'e:\auditory-objects\calibration\calib.ben.18.11.2013\compensationFilters.100k.mat'; % 100kHz
  % grid.compensationFilterVarNames = {'compensationFilters.L', 'compensationFilters.R'};
