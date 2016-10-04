function stim = stimgen_trilateralNoise(expt, grid, ...
	                                   duration, leftDelay, rightDelay, bothDelay, level)
	%% stim = stimgen_trilateralNoise(expt, grid, ...
	%%	                             duration, leftDelay, rightDelay, bothDelay, level)
	%% This is a dumb generalisation to three channels of stimget_bilateralnoise,
    %% just duplicating the second channel onto the third. For testing 3-channel stimulus
    %% presentation
    
	%% get parameters
	sampleRate = grid.sampleRate;
	nChannels = expt.nStimChannels;

	if nChannels~=3
		errorBeep('Trilateral noise requires expt.nStimChannels=3');
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

	stim = randn(2,stimLen);

	envL = [zeros(1,leftDelay),ramp,ones(1,duration-2*length(ramp)),fliplr(ramp)];
	envL = [envL zeros(1,bothDelay-length(envL))];

	envR = [zeros(1,rightDelay),ramp,ones(1,duration-2*length(ramp)),fliplr(ramp)];
	envR = [envR zeros(1,bothDelay-length(envR))];

	envBoth = [ramp,ones(1,duration-2*length(ramp)),fliplr(ramp)];
	envBoth = [envBoth zeros(1,stimLen-length(envBoth)-length(envL))];

	envL = [envL envBoth];
	envR = [envR envBoth];

	stim = stim.*[envL; envR];
    stim(3,:) = -stim(2,:); % duplicated but negative (so channels aren't identical)

	% apply level offset
	level_offset = level-94;
	stim = stim * 10^(level_offset/20);
