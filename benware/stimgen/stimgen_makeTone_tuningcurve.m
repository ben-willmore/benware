function stim = stimgen_makeTone_tuningcurve(expt, grid, varargin)

%{

Function generates a tone specifically for grid_tuningcurve

Sundeep Teki
v1: 22-Jun-2016 18:56:31

%}


%% get parameters

sampleRate  = grid.sampleRate;
nChannels   = expt.nStimChannels;
tone        = grid.tone;
freq        = varargin{1};

%% generate stimulus

% time
t = 0:1/sampleRate:tone.dur/1000;

% sinusoid
uncalib = sin(2*pi*freq*t);

% ramp up and down
ramplen_samples = round(5/1000*sampleRate);
ramp            = (1-cos(pi*(1:ramplen_samples)/ramplen_samples))/2;
env             = [ramp ones(1,length(uncalib)-2*length(ramp)) fliplr(ramp)];
uncalib         = uncalib.*env;

% set level correctly
uncalib         = uncalib*sqrt(2);
uncalib         = uncalib * 10^((tone.level-94) / 20);

pre_silence     = zeros(1,round(tone.prestim_dur*sampleRate));
post_silence    = zeros(1,round(tone.poststim_dur*sampleRate));
stim            = [pre_silence uncalib post_silence];
stim            = repmat(uncalib, nChannels, 1);

