function grid = grid_drc200k_25ms_with_lighttrain()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_loadSoundFileWith20HzLightTrain';
  grid.stimDir = 'E:\auditory-objects\michael.stimuli\drc1.dur25.3contrasts\';
  %grid.stimDir = '/Users/ben/scratch/texture/texture.v2/renamed/';
  grid.stimFilename = 'drc%1_dur%3_contrast%2.wav';
  
  % stimulus grid structure
  grid.stimGridTitles = {'DRC ID', 'Contrast', 'Chord dur', 'Light voltage', 'Level'};
  
  voltages = [0 5]; % voltage to use for light
  grid.stimGrid = createPermutationGrid(1, 30, 25, voltages, 80);

  % for calibration
%  grid.stimGrid = createPermutationGrid(9, 9, 80);
%  fprintf('For calibration only!\n');
%  pause;
%  grid.stimGrid = createPermutationGrid(1, [10], 25, 0, 80); 

  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 20;
  
  