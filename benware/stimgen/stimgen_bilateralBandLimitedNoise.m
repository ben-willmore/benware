function stim = stimgen_bilateralBandLimitedNoise(expt, grid, ...
	                                   duration, leftDelay, rightDelay, bothDelay, f_min, f_max, level)
	%% stim = stimgen_bilateralNoise(expt, grid, ...
	%%	                             duration, leftDelay, rightDelay, bothDelay, level)
	%%
	%% generate L-R-both bilateral noise stimulus, used as a search stimulus by Ben
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

	if nChannels~=2
		errorBeep('Bilateral noise requires expt.nStimChannels=2');
	end


	%% generate stimulus

	% convert lengths from ms to samples
	duration = ceil(duration/1000*sampleRate);
	leftDelay = ceil(leftDelay/1000*sampleRate);
	rightDelay = ceil(rightDelay/1000*sampleRate);
	bothDelay = ceil(bothDelay/1000*sampleRate);
	stimLen = bothDelay + duration;

	% 2.5 ms for the ramp is 10 ms for the whole cycle
	rampT = round(10/1000*sampleRate);

	% 2*pi*f*t
	ramp = sin(2*pi*(1/rampT)*(1:rampT/4));

    % generate band limited noise
    carrier = randn(1, stimLen);
    [N, Wn] = buttord([f_min f_max]/(sampleRate/2), [f_min*.5 f_max/.5]/(sampleRate/2), 2, 20);
    [B, A] = butter(N, Wn);
    carrier = filtfilt(B, A, carrier);
    stim = carrier/rms(carrier);
    
    % now rms = 1, i.e. 94dB
    
	envL = [zeros(1,leftDelay),ramp,ones(1,duration-2*length(ramp)),fliplr(ramp)];
	envL = [envL zeros(1,bothDelay-length(envL))];

	envR = [zeros(1,rightDelay),ramp,ones(1,duration-2*length(ramp)),fliplr(ramp)];
	envR = [envR zeros(1,bothDelay-length(envR))];

	envBoth = [ramp,ones(1,duration-2*length(ramp)),fliplr(ramp)];
	envBoth = [envBoth zeros(1,stimLen-length(envBoth)-length(envL))];

	envL = [envL envBoth];
	envR = [envR envBoth];

	stim = stim.*[envL; envR];

	% apply level offset
	level_offset = level-94;
	stim = stim * 10^(level_offset/20);

