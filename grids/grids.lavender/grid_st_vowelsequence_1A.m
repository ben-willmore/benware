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


Sundeep Teki
v1: 29.04.16

v2: 06.05.16
Added more vowel fields, start up greetings, grid.condition check based on day
%}


%% required parameters

grid.seed                       = rng;
grid.sampleRate                 = tdt100k;
grid.stimGenerationFunctionName = 'stimgen_st_vowelsequence_1A';
grid.date                       = datestr(now);

%% Stimulus parameters

grid.stimGridTitles = {'Frequency of vowel 1','Frequency of vowel 2','Frequency of vowel 3','Frequency of vowel 4'};

% stimulus parameters
vowel.F0         = 125; % Hz
vowel.order      = [2 0 3 1];
vowel.timbre     = 'a';

if(strcmpi(vowel.timbre,'a'))
    vowel.formants   = [936 1551 2815 4290];            % for vowel a
elseif(strcmpi(vowel.timbre,'e'))
    vowel.formants   = [730 2058 2979 4294];            % for vowel e
elseif(strcmpi(vowel.timbre,'i'))
    vowel.formants   = [437 2761 3372 4352];            % for vowel i
elseif(strcmpi(vowel.timbre,'u'))
    vowel.formants   = [460 1105 2735 4115];            % for vowel u
elseif(strcmpi(vowel.timbre,'test'))
    vowel.formants   = [1350 2384 3724 4012];           % for testing purposes only
end

vowel.octavesep  = 0.75;
vowel.freqs      = floor(vowel.F0*2.^(vowel.octavesep.*vowel.order)); % [353 125 594 210]; for experiment 1A only
vowel.bandwidth  = [80 70 160 300];                 % Hz, constant for each vowel
vowel.dur        = 0.15;                            % seconds
vowel.level      = 65;                              % dB
vowel.amp        = 20e-6*10.^(vowel.level/20);      % convert to Pascals
vowel.carrier    = 'clicktrain';
vowel.hannramp   = 0.005;                           % ramp size - 5ms
vowel.preisi     = 0.5;                             % pre-stim interval; seconds
vowel.postisi    = 1;                               % post-stim interval; seconds

%% Greetings

fid = 1;
fprintf(fid, 'VOWEL PARAMETERS \n');
fprintf(fid, 'F0 = %1.0f\n', vowel.F0);
fprintf(fid, 'Frequencies = %d\n', vowel.freqs);
fprintf(fid, 'Timbre = [%s]\n', vowel.timbre);
fprintf(fid, 'Formant frequencies = %d\n', vowel.formants);
fprintf(fid, 'Duration = %d\n', vowel.dur);
fprintf(fid, 'Level = %d\n', vowel.level);
fprintf(fid, '\n');
fprintf(fid, 'EXPERIMENT PARAMETERS  \n');
fprintf(fid, 'Experimental animals: Kea & Munchkin\n');
fprintf(fid, 'Control animals:      Lavender & Paprika\n');
fprintf(fid, 'Training phase:       Days 1 - 4   [May 9-12] \n');
fprintf(fid, 'Testing phase:        Days 5, 8, 10, 12   [May 13, 16, 18, 20] \n');
fprintf(fid, '\n');
fprintf(fid, 'ENTER EXPERIMENT DETAILS \n');


%% Specify experimental condition, animal group and testing day

grid.day_expt    = input('Enter the day of experiment - 1/2/3/4/5 etc.: ');
grid.ferret      = input('Enter the name of the ferret: ','s');
grid.animalgroup = input('Enter the animal group - [Experimental / Control]: ','s');

if(grid.day_expt < 5)
    warning('Training days = 1/2/3/4 only');
    grid.condition   = 'Training';  %input('Enter the experimental condition - [Training / Test]: ','s');
    fprintf(1, '%%%%%   grid.condition = [%s]\n', grid.condition);
else
    warning('Test days = 5/8/10/12 only');
    grid.condition = 'Test';
    fprintf(1, '%%%%%   grid.condition = [%s]\n', grid.condition);
end


% Experimental group of animals - training phase
if(strcmpi(grid.animalgroup,'Experimental') && strcmpi(grid.condition,'Training'))
        
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

grid.postStimSilence    = 0; % in seconds (added in stimgen_st_vowelsequence_1A)
grid.vowel              = vowel;
grid.randomiseGrid      = false;
