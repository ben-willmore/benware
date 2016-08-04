classdef tdtStimDevice < tdtDevice
	properties
		rcxSetups = [];
        currentStim = [];
        nextStim = [];
        nextStimIndex = nan;
	end

	methods

		function obj = tdtStimDevice(deviceInfo, sampleRate, nChannels)
			% initialise the class itself
			obj.rcxSetups(1).rcxFilename = 'benware/tdt/%s-monoplay.rcx';
			obj.rcxSetups(1).versionTagName = [deviceInfo.name 'MonoPlayVer'];
			obj.rcxSetups(1).versionTagValue = 3;
			obj.rcxSetups(2).rcxFilename = 'benware/tdt/%s-stereoplay.rcx';
			obj.rcxSetups(2).versionTagName = [deviceInfo.name 'StereoPlayVer'];
			obj.rcxSetups(2).versionTagValue = 7;
            obj.rcxSetups(3).rcxFilename = 'benware/tdt/%s-threechannelplay.rcx';
            obj.rcxSetups(3).versionTagName = [deviceInfo.name 'ThreeChannelPlayVer'];
            obj.rcxSetups(3).versionTagValue = 7;


			% initialise the device
			obj.initialise(deviceInfo, sampleRate, nChannels);
        end

		function initialise(obj, deviceInfo, sampleRate, nChannels)
			% call this to reinitialise the class -- will create a new
			% TDT handle and upload the rcx file
			rcxSetup = obj.rcxSetups(nChannels);
			rcxFilename = sprintf(rcxSetup.rcxFilename, deviceInfo.name);
			initialise@tdtDevice(obj, deviceInfo, rcxFilename, sampleRate);
            if ~obj.checkDevice(deviceInfo, sampleRate, nChannels);
                errorBeep('StimDevice is not in requested state after initialisation');
            end
        end

		function [ok, message] = checkDevice(obj, deviceInfo, sampleRate, nChannels)
			% call this to make sure the TDT is in the desired state
			rcxSetup = obj.rcxSetups(nChannels);
			[ok, message] = obj.checkDevice@tdtDevice(deviceInfo, sampleRate, rcxSetup.versionTagName, rcxSetup.versionTagValue);
            obj.reset;
		end

		function stim = downloadStim(obj, offset, nSamples, nStimChans)
            % why is nStimChans specified here? It should be obvious
            % from the stimDevice. i think that however channel numbers
            % are specified should be rationalised
            stim(1,:) = obj.handle.ReadTagV('WaveformL', offset, nSamples);

            if nStimChans>1
                stim(2,:) = obj.handle.ReadTagV('WaveformR', offset, nSamples);
            end

            if nStimChans>2
                stim(3,:) = obj.handle.ReadTagV('WaveformE', offset, nSamples);
            end

        end

        function prepareForSweep(obj, currentStim, nextStim)
            % at the end of this function, the stimDevice must be
            % be ready to receive a zBus trigger. It will then start
            % playing out stim.

            % register the new stimulus
            obj.currentStim = currentStim;

            if max(abs(obj.currentStim(:)))>10
                fprintf('== Warning -- maximum stimulus value is > 10V ==');
            end

            % if we already have a nextStim, check whether it matches currentStim
            match = false;
            if ~isempty(obj.nextStim)
                sz1 = size(obj.nextStim);
                sz2 = size(obj.currentStim);
                if length(sz1)==length(sz2) && all(sz1==sz2) && all(obj.nextStim(:)==obj.currentStim(:))
                    match = true;
                end
            end

            if match
                % if they match, make sure upload is finished
                obj.finishUploadingNextStim;
            else
                % otherwise upload whole stimulus from scratch
                obj.uploadCurrentStim;
            end

            % set other essential variables on device
            obj.setActiveStimChannels(size(obj.currentStim, 1));
            obj.setStimLength(size(obj.currentStim, 2));

            % check that the stimulus on the device matches currentStim
            obj.checkStimOnDevice;

            % reset circuit
            obj.reset;

            % register the next stimulus so it can be uploaded
            % during the sweep
            obj.nextStim = nextStim;
            obj.nextStimIndex = 0;

        end

        function workDuringSweep(obj)
            % check the current stimulus index
            % fill up the buffer to index-1

            if ~isempty(obj.nextStim)
                % stimulus upload is limited by length of stimulus, or where the
                % stimDevice has got to in reading out the stimulus, whichever is lower
                maxStimIndex = min(obj.getStimIndex, size(obj.nextStim, 2));

                if maxStimIndex>obj.nextStimIndex
                    obj.uploadStim(obj.nextStim(:, obj.nextStimIndex+1:maxStimIndex), obj.nextStimIndex);
                    obj.nextStimIndex = maxStimIndex;

                    if obj.nextStimIndex==size(obj.nextStim, 2)
                        fprintf(['  * Next stimulus uploaded during sweep, after ' num2str(toc) ' sec.\n']);
                    end
                end

            end

        end

        function workAfterSweep(obj)
            obj.finishUploadingNextStim;
        end

        function uploadCurrentStim(obj)
            obj.uploadWholeStim(obj.currentStim);
        end

        function finishUploadingNextStim(obj)
            maxStimIndex = size(obj.nextStim, 2);

            if maxStimIndex>obj.nextStimIndex
                fprintf('  * Uploading remaining %d stimulus samples...', maxStimIndex-obj.nextStimIndex);
                obj.uploadStim(obj.nextStim(:, obj.nextStimIndex+1:maxStimIndex), obj.nextStimIndex);
                obj.nextStimIndex = maxStimIndex;

                if obj.nextStimIndex==size(obj.nextStim, 2)
                    fprintf(['done after ' num2str(toc) ' sec.\n']);
                end
            end
        end

        function checkStimOnDevice(obj)
            % check that the correct stimulus is in the stimDevice buffer
            nStimChans = size(obj.currentStim, 1);
            stimLen = size(obj.currentStim, 2);

            % check stimulus length is correct
            if obj.getStimLength ~= stimLen
                errorBeep('Stimulus length on stimDevice is not correct');
            end

            % check some of the data itself is correct
            rnd = floor(100+rand*(stimLen-300));

            checkData = [obj.downloadStim(0, 100, nStimChans) ...
                obj.downloadStim(rnd, 100, nStimChans) ...
                obj.downloadStim(stimLen-100, 100, nStimChans)];

            %fprintf('warning, skipping check');

            d = max(max(abs(checkData - [obj.currentStim(:, 1:100) obj.currentStim(:, rnd+1:rnd+100) obj.currentStim(:, end-99:end)])));
            if d>10e-7
                fprintf('Stimulus on stimDevice is not correct!\n');
                keyboard
                %errorBeep('Stimulus on stimDevice is not correct!');
            end

        end

        function index = getStimIndex(obj)
            index = obj.handle.GetTagVal('StimIndex');
        end

        function nSamples = getStimLength(obj)
            nSamples = obj.handle.GetTagVal('nSamples');
        end

        function setStimLength(obj, samples)
            if ~obj.handle.SetTagVal('nSamples', samples)
                errorBeep('WriteTag nSamples failed');
            end
        end

        function setActiveStimChannels(obj, nChannels)
            obj.handle.SetTagVal('LeftActive', 1);

            if nChannels>1
                obj.handle.SetTagVal('RightActive', 1);
            else
                obj.handle.SetTagVal('RightActive', 0);
            end

            if nChannels>2
                obj.handle.SetTagVal('ExtraActive', 1);
            else
                obj.handle.SetTagVal('ExtraActive', 0);
            end

        end

        function softTriggerStimulus(stimDevice)
            invoke(stimDevice,'SoftTrg',1);
        end

        function reset(obj)
            obj.handle.SoftTrg(9);
        end

        function uploadStim(obj, stim, offset)
            % Note it's also necessary to set nSamples for the new stimulus

            %[offset offset+size(stim,2) getStimIndex]
            %if ~stimDevice.WriteTagV('WaveformL',offset,stim(1,:))
            %    errorBeep('WriteTagV WaveformL failed');
            %end
            %if ~stimDevice.WriteTagV('WaveformR',offset,stim(2,:))
            %    errorBeep('WriteTagV WaveformR failed');
            %end;

            maxRetries = 2;

            nRetries = 0;
            success = false;

            while ~success && nRetries<maxRetries
                success = obj.handle.WriteTagV('WaveformL',offset,stim(1,:));
                if ~success
                    fprintf('== WriteTagV WaveformL failed\n');
                    nRetries = nRetries + 1;
                end
            end

            if ~success
                errorBeep('Giving up after 3 attempts!');
            end

            if size(stim,1)==1
                return
            end

            nRetries = 0;
            success = false;

            while ~success && nRetries<maxRetries
                success = obj.handle.WriteTagV('WaveformR',offset,stim(2,:));
                if ~success
                    fprintf('== WriteTagV WaveformR failed\n');
                    nRetries = nRetries + 1;
                end
            end

            if ~success
                errorBeep('Giving up after 3 attempts!');
            end

            if size(stim,1)==2
                return
            end

            nRetries = 0;
            success = false;

            while ~success && nRetries<maxRetries
                success = obj.handle.WriteTagV('WaveformE',offset,stim(3,:));
                if ~success
                    fprintf('== WriteTagV WaveformE failed\n');
                    nRetries = nRetries + 1;
                end
            end

        end

        function uploadWholeStim(obj, stim)
            % uploadWholeStimulus(obj, stim)
            %
            % Upload a stereo stimulus to stimDevice, and inform the device
            % about the stimulus length
            t = toc;
            fprintf('  * Uploading whole stimulus...');

            if ~obj.handle.SetTagVal('nSamples',size(stim,2))
                errorBeep('WriteTag nSamples failed');
            end

            if ~obj.handle.WriteTagV('WaveformL',0,stim(1,:))
                errorBeep('WriteTagV WaveformL failed');
            end

            if size(stim, 1)==1
                return
            end

            if ~obj.handle.WriteTagV('WaveformR',0,stim(2,:))
                errorBeep('WriteTagV WaveformR failed');
            end

            if size(stim, 1)==2
                return
            end

            if ~obj.handle.WriteTagV('WaveformE',0,stim(3,:))
                errorBeep('WriteTagV WaveformE failed');
            end

            fprintf('done after %0.2f sec\n', toc-t);
        end

   end
end
