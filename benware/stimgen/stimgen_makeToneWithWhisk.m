function stim = makeCalibToneWithLight(expt, grid, ...
								duration, freq, delay, len, voltage, whiskdelay, whiskduration, level)

%% get parameters
sampleRate = grid.sampleRate;
nChannels = expt.nStimChannels;

if nChannels~=2
	errorBeep('CalibToneWithLight requires expt.nStimChannels=2');
end                            

stimLen_samples = ceil(duration/1000*grid.sampleRate);
% time
t = 0:1/grid.sampleRate:len/1000;

% sinusoid
tone = sin(2*pi*freq*t);
delay = zeros(1, ceil(delay/1000*grid.sampleRate));
remainder = zeros(1, (stimLen_samples-length(tone)-length(delay)));

% ramp up and down
ramplen_samples = round(5/1000*grid.sampleRate);
ramp = (1-cos(pi*(1:ramplen_samples)/ramplen_samples))/2;
env = [ramp ones(1,length(tone)-2*length(ramp)) fliplr(ramp)];
tone = tone.*env;

uncalib = [delay tone remainder];


% whisk in channel 2
whiskdelay = ceil(whiskdelay/1000*grid.sampleRate);
whiskduration = ceil(whiskduration/1000*grid.sampleRate);

whiskingtime=length(whiskdelay:min(stimLen_samples, whiskdelay+whiskduration-1));

t=[1:1:whiskingtime];
A=voltage;
f=0.0012865; %20hz
y=((((A/2)*cos(f*t))-(voltage/2))*-1)+0.000001;
%plot(t,y)
whiskstim = zeros(1, stimLen_samples)+0.000001; % you need to give the piezo electric a little bit of current, otherwise it will make a noise on initiaition
whiskstim(whiskdelay:min(stimLen_samples, whiskdelay+whiskduration-1)) =y;


stim(2, :) = whiskstim;

% set level correctly
uncalib = uncalib*sqrt(2);
uncalib = uncalib * 10^((level-94) / 20);

stim(1,:) = repmat(uncalib, 1, 1);

