function grid = grid_st_vowelsequence_1A()

%{
    The grid function will be called (by prepareGrid) as: grid = grid_st_vowelsequence_1A()
    
    Will return a grid structure containing the fields:
         grid.sampleRate: stimulus sample rate
         grid.stimGenerationFunctionName: name of a stimulus generation function
         grid.stimGridTitles: a cell containing the names of stimulus parameters
         grid.stimulusGrid: a matrix specifying values of the parameters in
              grid.stimGridTitles, one stimulus per row. The number of columns must
              match the length of grid.stimGridTitles
         grid.repeatsPerCondition: integer specifying how many times the
              grid will be repeated
    
     The stimulus generation function will be called by BenWare to generate each stimulus as:
     uncomp = stimgen_function(expt, grid, parameters{:})
     
 % check
1. seed type
2. tdt100k = 97656Hz?
3. check fields in verifyGridFields.m
4. pass a stimulus structure to stimgen?

% to do
1. add experiment-specific greeting - expt/control conditions, ferret
names, training and test days

Sundeep Teki
v1: 29.04.16

%}

%% required parameters

grid.seed                       = rng;
grid.sampleRate                 = tdt100k; % check this value = 97656Hz?
grid.stimGenerationFunctionName = 'stimgen_st_vowelsequence_1A';

%% Stimulus parameters

grid.stimGridTitles = {'Frequency of vowel 1','Frequency of vowel 2',...
    'Frequency of vowel 3','Frequency of vowel 4'};

% stimulus parameters
vowel.timbre     = 'a'; %'a';
vowel.F0         = 125; %125;
vowel.order      = [2 0 3 1]; %[2 0 3 1];

if(strcmpi(vowel.timbre,'a'))
    vowel.formants   = [936 1551 2815 4290];            % for vowel a
elseif(strcmpi(vowel.timbre,'e'))
    vowel.formants   = [730 2058 2979 4294];            % for vowel e
elseif(strcmpi(vowel.timbre,'i'))
    vowel.formants   = [437 2761 3372 4352];            % for vowel i
elseif(strcmpi(vowel.timbre,'u'))
    vowel.formants   = [460 1105 2735 4115];            % for vowel u
end

vowel.octavesep  = 0.75;
vowel.freqs      = floor(vowel.F0*2.^(vowel.octavesep.*vowel.order)); % [353 125 594 210]; for experiment 1A only
vowel.bandwidth  = [80 70 160 300];                 % Hz, constant for each vowel
vowel.dur        = 0.15;                            % seconds
vowel.level      = 65;                              % dB
vowel.amp        = 20e-6*10.^(vowel.level/20);      % convert to Pascals
vowel.carrier    = 'clicktrain';
vowel.hannramp   = 0.005;                           % ramp size - 5ms
vowel.isi        = 1.5;                             % post-stim interval; seconds

%% Specify experimental condition, animal group and testing day

grid.animalgroup = input('Enter the animal group - [Experimental / Control]: ','s');
grid.ferret      = input('Enter the name of the ferret: ','s');
grid.condition   = input('Enter the experimental condition - [Training / Test]: ','s');
grid.day         = input('Enter the day of experiment - 1/2/3/4/5/6-10 etc.: ');
grid.date        = datestr(now);


% Experimental group of animals - training phase
if(strcmpi(grid.animalgroup,'Experimental') && strcmpi(grid.condition,'Training'))
    
    vowel.sequence                  = input('Enter name of sequence - [ABCD]: ' ,'s');
    grid.stimGrid                   = vowel.freqs;
    grid.repeatsPerCondition        = 48; % 48 repeats of 1 fixed stimulus
    
end

% Experimental group of animals - test phase
if(strcmpi(grid.animalgroup,'Experimental') && strcmpi(grid.condition,'Test'))
    
    vowel.sequence                  = input('Enter name of sequence - [ABCD / DCBA / ABCD300]: ','s');
    
    if(strcmpi(vowel.sequence,'ABCD'))
        grid.stimGrid               = vowel.freqs;
    end
    
    if(strcmpi(vowel.sequence,'ABCD300'))
        vowel.dur                   = 0.3;
        grid.stimGrid               = vowel.freqs;
    end
    
    if(strcmpi(vowel.sequence,'DCBA'))
        grid.stimGrid               = vowel.freqs(end:-1:1);
    end
    
    grid.repeatsPerCondition        = 48; % 48 repeats of each of 1 fixed test stimuli per block
end

% Control group of animals - training phase
if(strcmpi(grid.animalgroup,'Control') && strcmpi(grid.condition,'Training'))
    
    temp                            = vowel.freqs(perms(1:length(vowel.freqs))); % 24 permutations
    temp1                           = repmat(temp,2,1); % 48 trials
    grid.stimGrid                   = temp1(randperm(length(temp1)),:);
    grid.repeatsPerCondition        = 1; % 1 repeat per unique scrambled stimulus
    
end

% Control group of animals - test phase
if(strcmpi(grid.animalgroup,'Control') && strcmpi(grid.condition,'Test'))
    
    vowel.sequence                  = input('Enter name of sequence - [ABCD / DCBA / ABCD300]: ','s');
    
    if(strcmpi(vowel.sequence,'ABCD'))
        grid.stimGrid               = vowel.freqs;
    end
    
    if(strcmpi(vowel.sequence,'ABCD300'))
        vowel.dur                   = 0.3;
        grid.stimGrid               = vowel.freqs;
    end
    
    if(strcmpi(vowel.sequence,'DCBA'))
        grid.stimGrid               = vowel.freqs(end:-1:1);
    end
    
    grid.repeatsPerCondition        = 48; % 48 repeats of each of the 3 test stimuli
end

%% sweep parameters

grid.postStimSilence     = 0; % in seconds (added in stimgen_st_vowelsequence_1A)

grid.vowel = vowel;

% optional parameters
grid.randomiseGrid = false;
% grid.legacyLevelOffsetDB = 0; % avoid using this
