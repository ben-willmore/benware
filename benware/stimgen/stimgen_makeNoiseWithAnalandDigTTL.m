function stim = stimgen_makeNoiseWithAnalandDigTTL(expt, grid, ...
    duration, StimID, delay, len, analvoltage, analdelay, analduration, digvoltage, digdelay, digduration, level)
%% stim = stimgen_makeCalibTone(expt, grid, varargin)
%%
%% This is a model for new-style (2016 onward) benware stimulus generation functions
%%
%% The stimulus generation function will be called (by prepareStimulus) as:
%%   uncomp = stimgen_function(expt, grid, parameters{:})
%% where 'parameters' is a row from grid.stimGrid, so the parameters are values
%% of the stimulus parameters specified in grid.stimGridTitles.
%%
%% Stimulus generation functions must obey the following rules:
%%
%% 1. Must have a name that begins stimgen_
%% 2. Accept parameters:
%%      expt: standard benware expt structure (as loaded by loadexpt.m)
%%      grid: standard benware grid structure (produced by grid_*.m)
%%      varargin: a list of parameters, whose length matches
%%            the length of grid.stimGridTitles
%% 3. Produces a matrix containing uncalibrated sound, meeting these criteria:
%%      A. The sample rate must match grid.sampleRate
%%      B. The first dimension of this matrix must match expt.nStimChannels.
%%      C. The values are measured in Pascals, so that a sound with an RMS of 1
%%         corresponds to 1 Pascal RMS, or 94 dB SPL.

%% get parameters
sampleRate = grid.sampleRate;
nChannels = expt.nStimChannels;

if nChannels~=3
    errorBeep('stimgen_makeNoiseWithAnalandDigTTL requires expt.nStimChannels=3');
end
stimLen_samples = ceil(duration/1000*grid.sampleRate);

% Generate Noise

new_expt = expt;
new_expt.nStimChannels = 1;

% remove light_voltage from grid.stimGridTitles and from the parameter list
% so that these are now in the format expected by stimgen_loadSoundfile.m
new_grid = grid;
valid_idx = [1 3 4 11]; % parameters we want to pass on to stimgen_CSDprobe.m
new_grid.stimGridTitles = new_grid.stimGridTitles(valid_idx);
params = num2cell([duration, delay, len, level]);
stimTemp = stimgen_CSDProbe(new_expt, new_grid, params{:});
stim(1,:) = stimTemp;

% anal channel
analdelay = ceil(analdelay/1000*grid.sampleRate);
analduration = ceil(analduration/1000*grid.sampleRate);

% analog channel in 2nd
% 	analdelay = ceil(lightdelay/1000*grid.sampleRate);
% 	analduration = ceil(lightduration/1000*grid.sampleRate);
analstim = zeros(1, stimLen_samples);
analstim(1, analdelay:min(stimLen_samples, analdelay+analduration-1)) = analvoltage;

stim(2,:) = analstim;

% dig in last channel
digdelay = ceil(digdelay/1000*grid.sampleRate);
digduration = ceil(digduration/1000*grid.sampleRate);
digstim = zeros(1, stimLen_samples);
digstim(1, digdelay:min(stimLen_samples, digdelay+digduration-1)) = digvoltage;


stim(3, :) = digstim;
