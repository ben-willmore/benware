function grid = getGridForStimDir(stimDir)
%% grid = getGridForStimDir(stimDir)
%%
%% Read a directory of wav/f32 files and generate a benware
%% grid to play them.
%% If the directory contains wav files, the sample rate will be
%% read from one of the files. If not, you must set the sample rate
%% in parameters.txt, e.g.:
%%
%% sampleRate = 48828
%%

grid = struct;

% go through all files in the directory and make a list of the wav/f32
% files. If there are .wav files, record the filename of one of them
% so we can read its samples rate.
files = dir(stimDir);

stimFiles = [];
sampleWavFile = '';
for ii = 1:length(files)
  if ~files(ii).isdir
    if strcmp(files(ii).name(end-3:end), '.wav')
      stimFiles{end+1} = [stimDir filesep files(ii).name];
      sampleWavFile = [stimDir filesep files(ii).name];

    elseif strcmp(files(ii).name(end-3:end), '.f32')
      stimFiles{end+1} = [stimDir filesep files(ii).name];

    end
  end
end

if isempty(stimFiles)
  % then this is an invalid directory
  errorBeep(sprintf('No .wav or .f32 files found in %s', stimDir));
end

if length(sampleWavFile)>0
  % then we have a file whose sample rate we can read in order to 
  % set grid.sampleRate.
  [y, fs] = audioread(stimFiles{1}); % NH change 28/10/2016
% [y, fs] = wavread(stimFiles{1}); % NH change 28/10/2016

  sampleRates =   [0.125 0.25 0.5 1 2 4 8]*tdt50k;
  sampleRateIdx = find((abs(fs-sampleRates)<1));

  if isempty(sampleRateIdx)
    errorBeep(sprintf('Sample rate of %s is not a TDT supported sample rate', stimFiles{1}));
  end

  wavSampleRate = sampleRates(sampleRateIdx);

end

grid.stimGenerationFunctionName = 'stimgen_loadSoundFileIdx';
grid.stimFiles = stimFiles;
grid.stimGridTitles = {'Stimulus file (index into grid.stimFiles)'};
grid.stimGrid = (1:length(stimFiles))';

paramsFile = [stimDir filesep 'parameters.txt'];
if exist(paramsFile, 'file')
    f = fopen(paramsFile);

    data = fgetl(f);
    while ischar(data)
        r=regexp(data,' |=|:','split');
        name = r{1};
        value = r{end};

        try
           value = eval(value);
        catch
            errorBeep(sprintf('Non-numerical value or formatting error in %s', paramsFile));
        end
        
        if length(r)>2 && strcmpi(name(1:3), 'rep')
          grid.repeatsPerCondition = value;
        elseif length(r)>2 && strcmpi(name, 'leveloffsetdb')
          grid.levelOffsetDB = value;
        else
          grid = setfield(grid, name, value);
        end
        data = fgetl(f);
    end
end

if ~isfield(grid, 'repeatsPerCondition')
    grid.repeatsPerCondition = 20;
end

if exist('wavSampleRate', 'var')
  if isfield(grid, 'sampleRate') && floor(grid.sampleRate)~=floor(wavSampleRate)
    errorBeep(sprintf('The sample rates in %s and parameters.txt are not the same!', sampleWavFile));
  elseif ~isfield(grid, 'sampleRate')
    grid.sampleRate = wavSampleRate;
  end
end

if ~isfield(grid, 'sampleRate')
  errorBeep(sprintf('No sample rate specified!'));
end

