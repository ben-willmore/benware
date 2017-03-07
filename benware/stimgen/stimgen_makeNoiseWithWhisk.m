function stim = stimgen_makeNoiseWithWhiskStim(expt, grid, ...
									duration, delay, len, voltage, whiskdelay, whiskduration, level)

%% get parameters
sampleRate = grid.sampleRate;
nChannels = expt.nStimChannels;

if nChannels~=2
	errorBeep('makeNoiseWithWhiskStim requires expt.nStimChannels=2');
end

% duration=1200
% whiskdelay=100
% whiskduration=25
% voltage = 8


% convert times to samples
duration = ceil(duration/1000*grid.sampleRate);
delay = round(delay/1000*grid.sampleRate);
len = round(len/1000*grid.sampleRate);
whiskdelay = ceil(whiskdelay/1000*grid.sampleRate);
whiskduration = ceil(whiskduration/1000*grid.sampleRate);

stimLen_samples = duration;

% sound in channel 1
uncalib = zeros(1, stimLen_samples);
uncalib(1, delay:delay+len-1) = randn(1, len); 

stim = nan(2, length(uncalib));
stim(1,:) = uncalib;

% whisker stim (piezoelectric) in channel 2
% 1 wave over 50 ms (20hz)

whiskingtime=length(whiskdelay:min(stimLen_samples, whiskdelay+whiskduration-1));

t=[1:1:whiskingtime];
A=voltage;
f=0.0012865/2; %20hz
y=((((A/2)*cos(f*t))-(voltage/2))*-1)+0.000001;
%plot(t/sampleRate,y)
whiskstim = zeros(1, stimLen_samples)+0.000001; % you need to give the piezo electric a little bit of current, otherwise it will make a noise on initiaition
whiskstim(whiskdelay:min(stimLen_samples, whiskdelay+whiskduration-1)) =y;


stim(2,:) = whiskstim;

% set level correctly
uncalib = uncalib*sqrt(2);
uncalib = uncalib * 10^((level-94) / 20);

stim(1,:) = repmat(uncalib, 1, 1);