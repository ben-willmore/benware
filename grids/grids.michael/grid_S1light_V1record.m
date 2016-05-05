function grid = S1light_V1record()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_CSDProbeWithLight';
  
  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Noise Delay (ms)', ...
           'Noise Length (ms)', 'Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level'};
  %grid.stimGrid = [1000 250 50 8 0.01 750 80; 1000 250 50 0 0.01 750 80;];
  
  levels = 0%[60 80]
 % noise_delay = %[50,75,92,125,150,200,250,300,350,650];
  %voltages = [0 5]; 
  %Create no light condition
   %light_grid=(1200, noise_delay, 100, voltages(2), 100, 50, levels);
   
   %Create full stim grid
  %stim_Grid_temp=cat(1,light_grid,no_light_condition);
  grid.stimGrid = [1200, 900, 1, 5, 100, 50, 0]
    
  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 50;
  
  
