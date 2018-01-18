function stim = stimgen_makeCalibTone(expt, grid, varargin)
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

	nExpectedParameters = 3;
	assert(length(varargin)==nExpectedParameters);
	freq = varargin{1};
	duration = varargin{2};
	level = varargin{3};


	%% generate stimulus

	% time
	t = 0:1/sampleRate:duration/1000;

	% sinusoid
	uncalib = sin(2*pi*freq*t);

	% ramp up and down
	ramplen_samples = round(5/1000*sampleRate);
	ramp = (1-cos(pi*(1:ramplen_samples)/ramplen_samples))/2;
	env = [ramp ones(1,length(uncalib)-2*length(ramp)) fliplr(ramp)];
	uncalib = uncalib.*env;
    % putting a silence
    uncalib = [uncalib zeros(1,round(0.3*sampleRate))]; % MR
	% set level correctly
	uncalib = uncalib*sqrt(2);
	uncalib = uncalib * 10^((level-94) / 20);

	stim = repmat(uncalib, nChannels, 1);
