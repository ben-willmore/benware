function grid = grid_csdprobe()

  % controlling the sound presentation
  grid.sampleRate = tdt100k;
  grid.stimGenerationFunctionName = 'stimgen_CSDProbe';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Delay (ms)'; 'Noise Length (ms)', 'Level'};
  grid.stimGrid = [490 50 50 80];  % after compensation this will be below nominal level

  global CALIBRATE;
  if CALIBRATE
   fprintf('For calibration only!\n');
   pause;
   grid.stimGrid = [490 50 480 80];
  end
  
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = Inf;
  