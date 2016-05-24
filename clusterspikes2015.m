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

  if true % length(getfilesmatching([dir filesep '*.dat']))
    % for klusta* 0.3.0
    % old (non-interleaved) benware data will be converted to interleaved format

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
        benware2spikedetekt2(dir);
        fid = fopen([dir filesep 'konversion_done.txt'], 'w');
        fprintf(fid,'done\n');
        fclose(fid);
      end

      % run spikedetekt and klustakwik, using 'klusta'
      if exist([dir filesep 'klustering_done.txt'], 'file') && ~overwrite
        fprintf('klustering_done.txt exists, skipping\n');
        continue;
      else
        overwrite_str = '--overwrite';
      end

      if ispc
        [status,windows_path] = system('PATH'); % we need to get rid of Matlab in our PATH as otherwise scipy will load wrong DLLs from Matlab installation
        pos = strfind(windows_path,';');
        cmd = [tempdir 'benware.bat'];
        fid = fopen(cmd,'w');
        fprintf(fid,'cd %s\n',dir);
        fprintf(fid,'set PATH=%s\n',windows_path(pos(1)+1:end));
        fprintf(fid,'%s\\klustakwik\\klusta.PCWIN.exe %s *.params', overwrite_str);
        fclose(fid);
      elseif ismac
        cmd = sprintf([prefix 'cd ' escapespaces(dir) '; DYLD_LIBRARY_PATH='''' klusta ' overwrite_str ' *.params']);
      else % linux
        cmd = sprintf([prefix 'cd ' escapespaces(dir) '; klusta ' overwrite_str ' *.params']);
      end
      fprintf('= Clustering by running command:\n %s\n', cmd);
      res = system(cmd);
      if res>0
        error('Command failed');
      end

      fid = fopen([dir filesep 'klustering_done.txt'], 'w');
      fprintf(fid,'done\n');
      fclose(fid);

    catch exc
      if ~skipFailures
        rethrow(exc);
      end
    end

  else
    % This no longer gets executed! old-style benware data is updated to new-style instead
    % old-style
    try
      dir = dirs{dirIdx};
      fprintf('== Processing %s\n', dir);

      if exist([dir '/raw.f32'])==0
        fprintf('%s does not exist (probably because no waveforms were saved); skipping spike detection\n', [dir '/raw.f32']);
        continue
      end


      % check if data has been converted; if not, convert it
      sweepInfoFile = [dir filesep 'spikedetekt/sweep_info.mat'];
      if exist(sweepInfoFile, 'file')
        fprintf('Found %s; skipping conversion\n', sweepInfoFile);
        l = load(sweepInfoFile);
        paramsFile = l.paramsFile;
        nSitesPerShank = l.nSitesPerShank;

      else
        [paramsFile, nSitesPerShank] = benware2spikedetekt(dirs{dirIdx});
      end
      nShanks = length(nSitesPerShank);

      % check if spikes have been detected; if not, detect them
      spikedetektDir = getLastSpikedetektDir(dir);

      if ~isempty(spikedetektDir) && exist([spikedetektDir filesep 'detektion_done.txt'], 'file')
        fprintf('Found complete spikedetekt data in %s; skipping spike detection\n', spikedetektDir);

      else
        if ispc
          [status,windows_path] = system('PATH'); % we need to get rid of Matlab in our PATH as otherwise scipy will load wrong DLLs from Matlab installation
          pos = strfind(windows_path,';');
          cmd = [tempdir 'benware.bat'];
          fid = fopen(cmd,'w');
          fprintf(fid,'cd %s/spikedetekt\n',dir);
          fprintf(fid,'set PATH=%s\n',windows_path(pos(1)+1:end));
          fprintf(fid,'python %s/klustakwik/detektspikes.py %s\n',pwd,paramsFile);
          fclose(fid);
        else
          cmd = ['cd ' escapespaces([dir filesep 'spikedetekt']) '; ' ...
               'LD_LIBRARY_PATH='''' DYLD_LIBRARY_PATH='''' DYLD_FRAMEWORK_PATH='''' ' ...
               'PATH=~/Library/Enthought/Canopy_64bit/User/bin/:Library/Enthought/Canopy_32bit/User/bin/:$PATH ' ...
               'python ' pwd '/klustakwik/detektspikes.py ' paramsFile];
        end

        fprintf('= Detecting spikes by running command:\n %s\n', cmd);
        res = system(cmd); % TODO: python / spikedetekt will crash if there is not enough diskspace - handle this

        if res>0
          error('Command failed');
        end

        spikedetektDir = getLastSpikedetektDir(dir);

        fid = fopen(sprintf('%s/detektion_done.txt',spikedetektDir),'w');
        fprintf(fid,'done\n');
        fclose(fid);

      end

      for shankIdx = 1:nShanks
        if exist(sprintf([spikedetektDir filesep 'klustering_done.%d.txt'], shankIdx), 'file')
          fprintf('= Shank %d already clustered, skipping\n', shankIdx);
        else
          f = getfilesmatching(sprintf([spikedetektDir filesep '*.clu.%d'], shankIdx));
          tmp = cluread(f{1});
          if isempty(tmp)
            fprintf('= No clusters for shank %d, skipping\n', shankIdx);
            continue;
          end
          if nSitesPerShank(shankIdx)==1
            parameters = ['-MinClusters 5 -MaxClusters 10 -MaxPossibleClusters 20 -PenaltyK 1 -PenaltyKLogN 0 -DropLastNFeatures 1'];
          else
            parameters = ['-UseDistributional 1 -MaxPossibleClusters ' num2str(nSitesPerShank(shankIdx)) ' -MaskStarts ' num2str(ceil(nSitesPerShank(shankIdx)/2)) ' -PenaltyK 1 -PenaltyKLogN 0 -DropLastNFeatures 1'];
          end
          if ispc
            [status,windows_path] = system('PATH'); % we need to get rid of Matlab in our PATH as otherwise scipy will load wrong DLLs from Matlab installation
            pos = strfind(windows_path,';');
            cmd = [tempdir 'benware.bat'];
            fid = fopen(cmd,'w');
            fprintf(fid,'cd %s\n',spikedetektDir);
            fprintf(fid,'set PATH=%s\n',windows_path(pos(1)+1:end));
            fprintf(fid,'%s\\klustakwik\\klustakwik.PCWIN.exe %s %d %s\n',pwd,paramsFile(1:end-7),shankIdx,parameters); % use 64 Bit version from https://github.com/klusta-team/klustakwik
            fclose(fid);
          else
            cmd = sprintf(['cd ' escapespaces(spikedetektDir) '; ' ...
                         'LD_LIBRARY_PATH='''' DYLD_LIBRARY_PATH='''' DYLD_FRAMEWORK_PATH='''' ' pwd '/klustakwik/KlustaKwik.' computer ' ' paramsFile(1:end-7) ' %d ' parameters], shankIdx);
          end
          fprintf('= Clustering shank %d by running command:\n %s\n', shankIdx, cmd);
          res = system(cmd);
          if res>0
            error('Command failed');
          end
          if ispc
            fid = fopen(sprintf('%s/klustering_done.%d.txt',spikedetektDir,shankIdx),'w');
            fprintf(fid,'done\n');
            fclose(fid);
          else
            cmd = sprintf(['echo done > ' spikedetektDir filesep 'klustering_done.%d.txt'], shankIdx);
            system(cmd);
          end
        end
      end

      % move to shank-specific directories
      for shankIdx = 1:nShanks
        shankDir = sprintf([dir filesep 'shank.%d'], shankIdx);
        if ~exist(shankDir, 'dir')
          mkdir(shankDir);
        end
        copyfile(sprintf([spikedetektDir filesep '*.%d'], shankIdx), shankDir);
        copyfile([dir filesep 'spikedetekt' filesep '*.probe'], shankDir);
        copyfile([spikedetektDir filesep '*.xml'], shankDir);
      end
    catch exc
      if ~skipFailures
        rethrow(exc);
      end
    end
  end
end
