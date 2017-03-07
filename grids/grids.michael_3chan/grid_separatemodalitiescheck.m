function grid = grid_noise_with_WhiskandLight()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_CSDProbeWithWhiskandLight';


  % stimulus grid structure
  grid.stimGridTitles = {'Sweep Length (ms)', 'Noise Delay (ms)', ...
           'Noise Length (ms)', 'Whisk voltage (V)', 'Whisk delay (ms)', 'Whisk Duration (ms)','Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level'};
  %grid.stimGrid = [1000 250 50 8 0.01 750 80; 1000 250 50 0 0.01 750 80;];
  
  levels = [80]
  noise_delay =[100];
  whiskvoltages = [9]; 
  lightvoltages = [5]; 
  
  %Create no light condition
  no_light_no_whisk_condition=createPermutationGrid(450, noise_delay, 100, 0, 100, 50, 0, 100, 50, levels);% normnally sweep is 1250ms
  %create light train condition
  %lighttrain_condition=createPermutationGrid(1500, 500, 100, voltages(2), 1, 10, levels);
   %Create light condition
   light_grid=createPermutationGrid(450, noise_delay, 50, 0, 100,50, lightvoltages(1), 100,50, -50);% normnally sweep is 1250ms
   whisk_grid=createPermutationGrid(450, noise_delay, 50, whiskvoltages, 100,50, 0, 100,50, -50);% normnally sweep is 1250ms

   %Create full stim grid
  grid.stimGrid =   light_grid%  cat(1, light_grid,whisk_grid,no_light_no_whisk_condition);
    
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 300
  