function data = getkilospikes(dataDir)
% function data = getsortedspikes(dataDir, allWaveforms, unsortedSpikes)
%
% get spike data that has been sorted with kilosort / phy
%
% dataDir: benware directory

setpath;

data = struct;
theFileSep = filesep;
data.gridInfoFile = [dataDir theFileSep 'gridInfo.mat'];

if ispc
  % kludge
  theFileSep = '/';
  data.gridInfoFile(data.gridInfoFile=='\') = '/';
end

% load information about the experiment from BenWare
l = load(data.gridInfoFile);
data.grid = l.grid;
data.expt = l.expt;

% get info about sweep lengths
m = load([dataDir theFileSep 'sweep_info.mat']);
sweepLens = m.sweepLens;

% load spike data
data.raw.spikeTimesInSamples = readNPY([dataDir theFileSep 'spike_times.npy']);
data.raw.spikeClusters = readNPY([dataDir theFileSep 'spike_clusters.npy']);

spikesByCluster = {};
data.spikeTimesBySweep = {};
for clusterIdx = 1:max(data.raw.spikeClusters)
  spikesByCluster{clusterIdx} = data.raw.spikeTimesInSamples(data.raw.spikeClusters==clusterIdx);
  data.spikeTimesBySweep{clusterIdx} = spikesamples2sweeptimes(l.expt.dataDeviceSampleRate, spikesByCluster{clusterIdx}, sweepLens);
end
