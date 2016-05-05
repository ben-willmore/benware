function grid = grid_quickFRA()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_makeToneWithLight';
 
  % stimulus grid structure
  grid.stimGridTitles = {'Stimulus Length (ms)', 'Frequency', 'Tone Delay (ms)', 'Tone Duration (ms)', 'Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level (dB)'};

  voltages = [0];
  level=[40 50 60 70 80]
  tone_delay = [100];
  freqs = logspace(log10(4000), log10(1000*2^6),25);
  
  %control conditions
  no_light_condition=createPermutationGrid(550, freqs, 100, 100, voltages(1), 100, 50, level);
   %Create light condition
  
   
    grid.stimGrid = no_light_condition
  
%  fprintf('For calibration only!\n');
%  pause;
%  grid.stimGrid = [1000, 1000, 250, 500, 0, 0.01, 0.01, 80];

  % sweep parameters
   grid.postStimSilence = 0;
   grid.repeatsPerCondition = 5;%
  



  
  
  
