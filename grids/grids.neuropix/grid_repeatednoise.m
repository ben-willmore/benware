function grid = grid_repeatednoise()

  % controlling the sound presentation
  grid.sampleRate = tdt100k;
  grid.stimGenerationFunctionName = 'stimgen_regularNoiseBurst';

  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Delay (ms)', 'Noise Length (ms)', 'Repeats', 'Level'};
  grid.stimGrid = [1000 1 500 1 80];  % after compensation this will be below nominal level

  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = Inf;

