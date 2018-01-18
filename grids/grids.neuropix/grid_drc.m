function grid = grid_drc

% essentials
grid.sampleRate = tdt50k;  % ~50kHz
grid.stimGenerationFunctionName = 'stimgen_loadSoundFile';
grid.stimDir = 'e:\benware.sounds.uncalib\SH.En.C_v2\';
grid.stimFilename = 'source.%1.sound.%2.snr.%3.token.%4.fw.%5.frozen.%6.wav';

% stimulus grid structure
grid.stimGridTitles = {'Source', 'Mode', 'BF', 'Token', 'Set', 'StimID'};

grid.stimGrid = [createPermutationGrid(9, 0, 0, 0:2, [10, 20, 30, 40], 0)]; % DRCs

grid.repeatsPerCondition = 5;
