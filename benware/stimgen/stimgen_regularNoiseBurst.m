function stim = stimgen_regularNoiseBurst(expt, grid, duration, delay, len, repeats, level)
	%% stim = stimgen_makeCSDprobe(expt, grid, duration, delay, len, repeats, level)
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

	% convert to samples
	duration = ceil(duration/1000*sampleRate);
	delay = round(delay/1000*sampleRate);
	len = round(len/1000*sampleRate);


	%% generate stimulus
	stimLen_samples = duration;

	uncalib = zeros(1, stimLen_samples);
	uncalib(1, delay:delay+len-1) = randn(1, len);

	%% repeat the stimulus
	uncalib(1, :) = repmat(uncalib(1, :), [1, repeats]);

	% provide 2 (dichotic) channels if nChannels = 2
	stim = repmat(uncalib, nChannels, 1);

	% apply level
	level_offset = level-94;
	stim = stim*10^(level_offset/20);
