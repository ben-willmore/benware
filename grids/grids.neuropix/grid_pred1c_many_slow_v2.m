function grid = grid_pred1c_many_slow_v2()

% controlling the sound presentation
grid.sampleRate = tdt100k;
grid.stimGenerationFunctionName = 'stimgen_loadSoundFile';
grid.stimDir = 'e:\benware.sounds.uncalib\pred1c_many_slow_v2\';
grid.stimFilename = 'pred1c_many.type%1.set%2.n%3.wav';

% stimulus grid structure
rng('shuffle')
grid.stimGridTitles = {'Type','Set','Number'};
% sG1 = [];
% for n=1:10
%     sG1temp = createPermutationGrid(1,1:14,n);
%     sG1temp = sG1temp(randperm(size(sG1temp,1)),:);
%     sG1 = [sG1; sG1temp];
% end
% stimGrid{1} = sG1;

% sG2 = [];
% for n=1:10
%     sG2temp = createPermutationGrid(0,1:9,n);
%     sG2temp = sG2temp(randperm(size(sG2temp,1)),:);
%     sG2 = [sG2; sG2temp];
% end
% stimGrid{2} = sG2;

sG1 = createPermutationGrid(2,1,1:10);
stimGrid{1} = sG1(randperm(size(sG1,1)),:);

sG2 = createPermutationGrid(3,1,1:10);
stimGrid{2} = sG2(randperm(size(sG2,1)),:);

sG3 = createPermutationGrid(4,1,1:10);
stimGrid{3} = sG3(randperm(size(sG3,1)),:);

sG4 = createPermutationGrid(2,2,1:10);
stimGrid{4} = sG4(randperm(size(sG4,1)),:);

sG5 = createPermutationGrid(3,2,1:10);
stimGrid{5} = sG5(randperm(size(sG5,1)),:);

sG6 = createPermutationGrid(4,2,1:10);
stimGrid{6} = sG6(randperm(size(sG6,1)),:);

sG7 = createPermutationGrid(2,3,1:10);
stimGrid{7} = sG7(randperm(size(sG7,1)),:);

sG8 = createPermutationGrid(3,3,1:10);
stimGrid{8} = sG8(randperm(size(sG8,1)),:);

sG9 = createPermutationGrid(4,3,1:10);
stimGrid{9} = sG9(randperm(size(sG9,1)),:);

rateord = randperm(3);
%reord = [2 2+rateord 5+rateord 1];
reord = [rateord 3+rateord 6+rateord];

stimGrid = stimGrid(reord);
sG = cat(1,stimGrid{:});
grid.stimGrid = sG;



%   global CALIBRATE;
%   if CALIBRATE
%     fprintf('== Calibration mode. Press a key to continue == ')
%     pause;
%     grid.stimGrid = createPermutationGrid(1, 1);
%   end

% sweep parameters
grid.postStimSilence = 0;
grid.repeatsPerCondition = 1;
grid.randomiseGrid = false;

% set this to match nominal level of 80dB
%   grid.legacyLevelOffsetDB = 7;
