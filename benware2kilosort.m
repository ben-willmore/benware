function clusterspikes(parentDir, skipFailures, overwrite)
% function clusterspikes(parentDir, skipFailures, recluster)
%
% Cluster benware data.
%
% parentDir: benware dir, or directory of benware dirs, or
%   wildcard matching multiple benware dirs
%
% skipFailures: Attempt to continue with other directories
%   if one directory failes
%
% recluster: Rerun klusta even if clustering has already beend
%   done. Useful if you have changed parameters in the *.params
%   file

setpath;

if ismac
  prefix = ''; % no longer needed
else
  prefix = '';
end

if ~exist('skipFailures', 'var')
  skipFailures = false;
end

if ~exist('overwrite', 'var')
  overwrite = false;
end

if overwrite
  overwrite_str = '--overwrite';
else
  overwrite_str = '';
end

if ispc
  filesep = '\\'; % yet another Matlab WTF... :/ - needed avoid invalid escape sequences in sprintf
else
  filesep = '/';
end

setpath;

if ~exist(parentDir, 'dir')
  error(sprintf('%s not found'), parentDir);
end

try
  d0 = {};
  d0 = getfilesmatching([parentDir '/gridInfo.mat']);
catch
  %
end

try
  d1 = {};
  d1 = getfilesmatching([parentDir '/*/gridInfo.mat']);
catch
  %
end

try
  d2 = {};
  d2 = getfilesmatching([parentDir '/*/*/gridInfo.mat']);
catch
  %
end

dirs = cat(1, d0, d1, d2);
dirs = cellfun(@(x) x(1:end-length('/gridInfo.mat')), dirs, 'uni', false);
if isempty(dirs)
  fprintf('== No gridInfo.mat files found\n');
  return;
end

fprintf('== Found:\n');
for dirIdx = 1:length(dirs)
  fprintf(' %s\n', dirs{dirIdx});
end
fprintf('\n');

for dirIdx = 1:length(dirs)
  dir = dirs{dirIdx};

  try
    fprintf('== Processing %s\n', dir);

    % convert old benware to new (interleaved) benware format
    if exist([dir filesep 'raw.f32'], 'dir')
      if exist([dir filesep 'update_done.txt'], 'file')
        fprintf('update_done.txt exists, not updating data\n');
      else
        benware_old2new(dir);
        fid = fopen([dir filesep 'update_done.txt'], 'w');
        fprintf(fid,'done\n');
        fclose(fid);
      end
    end

    % convert to a single i16 file which is readable by spikdetekt
    if exist([dir filesep 'konversion_done.txt'], 'file')
      fprintf('konversion_done.txt exists, not converting data\n');
    else
      benware2spikedetekt3(dir);
      fid = fopen([dir filesep 'konversion_done.txt'], 'w');
      fprintf(fid,'done\n');
      fclose(fid);
    end

  end % try

end % for
