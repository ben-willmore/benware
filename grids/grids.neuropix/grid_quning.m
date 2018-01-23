function grid = grid_quning()
    %% stim = grid_quning()
    %%
    %% This is a model for new-style (2016 onward) benware stimulus grid functions
    %%
    %% The grid function will be called (by prepareGrid) as:
    %%   grid = grid_function()
    %% 
    %% Grid functions must obey the following rules:
    %% 
    %% 1. The name must be 'grid_', and the name at the top of this file must
    %%      match the filename.
    %% 2. Must return a grid structure containing the fields:
    %%      grid.sampleRate: stimulus sample rate
    %%      grid.stimGenerationFunctionName: name of a stimulus generation function
    %%      grid.stimGridTitles: a cell containing the names of stimulus parameters
    %%      grid.stimulusGrid: a matrix specifying values of the parameters in
    %%           grid.stimGridTitles, one stimulus per row. The number of columns must
    %%           match the length of grid.stimGridTitles
    %%      grid.repeatsPerCondition: integer specifying how many times the 
    %%           grid will be repeated
    %%
    %%  The stimulus generation function will be called by BenWare to generate
    %%  each stimulus as:
    %%   uncomp = stimgen_function(expt, grid, parameters{:})
    %%  See stimgen_MakeTone.m and stimgen_loadSoundFile.m for
    
    %% required parameters
    grid.sampleRate = tdt100k;
    grid.stimGenerationFunctionName = 'stimgen_makeTone';
    
    % stimulus grid structure
    grid.stimGridTitles = {'Frequency', 'Duration', 'Level'};

    % frequencies and levels
    freqs = logspace(log10(500), log10(40000), 15);
    levels = 40:10:80;
    tonedur = 100;

    grid.stimGrid = createPermutationGrid(freqs, tonedur, levels);

    % sweep parameters
    grid.postStimSilence = 2;%.4; % in seconds %MR
    grid.repeatsPerCondition = 15;

    % optional parameters
    % grid.randomiseGrid = true;
    % grid.legacyLevelOffsetDB = 0; % avoid using this
