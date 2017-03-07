%% This script generates sounds in exactly the same way as benware. 
% Optionally, it plays the sounds. It also records them in a sweeps structure.
% sweeps contains:
% stim -- the sound after compensation filter have been applied
% stimInfo -- stimulus parameters
% uncalib -- the uncompensated sound
% 
% You can also inspect the 'expt' and 'grid' structures after this script
% has run.

% if true, play the entire randomised stimulus set specified by grid.randomisedGrid
% if false, just play each stimulus once as specified by grid.stimGrid
play_complete_grid = false;

if ispc
  % assume we are on the rig machine for which expt.username is configured

  % if true, play the sounds using sound()
  playsounds = false;

  % multiplier to adjust sounds by to make them audible
  level_adjust = 10;

  % don't set replace_path or stimulus_dir, on the assumption that these 
  % are already correct.

else
  % assume we are not on a rig machine, and so we'll play sounds through the
  % computer speaker, and use modified paths

  % if true, play the sounds using sound()
  playsounds = true;

  % multiplier to adjust sounds by to make them audible
  level_adjust = 10;

  % this path will be replaced in all fields of the grid where it is found
  replace_path = {'E:\auditory-objects\sounds-uncalib', '~/scratch/benware.stimuli'};

  % stimulus directory for "directory of wav file" stimuli
  stimulus_dir = './stimulusdir';

end

% no more parameters after this

% this prevents benware from creating a new directory to save data in (see prepareGrid.m)
global TEST
TEST = false; 

loadexpt;
% use different stimulus_dir than the one in expt
if exist('stimulus_dir', 'var')
  expt.stimulusDirectory = stimulus_dir;
end

grid = chooseGrid(expt.stimulusDirectory);
grid = prepareGrid(grid, expt);

% replace path
if exist('replace_path', 'var')
  from = replace_path{1};
  to = fix_slashes(replace_path{2});
  fprintf('Replacing %s with %s in grid...\n', from, to);
  from = lower(fix_slashes(from));
  len = length(from);

  fields = fieldnames(grid);
  for ii = 1:numel(fields)
    fieldname = fields{ii};
    fieldvalue = grid.(fields{ii});
    if isstr(fieldvalue) && length(fieldvalue)>=len && all(fix_slashes(fieldvalue(1:len))==from)
      fieldvalue = fix_slashes([to fieldvalue(len+1:end)]);
      fprintf('--> grid.%s is now %s\n', fieldname, fieldvalue);
      grid.(fields{ii}) = fieldvalue;
    end
  end
end

if play_complete_grid == false
  grid.randomisedGrid = grid.stimGrid;
  grid.nSweepsDesired = size(grid.stimGrid, 1);
end

fprintf('\n\n= Expt:')
expt

fprintf('\n\n= Grid:')
grid

sweeps = struct;
for sweepNum = 1:grid.nSweepsDesired
  fprintf('= Sweep %d\n', sweepNum)
  [sweeps(sweepNum).stim, sweeps(sweepNum).stimInfo, sweeps(sweepNum).uncalib] = ...
      prepareStimulus(grid.stimGenerationFunction, sweepNum, grid, expt);

  if playsounds
    sound(sweeps(sweepNum).uncalib*level_adjust, grid.sampleRate);
    pause(size(sweeps(sweepNum).stim, 2)/grid.sampleRate);
  end
end
