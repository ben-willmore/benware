function grid = grid_FRA_with_Analog2andDigital3_3chan()

% controlling the sound presentation
grid.sampleRate = 24414.0625*8;  % ~200kHz
grid.stimGenerationFunctionName = 'stimgen_makeToneWithAnalandDigTTL';

% stimulus grid structure
grid.stimGridTitles = {'Sweep Length (ms)', 'Frequency', 'Tone Delay (ms)', 'Tone Duration (ms)', 'Analog Chan2 voltage (V)', 'Analog Chan2 delay (ms)', 'Analog Chan2 Duration (ms)', 'Digital Chan3 voltage (V)', 'Digital Chan3 delay (ms)', 'Digital Chan3 Duration (ms)', 'Level (dB)'};
Digvoltages = [0 5];
Analvoltages = [0 9];
level=[20:20:80];
tone_delay_aud = [100]
tone_delay_light = [100];
stim_dur=[50];

retinotopic_positions=[1:120];
%   freqs = logspace(log10(1250), log10(1000*2^6),26);
freqs = logspace(log10(1000), log10(1000*2^6),25);% [0.1 to 6.4KHz]
%   logspace(log10(1250), log10(1000*2^6.3220),25) from [1.250 to 80]

% Auditory conditions
auditory_grid=createPermutationGrid(800, freqs, tone_delay_aud, stim_dur,Analvoltages(1), 100, 50, Digvoltages(2), 100, 50, level);% 550ms length ()100ms duration tones) %normally sweep length 550
%Create visual condition
visual_grid=createPermutationGrid(800, retinotopic_positions, tone_delay_light, stim_dur,Analvoltages(2), 100, 50, Digvoltages(2), 100, 50, -50);


grid.stimGrid = cat(1,auditory_grid,visual_grid);

%  fprintf('For calibration only!\n');
%  pause;
%  grid.stimGrid = [1000, 1000, 250, 500, 0, 0.01, 0.01, 80];

% sweep parameters
grid.postStimSilence = 0;
grid.repeatsPerCondition = 20;

% i=23
% stim = stimgen_makeToneWithAnalandDigTTL(expt, grid, ...
% grid.stimGrid(i,1), grid.stimGrid(i,2), grid.stimGrid(i,3), grid.stimGrid(i,4),grid.stimGrid(i,5), grid.stimGrid(i,6), grid.stimGrid(i,7), grid.stimGrid(i,8), grid.stimGrid(i,9), grid.stimGrid(i,10), grid.stimGrid(i,11));
% figure, imagesc(stim)
% 




