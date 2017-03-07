function grid = grid_noise_with_light()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_CSDProbeWithWhiskandLight';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Sweep Length (ms)', 'Noise Delay (ms)', ...
           'Noise Length (ms)', 'Whisk voltage (V)', 'Whisk delay (ms)', 'Whisk Duration (ms)','Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level'};
  %grid.stimGrid = [1000 250 50 8 0.01 750 80; 1000 250 50 0 0.01 750 80;];
  
  levels = [12.5:2.5:92.5];
  noise_delay_som =[100 150];
  noise_delay_light =[100 150 200];
  lightvoltages = [0 5]; 
  whiskvoltages = [0 9]; 
  %Create no light condition
  no_whisk_no_light_condition=createPermutationGrid(510, 100, 50, whiskvoltages(1), 100, 50, lightvoltages(1), 100, 50, levels);% normnally sweep is 1250ms
  %create light train condition
  %lighttrain_condition=createPermutationGrid(1500, 500, 100, voltages(2), 1, 10, levels);
   %Create light condition
   light_grid=createPermutationGrid(510, noise_delay_light, 50,whiskvoltages(1), 100, 50, lightvoltages(2), 100,50, levels);% normnally sweep is 1250ms
   whisk_grid=createPermutationGrid(510, noise_delay_som, 50,whiskvoltages(2), 100, 50, lightvoltages(1), 100,50, levels);% normnally sweep is 1250ms

   %Create full stim grid
  grid.stimGrid =  cat(1, whisk_grid, light_grid, no_whisk_no_light_condition);
    
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 12;
  
  
