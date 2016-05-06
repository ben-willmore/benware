function grid = grid_mixmix_v3()

  % controlling the sound presentation
  grid.sampleRate = tdt50k;
  grid.stimGenerationFunctionName = 'stimgen_loadSoundFile';
  grid.stimDir = 'c:\awakedata\stimuli_oldstyle\mixmix\';
  grid.stimFilename = 'mixmix.mix.%1.%2.wav';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Mixture', 'Sound ID'};  
  grid.stimGrid = createPermutationGrid([0 1], 1:16);
  
  global CALIBRATE;
  if CALIBRATE
    fprintf('== Calibration mode. Press a key to continue == ')
    pause;
    grid.stimGrid = createPermutationGrid(1, 1); 
  end
  
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 10;
  
  % set this to match nominal level of 80dB
  grid.legacyLevelOffsetDB = 7;
  