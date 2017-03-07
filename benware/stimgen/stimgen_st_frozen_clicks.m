function stim = stimgen_st_frozen_clicks(expt,grid,varargin)

%{

------------    
Sundeep Teki
v1: 27-Jun-2016 08:53:36

%}

sampleRate       = grid.sampleRate; 
nChannels        = expt.nStimChannels;
click            = grid.click;
stimtype         = varargin;

%% deal with random number generator

% rng('default')
% if (~isempty(click.seed) & stimtype == 2)
    rng(click.seed);
% else
%     rng('shuffle');
%     randstate = rng;
%     click.seed = randstate.Seed;
% end

if click.mingap > click.maxgap/2 % check the actual value!
    error('Min and mastim gap seem too close!')
end

% number of samples for a click
nclicksamp = floor(click.clickdur*sampleRate);

% highpass filter
if click.highpass ~= 0
    [B,A] = butter(8,click.highpass*2/sampleRate,'high');
end

% main loop
stim = [];
click.clicktimes = [];

for irep = 1:1:click.nreps
    
    if ( (irep == 1) || (stimtype == 0) )
        % a zero vector with correct length
        stimseg = zeros(1,floor(sampleRate*click.replength));
        % draw a random number of interval until we are too long
        idstim = 1;
        okflag = 1;
        clicktimes = [];
        clicktimes(1) = 1/sampleRate;

        while okflag
            zclicktimes = click.mingap + rand(1)*(click.maxgap-click.mingap);
            idstim = idstim+1;
            clicktimes(idstim) = clicktimes(idstim-1)+zclicktimes;
            if clicktimes(idstim) > click.replength-click.maxgap;
                okflag = 0;
            end
        end
        % convert to samples
        click.clicksamples = ceil(clicktimes*sampleRate);
        for iclicksamp = 1:1:nclicksamp
          stimseg(click.clicksamples+iclicksamp-1) = 1;
        end
        if click.highpass ~= 0
          stimseg = filter(B,A,stimseg);
        end
    end
    
    stim = [stim stimseg];
    click.clicktimes = [click.clicktimes ((irep-1)*click.replength + click.clicksamples./sampleRate)];

end

% deal with level
stim = click.amp/sqrt(mean(stim.^2)) .* stim; 

%% check that we did not clip

if mastim(abs(stim))>0.999
    warning('Clipped!')
    pause(0.01);
    [stim,click] = genmemoclicks(click,sigint);
end
    
%% final stim

pre_silence  = zeros(1,round(click.preisi*sampleRate));
post_silence = zeros(1,round(click.postisi*sampleRate));
stim         = [pre_silence stim post_silence];
stim         = repmat(stim, nChannels, 1);
