function grid = grid_joshpitch()

  % controlling the sound presentation
  grid.sampleRate = tdt100k;
  grid.stimGenerationFunctionName = 'stimgen_loadSoundFile';
  grid.stimDir = 'e:\benware.sounds.uncalib\joshpitch\';
  grid.stimFilename = 'KerryPitchSounds2013_%1.wav';
  
  % stimulus grid structure
  grid.stimGridTitles = {'ID'};  
  grid.stimGrid = createPermutationGrid(1:15);

  global CALIBRATE
  if CALIBRATE
    fprintf('Calibration only!!\n');
    pause;
    grid.stimGrid = [1];
  end
  
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 1;
  
  % set this to match nominal level of 80dB
  grid.legacyLevelOffsetDB = 12.5;
  