function grid = grid_noise_with_light()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_CSDProbeWithLight_long';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Noise Delay (ms)', ...
           'Noise Length (ms)', 'Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level'};
  %grid.stimGrid = [1000 250 50 8 0.01 750 80; 1000 250 50 0 0.01 750 80;];
  
  noise_delay = [75,100,125,150,175,200,250,350,450,550];
  trials= length(noise_delay)+1 % trials plus control
  voltages = [0 5];
  %Create no light condition
  no_light_condition=createPermutationGrid(650, 500, 50, voltages(1), 50, 10, 80);
   %Create light condition
   light_grid=createPermutationGrid(650, noise_delay, 50, voltages(2), 50, 10, 80);
   %Create full stim grid
  grid.stimGrid = cat(1,light_grid,no_light_condition);
    
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 50;
  
  
