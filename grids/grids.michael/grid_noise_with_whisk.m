function grid = grid_noise_with_whisk()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_makeNoiseWithWhisk';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Noise Delay (ms)', ...
           'Noise Length (ms)', 'Voltage (V)', 'Whisk delay (ms)', 'Whisk Duration (ms)', 'Level'};
  %grid.stimGrid = [1000 250 50 8 0.01 750 80; 1000 250 50 0 0.01 750 80;];
  
  levels = [60 80]
  noise_delay = [50,100,125,150,200,250,350];
  whiskDelay = 100%[50,75,92,125,150,200,250,300,350,650];
  voltages = [0 8]; 
  %Create no light condition
  no_whisk_condition=createPermutationGrid(1250, 500, 100, voltages(1), whiskDelay, 25, levels);
  %Create light condition
  whisk_grid=createPermutationGrid(1250, noise_delay, 100, voltages(2), whiskDelay, 25, levels);
  continuous_whisk = createPermutationGrid(1500, 500, 100, voltages(2), 50, 750, levels)
 % whisk_only=[1250, 500, 10, voltages(2), 100, 25, 0]
   
   %Create full stim grid
     stim_Grid_temp=cat(1,whisk_grid,no_whisk_condition);
    % stim_grid_temp2=cat(1,continuous_whisk,stim_Grid_temp)
  grid.stimGrid =   stim_Grid_temp% cat(1,continuous_whisk,stim_Grid_temp)%cat(1,whisk_only,stim_grid_temp2);
    
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 80;
  
  
