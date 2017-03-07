function grid = grid_noise_with_light()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_CSDProbeWithLight';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Noise Delay (ms)', ...
           'Noise Length (ms)', 'Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level'};
  %grid.stimGrid = [1000 250 50 8 0.01 750 80; 1000 250 50 0 0.01 750 80;];
  
  levels = [80]
  noise_delay =[350];
  voltages = [5]; 
  %Create no light condition

   light_grid=createPermutationGrid(4000, noise_delay, 100, voltages, 100,2000, levels);
   
   %Create full stim grid
  grid.stimGrid =  light_grid% cat(1,light_grid,no_light_condition);
    
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 80;
  
  
