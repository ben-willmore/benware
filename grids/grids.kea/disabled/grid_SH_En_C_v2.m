function grid = grid_sh_en_c_v2

% essentials
grid.sampleRate = tdt50k;  % ~50kHz
grid.stimGenerationFunctionName = 'stimgen_loadSoundFile';
grid.stimDir = 'c:\awakedata\stimuli_oldstyle\SH.En.C_v2\';
grid.stimFilename = 'source.%1.sound.%2.snr.%3.token.%4.fw.%5.frozen.%6.wav';

% stimulus grid structure
grid.stimGridTitles = {'Source', 'Mode', 'BF', 'Token', 'Set', 'StimID'};

grid.stimGrid = [...
    createPermutationGrid(1, 0, 0, 0, 2, 1:12); % sparseness sounds, 4 times
    createPermutationGrid(1, 0, 0, 0, 2, 1:12);
    createPermutationGrid(1, 0, 0, 0, 2, 1:12);
    createPermutationGrid(1, 0, 0, 0, 2, 1:12);
    2   0   0   0   1   1; % environmental sounds, 4 times
    2   0   0   0   1   2;
    2   0   0   0   1   3;
    2   0   0   0   1   4;
    2   0   0   0   1   5;
    2   0   0   0   1   6;
    2   0   0   0   1   7;
    2   0   0   0   1   8;
    2   0   0   0   1   1;
    2   0   0   0   1   2;
    2   0   0   0   1   3;
    2   0   0   0   1   4;
    2   0   0   0   1   5;
    2   0   0   0   1   6;
    2   0   0   0   1   7;
    2   0   0   0   1   8;
    2   0   0   0   1   1;
    2   0   0   0   1   2;
    2   0   0   0   1   3;
    2   0   0   0   1   4;
    2   0   0   0   1   5;
    2   0   0   0   1   6;
    2   0   0   0   1   7;
    2   0   0   0   1   8;
    2   0   0   0   1   1;
    2   0   0   0   1   2;
    2   0   0   0   1   3;
    2   0   0   0   1   4;
    2   0   0   0   1   5;
    2   0   0   0   1   6;
    2   0   0   0   1   7;
    2   0   0   0   1   8;
    createPermutationGrid(9, 0, 0, 0:2, [10, 20, 30, 40], 0);]; % DRCs

%  fprintf('Calibration only!!\n');
%  grid.stimGrid = [createPermutationGrid(9, 0, 0, 0, 10, 0, 75, -13);];

grid.repeatsPerCondition = 5;
grid.postStimSilence = 0.2;
grid.legacyLevelOffsetDB = -40;

% set this using absolute calibration
%grid.stimLevelOffsetDB = [16 16]+77;

% compensation filter
%grid.initFunction = 'loadCompensationFilters';
%grid.compensationFilterFile = ...
%'e:\auditory-objects\calibration\calib.ben.2013.04.27\compensationFilters.mat';
%grid.compensationFilterVarNames = {'compensationFilters.L', 'compensationFilters.R'};
