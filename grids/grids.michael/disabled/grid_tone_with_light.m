function grid = grid_tone_with_light()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_makeToneWithLight';
 
  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Frequency', 'Tone Delay (ms)', 'Tone Duration (ms)', 'Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level (dB)'};

  voltages = [0 5];
  level=[40 50 60 70 80 90]
  tone_delay = [42,100,350];
  freqs = logspace(log10(1000), log10(1000*2^6),15);
  
  %control conditions
  no_light_condition=createPermutationGrid(500, freqs, 100, 50, voltages(1), 50, 10, level);
   %Create light condition
   light_grid=createPermutationGrid(500, freqs, tone_delay, 50, voltages(2), 50, 10, level);
  
   spontanous =[500,10, 100, 10, voltages(1), 50, 1, -50];
    grid.stimGrid = cat(1,light_grid,no_light_condition,spontanous);

  % sweep parameters
   grid.postStimSilence = 0;
   grid.repeatsPerCondition = 10;
  



  
  
  
