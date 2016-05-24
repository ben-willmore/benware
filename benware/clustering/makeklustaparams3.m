function [paramsFile, probeFile, nSitesPerShank] = makeklustaparams3(expt, grid, exptdir, datafiles)

if ~exist('exptdir', 'var')
  exptdir = expt.dataDir;
end

if ~exist('datafiles', 'var')
  usebenwarefiles = true; % this probably doesn't work
else
  usebenwarefiles = false;
  if isstr(datafiles)
    datafiles = {datafiles};
  end
end
gridName = grid.name;

%%%%%
fprintf('Making probe adjacency map...');
probes = expt.probes;
layout = {};
type = {};

for ii = 1:length(probes)
  if strcmp(probes(ii).layout, 'Warp-16')
    layout{ii} = [16 1];
    type{ii} = 'linear';

  elseif probes(ii).layout(1)=='A'
    res = regexp(probes(ii).layout, 'A([0-9]+)x([0-9]+)', 'tokens');
    nShanks = eval(res{1}{1});
    nSites = eval(res{1}{2});
    layout{ii} = [nShanks nSites];
    if ~isempty(strfind(probes(ii).layout, 'Buzs')) || ~isempty(strfind(probes(ii).layout, 'Busz'))
      type{ii} = 'buzsaki';
    else
      type{ii} = 'linear';
    end
  else
    error('unknown probe layout -- talk to ben');
  end
end

probeFile = constructDataPath([exptdir filesep gridName '.probe'], grid, expt, 1);
makeadjacencygraph2(layout, type, probeFile);

nSitesPerShank = [];
for ii = 1:length(layout)
  nSitesPerShank = [nSitesPerShank repmat(layout{ii}(2), [1 layout{ii}(1)])];
end

fprintf('done\n');

%%%%%
fprintf('Making spikedetekt parameter file...');

% get current directory
S = dbstack('-completenames');
parts = strsplit(S(1).file, {'/' '\'});
clustering_dir = strjoin(parts(1:end-1), filesep);

params = '';
fid=fopen([clustering_dir filesep 'params.new.prm'], 'r');
while 1
  tline = fgets(fid);
  if ~ischar(tline), break, end
  params = [params tline];
end
fclose(fid);

% file list
if usebenwarefiles
  file_list = '[ ';
  for sweepIdx = 1:grid.nSweepsDesired
    filename = constructDataPath(expt.dataFilename, grid, expt, sweepIdx);
    file_list = [file_list '''' filename '''' ', '];
  end
  file_list = [file_list ' ]'];
else
  filelist = '[ ';
  for sweepIdx = 1:length(datafiles)
    datafile = datafiles{sweepIdx}
    filelist = [filelist '''' datafile '''' ', '];
  end
  file_list = [filelist ' ]'];
end
file_list

% insert parameters into file
params = regexprep(params, '%EXPERIMENT_NAME%', gridName);
params = regexprep(params, '%FILES_LIST%', file_list);
params = regexprep(params, '%PROBE_FILE%', [gridName '.probe']);
params = regexprep(params, '%SAMPLE_RATE%', sprintf('%0.6f', expt.dataDeviceSampleRate));
params = regexprep(params, '%N_CHANNELS%', sprintf('%d', expt.nChannels));

max_sites = min(8,max(nSitesPerShank));
max_poss = min(max_sites*8, 256);
params = regexprep(params, '%MASK_STARTS%', sprintf('%d', max_poss/2));
params = regexprep(params, '%MIN_CLUSTERS%', sprintf('%d', max_sites/2));
params = regexprep(params, '%MAX_CLUSTERS%', sprintf('%d', max_sites*2));
params = regexprep(params, '%MAX_POSS_CLUSTERS%', sprintf('%d', max_poss));

paramsFile = constructDataPath([exptdir filesep gridName '.params'], grid, expt, 1);
fid = fopen(paramsFile, 'w');
fprintf(fid, params);
fclose(fid);
fprintf('done\n');

