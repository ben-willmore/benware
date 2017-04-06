function grid = grid_texture_v4()

  % controlling the sound presentation
  grid.sampleRate = tdt50k;
  grid.stimGenerationFunctionName = 'stimgen_loadSoundFile';
  grid.stimDir = 'e:\benware.sounds.uncalib\texture.v2\';
  grid.stimFilename = 'texture.v2.id%1.type%2.wav';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Sound ID', 'Condition'};  
  grid.stimGrid = [createPermutationGrid(1:5, 1:9); % sounds
                   createPermutationGrid(6,9)]; % silence

  global CALIBRATE;
  if CALIBRATE
    fprintf('== Calibration mode. Press a key to continue == ')
    pause;
    grid.stimGrid = createPermutationGrid(9, 9);
  end

  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 7;
  
  % set this to match nominal level of 80dB
  grid.legacyLevelOffsetDB = 0;
  