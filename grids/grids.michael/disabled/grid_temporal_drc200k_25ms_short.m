function grid = grid_drc200k_25ms_short()

  % controlling the sound presentation
  grid.sampleRate = 24414.0625*8;  % ~200kHz
  grid.stimGenerationFunctionName = 'stimgen_loadSoundFileWithLight';
  grid.stimDir = 'e:\auditory-objects\sounds-uncalib\mouse.drc.11\';
  grid.stimFilename = 'drc%1_dur%3_contrast%2.f32';
  
  % stimulus grid structure
  grid.stimGridTitles = {'DRC ID', 'Contrast', 'Chord dur', 'Light voltage', 'Level'};
  
  voltage = 5; % voltage to use for light
  grid.stimGrid = createPermutationGrid(1:4, [20 40 99], 25, [0 voltage], 80);

  % sweep parameters
  grid.postStimSilence = 0;
  grid.repeatsPerCondition = 10;
  
  % set this using absolute calibration
  grid.stimLevelOffsetDB = [16 0];
  