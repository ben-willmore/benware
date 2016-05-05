function grid = prepareGrid(grid, expt)

% add extra fields
grid.saveName = '';


if strcmpi(expt.stimDeviceType, 'none')
  % no stimulus device, so no stimulus checks
  grid.stimGenerationFunction = '';
  grid.stimGridTitles = {'SweepNum'};
  grid.nStimConditions = 10000;
  grid.repeatsPerCondition = 1;
  grid.nSweepsDesired = grid.nStimConditions;
  grid.stimGrid = (1:grid.nSweepsDesired)';
  grid.randomisedGrid = grid.stimGrid;
  grid.randomisedGridSetIdx = grid.stimGrid;
  
  if ~isfield(grid, 'saveWaveforms')
    grid.saveWaveforms = true;
  end

else
  % add extra field
  grid.nStimConditions = size(grid.stimGrid, 1);

  % check that the grid is valid
  verifyGridFields(grid);

  % check that stim files are there, if needed
  if isequal(grid.stimGenerationFunctionName, 'loadStereo')
    verifyStimFilesExist(grid, expt);
  end

  if isfield(grid, 'initFunction')
    grid = feval(grid.initFunction, grid, expt);
  end

  if ~isfield(grid, 'monoStim')
    grid.monoStim = false;
  end

  if ~isfield(grid, 'saveWaveforms')
    grid.saveWaveforms = true;
  end

  if ~isfield(grid, 'postStimSilence')
    grid.postStimSilence = 0;
  end

  global OLDCOMPENSATION
  if OLDCOMPENSATION
    error('== Using OLDCOMPENSATION=true is no longer possible');
    if ~isfield(grid, 'compensationFilters')
      grid.compensationFilters = [];
    end
  else
    % load default compensation filters specified in expt
    grid = loadDefaultCompensationFilters(grid, expt);
  
    if ~isfield(grid, 'applyCompensationFilters')
      grid.applyCompensationFilters = true;
    end
  end

  if isfield(grid, 'sweepLen') && isfield(grid, 'postStimSilence')
    error('grid:error', 'Grid specifies both sweepLen and postStimSilence');
  end

  % randomise grid
  if isfinite(grid.repeatsPerCondition)
    repeatsPerCondition = grid.repeatsPerCondition;
  else
    repeatsPerCondition = 10000;
  end

  idx = [];

  if isfield(grid, 'randomiseGrid') && ~grid.randomiseGrid
    fprintf('  * Not randomising grid!\n');
    for ii = 1:repeatsPerCondition
      idx = [idx 1:size(grid.stimGrid, 1)];
    end
  else
    for ii = 1:repeatsPerCondition
      idx = [idx randperm(size(grid.stimGrid, 1))];
    end
  end
  grid.randomisedGrid = grid.stimGrid(idx, :);
  grid.nSweepsDesired = size(grid.randomisedGrid, 1);

  [junk grid.randomisedGridSetIdx] = ...
    ismember(grid.randomisedGrid, grid.stimGrid, 'rows');

  % stimulus generation function handle
  grid.stimGenerationFunction = str2func(grid.stimGenerationFunctionName);

end

% verify that we have the right conditions from the user
verifyExpt(grid, expt);

% check for existence of data directory.
% If it does exist, use grid.saveName to store alternative name.
grid.saveName = verifySaveDir(grid, expt);

% save grid metadata
saveGridMetadata(grid, expt);
