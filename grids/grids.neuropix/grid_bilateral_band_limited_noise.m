function grid = grid_bilateral_band_limited_noise

  % controlling the sound presentation
  grid.sampleRate = tdt100k;
  grid.stimGenerationFunctionName = 'stimgen_bilateralBandLimitedNoise';

  % stimulus grid structure
  grid.stimGridTitles = {'Duration', 'LeftDelay', 'RightDelay', 'BothDelay', 'f_min', 'f_max', 'Level'};
  grid.stimGrid = [400 0 500 1000 500 1500 90];
  
  % sweep parameters
  grid.postStimSilence = 0.2; %seconds
  
  % search mode
  grid.repeatsPerCondition = Inf;
  grid.saveWaveforms = false;
  