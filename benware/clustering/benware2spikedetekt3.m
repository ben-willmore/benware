function [paramsFile, nSitesPerShank] = benware2spikedetekt3(dataDir)
% benware2spikedetekt3
% this is for new-style benware data, using interleaved files
% it's identical to benware2spikedetekt2, except that it uses makeklustaparams3
% to make a params file which is compatible with newer klusta* from May 2016

if ispc
  filesep = '\\'; % yet another Matlab WTF... :/ - needed avoid invalid escape sequences in sprintf
else
  filesep = '/';
end

if ~exist(dataDir, 'dir')
  error('Directory %s does not exist\n', dataDir);
end

if ~exist([dataDir filesep 'gridInfo.mat'], 'file')
  error('%s is not a benware data directory\n', dataDir);
end


fprintf('Converting %s... to i16 format:\n', dataDir);
l = load([dataDir filesep 'gridInfo.mat']);
nChannels = length(l.expt.channelMapping);

gridName = l.grid.name;
dataPath = [dataDir filesep l.expt.dataFilename];

% get multiplier for int16 format
fprintf('Getting range of data');
sweepIdx = 1;
maxabs = -Inf;
foundempty = false;

while exist(constructDataPath(dataPath, l.grid, l.expt, sweepIdx, nChannels))
  tmp = f32read(constructDataPath(dataPath, l.grid, l.expt, sweepIdx, nan));

  if foundempty
    % then a data file was empty, and it wasn't the last
    fprintf('Empty f32 file!\n');
    keyboard
  end

  if isempty(tmp)
    % if data file is empty, it must be the last one, or something is wrong
    foundempty = true;
    fprintf('o');
  else
    maxabs = max(maxabs, max(abs(tmp(:))));
    fprintf('.');
  end

  if round(sweepIdx/70)==(sweepIdx/70)
    fprintf('\n');
  end

  sweepIdx = sweepIdx+1;
end

mult = 32767/maxabs/2; % seems to be needed to prevent clipping

fprintf('done\n');

fprintf('Converting sweeps');

sweepLens = [];
sweepIdx = 1;

shortFilename = [gridName '.sweeps.i16.dat'];
filename = [dataDir filesep shortFilename];

while exist(constructDataPath(dataPath, l.grid, l.expt, sweepIdx, nan))
  fprintf('.');
  if round(sweepIdx/70)==(sweepIdx/70)
    fprintf('\n');
  end

  sweepData = f32read(constructDataPath(dataPath, l.grid, l.expt, sweepIdx, nan));
  assert(mod(length(sweepData)/nChannels,1)==0)
  sweepLens(end+1) = length(sweepData)/nChannels;

  if isempty(sweepData)
    break;
  end

  if sweepIdx==1
    int16write(sweepData, filename, mult);
  else
    % append
    int16write(sweepData, filename, mult, true);
  end

  sweepIdx = sweepIdx+1;

end

nFiles = 1; % number of data files

[paramsFile, probeFile, nSitesPerShank] = makeklustaparams3(l.expt, l.grid, dataDir, shortFilename);

datafile = shortFilename;
save([dataDir filesep 'sweep_info.mat'], 'datafile', 'sweepLens', 'paramsFile', 'probeFile', 'nSitesPerShank');
