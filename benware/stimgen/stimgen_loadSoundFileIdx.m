function stim = stimgen_loadSoundFileIdx(expt, grid, stimIdx)
    %% stim = stimgen_loadSoundFileIdx(expt, grid, stimIdx)
    %%
    %% This function is used by the "directory of wav files" stimulus grids.
    %%
    %% This is a model for new-style (2016 onward) benware stimulus generation functions
    %%
    %% The stimulus generation function will be called (by prepareStimulus) as:
    %%   uncomp = stimgen_function(expt, grid, parameters{:})
    %% where 'parameters' is a row from grid.stimGrid, so the parameters are values
    %% of the stimulus parameters specified in grid.stimGridTitles.
    %%
    %% Stimulus generation functions must obey the following rules:
    %%
    %% 1. Must have a name that begins stimgen_
    %% 2. Accept parameters:
    %%      expt: standard benware expt structure (as loaded by loadexpt.m)
    %%      grid: standard benware grid structure (produced by grid_*.m)
    %%      varargin: a list of parameters, whose length matches
    %%            the length of grid.stimGridTitles
    %% 3. Produces a matrix containing uncalibrated sound, meeting these criteria:
    %%      A. The sample rate must match grid.sampleRate
    %%      B. The first dimension of this matrix must match expt.nStimChannels.
    %%      C. The values are measured in Pascals, so that a sound with an RMS of 1
    %%         corresponds to 1 Pascal RMS, or 94 dB SPL.
    %%
    %% The correct stimulus files are found by
    %% finding experiment parameters in the grid and expt structures, and
    %% using constructStimPath to replace % tokens with appropriate values
    %% (sweepNum, etc)

    %% get parameters
    sampleRate = round(grid.sampleRate);
    nChannels = expt.nStimChannels;

	filename = grid.stimFiles{stimIdx};

	%% get stimulus
	fprintf(['  * Getting stimulus from ' escapepath(filename) '...']);

    % load the stimulus
    if strcmp(filename(end-3:end), '.f32')
        uncalib = readf32(filename)';
        if isnan(uncalib);
            errorBeep('Failed to read file %s', filename);
        end

    elseif strcmp(filename(end-3:end), '.wav')
        [uncalib, sampleRateInFile] = audioread(filename); %NH change, 20/10/2016
%         [uncalib, sampleRateInFile] = wavread(filename); %NH change,
%         20/10/2016 - ST reverted to audioread - 31.03.17
        uncalib = uncalib';

        if round(sampleRateInFile)~=round(sampleRate)
            error(sprintf('Sample rate (%d Hz) in file doesn''t match grid (%d Hz)', ...
                          round(sampleRateInFile), round(sampleRate)));
        end
    end

    nChannelsInFile = size(uncalib, 1);

    if nChannelsInFile==nChannels
        stim = uncalib;
    elseif nChannelsInFile==1
        stim = repmat(uncalib, [nChannels 1]);
    else
        error(sprintf('Can''t map %d channels in stimulus file to %d stimulus channels', ...
              nChannelsInFile, nChannels));
    end

    fprintf('done\n');
