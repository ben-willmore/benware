function saveData(data, grid, expt, sweepNum)
  % saveData(data, grid, expt, sweepNum)

fprintf(['Saving data']);

% ensure target directory exists
dirTemplate = [grid.dataDir grid.dataFilename];
fullPath = constructDataPath(dirTemplate, grid, expt, sweepNum);
dirName = split_path(fullPath);
mkdir_nowarning(dirName);

% save each channel in a separate f32 file
for chanNum = 1:L(data)
    fprintf('.');
    filename = constructDataPath(dirTemplate, grid, expt, sweepNum, chanNum);
    h = fopen(filename, 'w');
    fwrite(h, data{chanNum}, 'float32');
    fclose(h);
end

fprintf(['done after ' num2str(toc) ' sec.\n']);
