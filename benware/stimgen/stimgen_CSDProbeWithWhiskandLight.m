function stim = stimgen_makeNoiseWithWhiskStim(expt, grid, ...
									duration, delay, len, whiskvoltage, whiskdelay, whiskduration,light_voltage, light_delay, light_duration, level)

%% get parameters
sampleRate = grid.sampleRate;
nChannels = expt.nStimChannels;

if nChannels~=3
	errorBeep('makeNoiseWithWhiskStim requires expt.nStimChannels=3');
end

% duration=1200
% whiskdelay=100
% whiskduration=50
% whiskvoltage = 8


% convert times to samples
duration = ceil(duration/1000*grid.sampleRate);
delay = round(delay/1000*grid.sampleRate);
len = round(len/1000*grid.sampleRate);
whiskdelay = ceil(whiskdelay/1000*grid.sampleRate);
whiskduration = ceil(whiskduration/1000*grid.sampleRate);
light_delay = ceil(light_delay/1000*grid.sampleRate);
light_duration = ceil(light_duration/1000*grid.sampleRate);
    
stimLen_samples = duration;

% sound in channel 1
uncalib = zeros(1, stimLen_samples);
uncalib(1, delay:delay+len-1) = randn(1, len); 

stim = nan(2, length(uncalib));
% set level correctly
uncalib = uncalib*sqrt(2);
uncalib = uncalib * 10^((level-94) / 20);

stim(1,:) = repmat(uncalib, 1, 1);

% whisker stim (piezoelectric) in channel 2
% 1 wave over 50 ms (20hz)

% whisk channel
whiskingtime=length(whiskdelay:min(stimLen_samples, whiskdelay+whiskduration-1));

t=[1:1:whiskingtime];
A=whiskvoltage;
f=0.0012865/2;%/2; %20hz
y=((((A/2)*cos(f*t))-(whiskvoltage/2))*-1)+0.000001;
%plot(t,y)
whiskstim = zeros(1, stimLen_samples)+0.000001; % you need to give the piezo electric a little bit of current, otherwise it will make a noise on initiaition
whiskstim(whiskdelay:min(stimLen_samples, whiskdelay+whiskduration-1)) =y;


stim(2,:) = whiskstim;



	%% light in last channel
    
   	lightstim = zeros(1, stimLen_samples);
	lightstim(1, light_delay:min(stimLen_samples, light_delay+light_duration-1)) = light_voltage;

	stim(nChannels,:) = lightstim;
