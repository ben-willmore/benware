function grid = grid_noise_with_light()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_CSDProbeWithLight';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Noise Delay (ms)', ...
           'Noise Length (ms)', 'Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level'};
  %grid.stimGrid = [1000 250 50 8 0.01 750 80; 1000 250 50 0 0.01 750 80;];
  
  levels = [60 80]
  noise_delay =[100,125,150,200,250,350,400,500];
  voltages = [0 5]; 
  %Create no light condition
  no_light_condition=createPermutationGrid(1250, 500, 50, voltages(1), 100, 50, levels);% normnally sweep is 1250ms
  %create light train condition
  %lighttrain_condition=createPermutationGrid(1500, 500, 100, voltages(2), 1, 10, levels);
   %Create light condition
   light_grid=createPermutationGrid(1250, noise_delay, 50, voltages(2), 100,50, levels);% normnally sweep is 1250ms
   %aa=[1250, 50, 50, 8, 100, 50, 0]
   %Create full stim grid
  grid.stimGrid =cat(1,light_grid,no_light_condition);
    
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 80;
  
  
