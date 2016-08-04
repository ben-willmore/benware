function grid = grid_trilateral_noise

  % controlling the sound presentation
  grid.sampleRate = tdt100k;
  grid.stimGenerationFunctionName = 'stimgen_trilateralNoise';

  % stimulus grid structure
  grid.stimGridTitles = {'Duration', 'LeftDelay', 'RightDelay', 'BothDelay', 'Level'};
  grid.stimGrid = [45 0 100 200 90]; % after compensation this will be about 10dB below nominal level
  
  global CALIBRATION
  if CALIBRATION
    fprintf('== Calibration only!\n');
    pause;
    grid.stimGrid = [500 0 1000 2000 90];
  end
  
  % sweep parameters
  grid.postStimSilence = 0.2; %seconds
  
  % search mode
  grid.repeatsPerCondition = Inf;
  grid.saveWaveforms = false;
  