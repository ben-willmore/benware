function hardware = prepareHardware(hardware, expt, grid)
% hardware = prepareHardware(hardware, expt, grid)
%
% Given expt and grid structures, set the hardware up appropriately.
% 
% hardware: A previously initialised hardware structure, or []
% expt, grid: Standard benWare structures
% 
% Returns:
% hardware.zBus -- zBus handle
% hardware.stimDevice -- stimulus device handle
% hardware.stimSampleRate -- stimulus device sample rate
% hardware.dataDevice -- data device handle
% hardware.dataSampleRate -- data device sample rate


if isempty(hardware)
  hardware = struct();
end

% Set up stim device
% we want to be able to have mono or stereo stimulus device because the amount of buffer space on the 
% TDT devices is limited. We don't want to share the buffer with a non-existant second channel.

if strcmpi(expt.stimDeviceType, 'none')
  hardware.stimDevice = [];
else
  if ~isfield(hardware, 'stimDevice')
  	fprintf('  * Initialising stimulus device...\n');
    hardware.stimDevice = feval(expt.stimDeviceType, ...
  								expt.stimDeviceInfo, grid.sampleRate, expt.nStimChannels);
  else
      if ~strcmp(class(hardware.stimDevice), expt.stimDeviceType)
          ok = false;
          message = sprintf('wrong stimulus device type (%s rather than %s)', ...
                      class(hardware.stimDevice), expt.stimDeviceType);
      else
          [ok, message] = hardware.stimDevice.checkDevice(...
                      	expt.stimDeviceInfo, grid.sampleRate, expt.nStimChannels);
      end

      if ok
          fprintf('  * Stimulus device already initialised\n');
      else
          fprintf('  * Reinitialising stimulus device (%s)...\n', message);
          hardware.stimDevice = feval(expt.stimDeviceType, ...
  								expt.stimDeviceInfo, grid.sampleRate, expt.nStimChannels);
      end
  end
end

% set up data device
if strcmpi(expt.dataDeviceType, 'none')
    hardware.dataDevice = [];
else
    if ~isfield(hardware, 'dataDevice')
        fprintf('  * Initialising data device...\n');
        hardware.dataDevice = feval(expt.dataDeviceType, ...
                                    expt.dataDeviceInfo, expt.dataDeviceSampleRate, ...
                                    expt.channelMapping, hardware.stimDevice);
    else
        if ~strcmp(class(hardware.dataDevice), expt.dataDeviceType)
            ok = false;
            message = sprintf('wrong data device type (%s rather than %s)', ...
                class(hardware.dataDevice), expt.dataDeviceType);
        else
            [ok, message] = hardware.dataDevice.checkDevice(...
                    expt.dataDeviceInfo, expt.dataDeviceSampleRate, expt.channelMapping);
        end

        if ok
            fprintf('  * Data device already initialised\n');
        else
            fprintf('  * Reinitialising data device (%s)...\n', message);
            hardware.dataDevice = feval(expt.dataDeviceType, ...
                                    expt.dataDeviceInfo, expt.dataDeviceSampleRate, ...
                                    expt.channelMapping, hardware.stimDevice);
        end
    end
end

% set up trigger
if strcmpi(expt.triggerDevice, 'stimDevice')
    hardware.triggerDevice = hardware.stimDevice;
elseif strcmpi(expt.triggerDevice, 'zBus')
    if ~isfield(hardware, 'triggerDevice') || ...
    			~strcmp(class(hardware.triggerDevice), expt.triggerDevice)
        hardware.triggerDevice = zBus();
    end
elseif strcmpi(expt.triggerDevice, 'stimAndDataDevices')
  hardware.triggerDevice = stimAndDataTrigger(hardware.stimDevice, hardware.dataDevice);
else
    errorBeep('Unknown trigger type');
end

fprintf('  * Post-initialisation pause...');
pause(2);
fprintf('done.\n');

% check sample rates are identical to those requested
if ~strcmpi(expt.stimDeviceType, 'none')
  if floor(hardware.stimDevice.sampleRate) ~= floor(grid.sampleRate)
    errorBeep('stimDevice sample rate is wrong');
  end
end

if ~isempty(hardware.dataDevice) && (hardware.dataDevice.sampleRate ~= expt.dataDeviceSampleRate)
  errorBeep('dataDevice sample rate is wrong');
end
