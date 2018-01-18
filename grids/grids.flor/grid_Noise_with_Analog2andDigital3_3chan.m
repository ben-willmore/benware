function grid = grid_Noise_with_Analog2andDigital3_3chan()

% controlling the sound presentation
grid.sampleRate = 24414.0625*8;  % ~200kHz
grid.stimGenerationFunctionName = 'stimgen_makeNoiseWithAnalandDigTTL';

% stimulus grid structure
grid.stimGridTitles = {'Stimulus Length (ms)','StimID' ,'Noise Delay (ms)', 'Noise Duration (ms)', 'Analog Chan2 voltage (V)', 'Analog Chan2 delay (ms)', 'Analog Chan2 Duration (ms)', 'Digital Chan3 voltage (V)', 'Digital Chan3 delay (ms)', 'Digital Chan3 Duration (ms)', 'Level (dB)'};
Digvoltages = [0 5];
Analvoltages = [0 9];
level=[80];
tone_delay_aud = [100]
tone_delay_light = [100];

stim_dur=50;

retinotopic_positions=[1:12];
%   freqs = logspace(log10(1250), log10(1000*2^6),26);
%   logspace(log10(1250), log10(1000*2^6.3220),25) from [1.250 to 80]

% Auditory conditions
auditory_grid=createPermutationGrid(800,0, tone_delay_aud, stim_dur, Analvoltages(1), 100, 50, Digvoltages(2), 100, 50, level);% 550ms length ()100ms duration tones) %normally sweep length 550
%Create visual condition
visual_grid=createPermutationGrid(800, retinotopic_positions, tone_delay_light, stim_dur, Analvoltages(2), 100, 50, Digvoltages(2), 100, 50, -50);
visual_Aud_grid=createPermutationGrid(800, retinotopic_positions(end)+retinotopic_positions, tone_delay_light, 50, Analvoltages(2), 100, 50, Digvoltages(2), 100, 50, level);


grid.stimGrid = cat(1,cat(1,auditory_grid,visual_grid),visual_Aud_grid);
repeatsPerCondition=20;
idx = [];

for ii = 1:repeatsPerCondition
    idx = [idx randperm(size(grid.stimGrid, 1))];
end
grid.randomisedGrid = grid.stimGrid(idx, :);
grid.nSweepsDesired = size(grid.randomisedGrid, 1);
grid.stimGrid=grid.stimGrid(idx, :);

%  fprintf('For calibration only!\n');
%  pause;
%  grid.stimGrid = [1000, 1000, 250, 500, 0, 0.01, 0.01, 80];

% sweep parameters
grid.postStimSilence = 0;
grid.repeatsPerCondition = 1;
grid.randomiseGrid = false;


% i=23
% stim = stimgen_makeNoiseWithAnalandDigTTL(expt, grid, ...
% grid.stimGrid(i,1), grid.stimGrid(i,2), grid.stimGrid(i,3), grid.stimGrid(i,4),grid.stimGrid(i,5), grid.stimGrid(i,6), grid.stimGrid(i,7), grid.stimGrid(i,8), grid.stimGrid(i,9), grid.stimGrid(i,10), grid.stimGrid(i,11));
% figure, imagesc(stim)
% 




