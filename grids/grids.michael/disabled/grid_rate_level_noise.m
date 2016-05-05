function grid = grid_rate_level_noise()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~100kHz
  grid.stimGenerationFunctionName = 'stimgen_CSDProbeWithLight';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Noise Delay (ms)', ...
           'Noise Length (ms)', 'Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level'};

  voltages = [0 5];
  levels = [-10:5:90];
  grid.stimGrid = createPermutationGrid(1000, 250, 50, voltages, 0.1, 750, levels);
  
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 30;
  
  % set this using absolute calibration
  grid.stimLevelOffsetDB = [-2 0];
  
