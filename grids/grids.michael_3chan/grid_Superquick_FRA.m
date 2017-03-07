function grid = grid_tone_with_light()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_makeToneWithWhiskandLight';
 
  % stimulus grid structure
  grid.stimGridTitles = {'Sweep Length (ms)', 'Frequency', 'Tone Delay (ms)', 'Tone Duration (ms)', 'Whisk voltage (V)', 'Whisk delay (ms)', 'Whisk Duration (ms)', 'Light voltage (V)', 'Light delay (ms)', 'Light Duration (ms)', 'Level (dB)'};
  lightvoltages = [0 5];
  whiskvoltages = [0 8];
  level=[60 80]
  tone_delay = [100];
  freqs =logspace(log10(4000), log10(1000*2^6),13);
  
  %control conditions
  no_whisk_no_light_condition=createPermutationGrid(300, freqs, 100, 100,whiskvoltages(1), 100, 50, lightvoltages(1), 100, 50, level);% 550ms length ()100ms duration tones) %normally sweep length 550
   %Create light condition
  % light_grid=createPermutationGrid(400, freqs, tone_delay, 50,whiskvoltages(1), 100, 50, lightvoltages(2), 100, 50, level);
  % whisk_grid=createPermutationGrid(400, freqs, tone_delay, 50,whiskvoltages(2), 100, 50, lightvoltages(1), 100, 50, level);

  
  % spontanous =[400,10, 100, 10,whiskvoltages(1), 100, 50, lightvoltages(1), 50, 1, -50];
    grid.stimGrid =  no_whisk_no_light_condition%cat(1,whisk_grid,light_grid,no_whisk_no_light_condition,spontanous);
  
%  fprintf('For calibration only!\n');
%  pause;
%  grid.stimGrid = [1000, 1000, 250, 500, 0, 0.01, 0.01, 80];

  % sweep parameters
   grid.postStimSilence = 0;
   grid.repeatsPerCondition = 30; 
  



  
  
  
