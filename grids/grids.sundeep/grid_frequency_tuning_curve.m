function grid = grid_frequency_tuning_curve()

%{

- Functions plays a sequence of pure tones within specified octaves for
  characterizing the best frequency (BF) of a sound-responsive neuron.
- Useful for presenting targeted stimuli at the BF of a cell.
- Plays sequence once at a given level.


The grid function will be called (by prepareGrid) as: grid = grid_tuningcurve()
       
Sundeep Teki
v1: 22-Jun-2016 18:36:16

%}

% controlling the sound presentation
grid.sampleRate                 = tdt100k;
grid.stimGenerationFunctionName = 'stimgen_makeTone_tuningcurve';

% stimulus grid structure
grid.stimGridTitles             = {'Frequency'};

% default tone parameters
fid = 1;
tone.freq_base        = 1000;
tone.octave_below     = 3;
tone.octave_above     = 4;
tone.tones_per_octave = 4;
tone.freqs            = logspace( log10(tone.freq_base*2^(-tone.octave_below)), log10(tone.freq_base*2^tone.octave_above), (tone.octave_above+tone.octave_below)*tone.tones_per_octave+1);

tone.level            = 65;
tone.dur              = 100;
tone.prestim_dur      = 100;
tone.poststim_dur     = 100;
tone.num_repeats      = 4;

% print default tone parameters
fprintf(fid, '%%% Using default tone parameters %%%\n');
fprintf(fid, 'F0                        = %s\n', [num2str(tone.freq_base) ' Hz']);
fprintf(fid, 'No. of octaves above F0    = %d\n', tone.octave_above);
fprintf(fid, 'No. of octaves below F0    = %d\n', tone.octave_below);
fprintf(fid, 'Bandwidth                  = %s\n', [num2str(tone.freq_base*2^-tone.octave_below) ' - ' num2str(tone.freq_base*2^tone.octave_above) ' Hz']);
fprintf(fid, 'No. of tones per octave    = %d\n', tone.tones_per_octave);
fprintf(fid, 'No. of tones in sequence   = %d\n', length(tone.freqs));
fprintf(fid, '\n');
fprintf(fid, 'Level                      = %s\n', [num2str(tone.level) ' dB']);
fprintf(fid, 'Duration of tone           = %s\n', [num2str(tone.dur) ' ms']);
fprintf(fid, 'Pre-stim duration          = %s\n', [num2str(tone.prestim_dur) ' ms']);
fprintf(fid, 'Post-stim duration         = %s\n', [num2str(tone.poststim_dur) ' ms']);
fprintf(fid, 'No. of repeats of sequence = %d\n', tone.num_repeats);
fprintf(fid, '\n');
fprintf(fid, 'Frequencies = %2.0f\n', tone.freqs);
fprintf(fid, '\n');    

% specify different tone parameters
fid = 1;
tone.getinput = input('Modify tone parameters or use default values - 0/1 : ');

if(tone.getinput)
    fprintf(fid, 'Specify tone parameters \n');
    tone.freq_base        = input('Enter base frequency (Hz) e.g. 1000 : ');
    tone.octave_below     = input('Enter number of octaves above base frequency e.g. 5 :');
    tone.octave_above     = input('Enter number of octaves below base frequency e.g. 3 :');
    tone.tones_per_octave = input('Enter number of tones per octave e.g. 4 :');
    tone.freqs            = logspace( log10(tone.freq_base*2^(-tone.octave_below)), log10(tone.freq_base*2^tone.octave_above), (tone.octave_above+tone.octave_below)*tone.tones_per_octave + 1);
    
    tone.level            = input('Enter level of tone (dB) e.g. 65 :');
    tone.dur              = input('Enter duration of tone (ms) e.g. 100 :');
    tone.prestim_dur      = input('Enter pre-stim silence duration (ms) e.g. 200 :');
    tone.poststim_dur     = input('Enter post-stim silence duration (ms) e.g. 200 :');
    tone.num_repeats      = input('Enter number of times to repeat entire tone sequence e.g. 4:'); % repeat sequence to get average response at each frequency    
end
        
% if calibration required
global CALIBRATE;
if CALIBRATE
    fprintf('== Calibration mode. Press a key to continue == ')
    pause;
    freqs = [1000];
    levels = 80;
    tonedur = 1000;
end

% sweep parameters
grid.stimGrid            = createPermutationGrid(tone.freqs);
grid.repeatsPerCondition = tone.num_repeats;
grid.tone                = tone;
grid.randomiseGrid       = true; % check
grid.postStimSilence     = 0; % in seconds (added in stimgen_makeTone_tuningcurve)

% set this using absolute calibration
% grid.legacyLevelOffsetDB = -20;

% compensation filters
% grid.initFunction = 'loadCompensationFilters';
% grid.compensationFilterFile = ...
%   'e:\auditory-objects\calibration\calib.ben.18.11.2013\compensationFilters.100k.mat'; % 100kHz
% grid.compensationFilterVarNames = {'compensationFilters.L', 'compensationFilters.R'};
