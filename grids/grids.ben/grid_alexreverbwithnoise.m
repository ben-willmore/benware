function grid = grid_alexreverbwithnoise

% essentials
grid.sampleRate = tdt50k;  % ~50kHz
grid.stimGenerationFunctionName = 'stimgen_loadSoundFile';
grid.stimDir = 'e:\auditory-objects\sounds-uncalib\alexreverbwithnoise\';
grid.stimFilename = 'alexreverb.%1.%2.%3.wav';

% stimulus grid structure
grid.stimGridTitles = {'Reverb_level', 'Stim_number', 'Repetition'};

grid.stimGrid = [];

for ii = 1:10
  grid_section = createPermutationGrid(0:2, 1:2, ii);
  idx = randperm(size(grid_section, 1));
  grid.stimGrid(end+1:end+length(idx),:) = grid_section(idx,:);
end

% grid.stimGrid = [...
%     createPermutationGrid(0:2,1:2,1:10); % sparseness sounds, 4 times
% ]; % DRCs

grid.repeatsPerCondition = 1;
grid.randomiseGrid = false;
% grid.postStimSilence = false;

% set this using absolute calibration
%grid.stimLevelOffsetDB = [16 16]+77;

% compensation filter
%grid.initFunction = 'loadCompensationFilters';
%grid.compensationFilterFile = ...
%'e:\auditory-objects\calibration\calib.ben.2013.04.27\compensationFilters.mat';
%grid.compensationFilterVarNames = {'compensationFilters.L', 'compensationFilters.R'};
