function grid = grid_tone_with_light()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_makeToneWithWhisk';
 
  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Frequency', 'Tone Delay (ms)', 'Tone Duration (ms)', 'Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level (dB)'};

  voltages = [0 8];
  level=[40 50 60 70 80]
  tone_delay = [100 150];
  freqs = logspace(log10(4000), log10(1000*2^6),32);
  
  %control conditions
  no_light_condition=createPermutationGrid(550, freqs, 100, 100, voltages(1), 100, 25, level);
   %Create light condition
   light_grid=createPermutationGrid(550, freqs, tone_delay, 100, voltages(2), 100, 25, level);
  
   spontanous =[550,10, 100, 10, voltages(1), 50, 1, -50];
    grid.stimGrid = cat(1,light_grid,no_light_condition,spontanous);
  
%  fprintf('For calibration only!\n');
%  pause;
%  grid.stimGrid = [1000, 1000, 250, 500, 0, 0.01, 0.01, 80];

  % sweep parameters
   grid.postStimSilence = 0;
   grid.repeatsPerCondition = 15;
  



  
  
  
