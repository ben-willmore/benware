function [stim, stimInfo, uncomp] = prepareStimulus(stimGenerationFunction, sweepNum, grid, expt)
% generate stimInfo (stimulus parameters) for a given sweep, and
% pass parameters to specified stimGenerationFunction which generates
% stimulus vectors.
% Finally, add stimLevelOffsetDB to the stimulus for absolute calibration

global OLDCOMPENSATION

if OLDCOMPENSATION
    error('Using OLDCOMPENSATION=true is no longer possible')

    stimInfo.stimGridTitles = grid.stimGridTitles;
    stimInfo.stimParameters = grid.randomisedGrid(sweepNum, :);

    parameters = num2cell(stimInfo.stimParameters);

    % generate stimulus vector/matrix
    stim = feval(stimGenerationFunction, expt, grid, grid.sampleRate, expt.nStimChannels, ...
                    grid.compensationFilters, parameters{:});

    % check number of channels is correct
    if size(stim, 1)~=expt.nStimChannels
        errorBeep('Stimulus function %s did not generate the correct number of channels (%d)', ...
                    func2str(stimGenerationFunction), expt.nStimChannels);
    end

    % apply relative and absolute compensation

    % apply level offset
    level_offset = grid.stimLevelOffsetDB;
    if length(level_offset)==1
        level_offset = repmat(level_offset, 1, size(stim, 1));
    end

    for chan = 1:size(stim, 1)
      stim(chan, :) = stim(chan, :) * 10^(level_offset(chan) / 20);
    end

else
    stimInfo.stimGridTitles = grid.stimGridTitles;
    stimInfo.stimParameters = grid.randomisedGrid(sweepNum, :);

    if strcmpi(expt.stimDeviceType, 'none')
      stim = [];
      return;
    end

    parameters = num2cell(stimInfo.stimParameters);

    % generate stimulus vector/matrix

    % Check whether this is new-style (2016 onward) stimulus generation function
    % If so, its name will begin 'stimgen_', and we will call it with new-style
    % reduced parameters.
    func_str = func2str(stimGenerationFunction);
    prefix = 'stimgen_';
    len = length(prefix);
    if length(func_str)>len && all(func_str(1:len)==prefix)
        % function is new-style
        uncomp = feval(stimGenerationFunction, expt, grid, parameters{:});

    else
        % function is old-style
        fprintf(sprintf('== ERROR: %s is an old-style stimulus generation function.\n', func_str));
        fprintf('== Switch to stimgen_* functions by updating your grid file!\n');
        fprintf('== E.G.: loadStereoFile          -> stimgen_loadSoundFile\n');
        fprintf('==       makeCalibtone           -> stimgen_makeTone\n');
        fprintf('==       makeCSDprobe            -> stimgen_CSDProbe\n');
        fprintf('==       makeBilateralNose       -> stimgen_bilateralNoise\n');
        fprintf('==       loadMonoFileWithLight   -> stimgen_loadSoundFileWithLight\n');
        fprintf('==       makeCSDprobeWithLight   -> stimgen_CSDProbeWithLight\n');
        error('Fix these before continuing!')
        uncomp = feval(stimGenerationFunction, expt, grid, grid.sampleRate, expt.nStimChannels, ...
                       grid.compensationFilters, parameters{:});
    end

    % check number of channels is correct
    if size(uncomp, 1)~=expt.nStimChannels
        errorBeep('Stimulus function %s did not generate the correct number of channels (%d)', ...
                    func2str(stimGenerationFunction), expt.nStimChannels);
    end

    if isfield(grid, 'levelOffsetDB')
        fprintf('= levelOffsetDB: Boosting level by %d dB\n', grid.levelOffsetDB);
        amplitudeMultiplier = 10^(grid.levelOffsetDB/20);
        nAudioChannels = length(grid.compensationFilters);
        uncomp(1:nAudioChannels,:) = uncomp(1:nAudioChannels,:) * amplitudeMultiplier;
    end

    % at this point, stim is equal to the ideal stimulus, i.e.
    % it has not been processed with the headphone compensation or the
    % absolute level compensation.
    % So, the stimulus can be checked here (e.g. the RMS level)

    % check maximum level of stimulus in 5ms increments
    std_n = round(.005*grid.sampleRate);
    l = size(uncomp, 2);
    total_n = floor(l/std_n)*std_n;
    sd = nan(1, size(uncomp, 1));
    for ii = 1:size(uncomp, 1)
      r = reshape(uncomp(ii,1:total_n), [std_n total_n/std_n]);
      sd(ii) = max(std(r));
    end
    max_level = 20*log10(sd)+94;

    fprintf(['  * maximum levels: [ ' num2str(max_level, '%0.2f '), ' ] dB\n']);

    if max_level>110
        errorBeep('== Warning: maximum sound level is >110dB');
    end


    % apply relative and absolute compensation
    if grid.applyCompensationFilters

        % use the maximum value of the compensation filter to define the offset
        filterOffset = nan(1, length(expt.nStimChannels));
        for chan = 1:length(expt.nStimChannels)
            filterOffset(chan) = find(grid.compensationFilters{chan}==max(grid.compensationFilters{chan}), 1);
        end

        if any(filterOffset ~= 1)
            fprintf('= Warning: Compensation filters do not appear to be minimum phase; offset is not 1');
        end

        if any(filterOffset(chan) ~= filterOffset(1))
            fprintf('= Warning: Compensation filters have different offsets in different channels; using filterOffset(1) only');
        end

        filterOffset = filterOffset(1);

        stim = {};
        for chan = 1:expt.nStimChannels
            if chan<=length(grid.compensationFilters)
                % then this is assumed to be a compensatable audio channel
                % (not a pure voltage for driving the LED for example)
                fprintf('= Compensating channel %d for frequency response\n', chan);
                stim_long = conv(grid.compensationFilters{chan}, uncomp(chan,:), 'full');
                stim{chan} = stim_long(filterOffset:end);

                if isfield(grid, 'legacyLevelOffsetDB')
                    if length(grid.legacyLevelOffsetDB)==1
                        level_offset = grid.legacyLevelOffsetDB(1);
                    else
                        level_offset = grid.legacyLevelOffsetDB(chan);
                    end
                    stim{chan} = stim{chan} * 10^(level_offset / 20);
                    fprintf('= LegacyLevelOffset: boosting level by %d dB\n', level_offset);

                end
            else
               % pure voltage channels may need some padding at the end
               stim{chan} = zeros(1, max(cellfun(@(x) length(x),stim)));
               stim{chan}(1:length(uncomp(chan,:))) = uncomp(chan,:);
            end
        end
        stim = cat(1, stim{:});
    else
        stim = uncomp;
    end

end
