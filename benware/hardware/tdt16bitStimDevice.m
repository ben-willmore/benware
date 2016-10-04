classdef tdt16bitStimDevice < tdtDevice
	properties
		rcxSetups = [];
        currentStim = [];
        currentStimEnc = [];
        currentStimScaleFactor = nan;
        nextStim = [];
        nextStimEnc = [];
        nextStimScaleFactor = nan;
        nextStimIndex = nan;
	end

	methods

		function obj = tdt16bitStimDevice(deviceInfo, sampleRate, nChannels)
			% initialise the class itself
			obj.rcxSetups(1).rcxFilename = 'benware/tdt/%s-monoplay16bit.rcx';
			obj.rcxSetups(1).versionTagName = [deviceInfo.name 'MonoPlay16bitVer'];
			obj.rcxSetups(1).versionTagValue = 3;
			obj.rcxSetups(2).rcxFilename = 'benware/tdt/%s-stereoplay16bit.rcx';
			obj.rcxSetups(2).versionTagName = [deviceInfo.name 'StereoPlay16bitVer'];
			obj.rcxSetups(2).versionTagValue = 7;
            obj.rcxSetups(3).rcxFilename = 'benware/tdt/%s-threechannelplay16bit.rcx';
            obj.rcxSetups(3).versionTagName = [deviceInfo.name 'ThreeChannelPlay16bitVer'];
            obj.rcxSetups(3).versionTagValue = 8;

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

        function setScaleFactor(obj, scaleFactor)
           if ~obj.handle.SetTagVal('ScaleFactorL', scaleFactor.L);
              errorBeep('Failed to set ScaleFactorL');
           end

           if length(obj.currentStim)==0
              errorBeep('tdt16bitStimDevice: obj.currentStim is empty');
           end

           if size(obj.currentStim,1)>1
               if ~obj.handle.SetTagVal('ScaleFactorR', scaleFactor.R);
                  errorBeep('Failed to set ScaleFactorR');
               end
           end

           if size(obj.currentStim,1)>2
               if ~obj.handle.SetTagVal('ScaleFactorE', scaleFactor.E);
                  errorBeep('Failed to set ScaleFactorE');
               end
           end

        end

        function scaleFactor = getScaleFactor(obj)
           scaleFactor.L = obj.handle.GetTagVal('ScaleFactorL');

           if length(obj.currentStim)==0
              errorBeep('tdt16bitStimDevice: obj.currentStim is empty');
           end

           if size(obj.currentStim,1)>1
               scaleFactor.R = obj.handle.GetTagVal('ScaleFactorR');
           end

           if size(obj.currentStim,1)>2
               scaleFactor.E = obj.handle.GetTagVal('ScaleFactorE');
           end

        end

        function [stimEnc, scaleFactor] = encode(obj, stim)
           if isempty(stim)
               scaleFactor.L = 0;
               if size(stim,1)>1
                   scaleFactor.R = 0;
               end
               if size(stim,1)>2
                   scaleFactor.E = 0;
               end
               stimEnc = [];
           else
               if mod(size(stim,2),2)==1
                   stim(:, end+1) = 0;
               end

               scaleFactor.L = max(abs(stim(1,:)))/(2^15-1);
               stimEnc(1,:) = stim(1,:)/scaleFactor.L;

               if size(stim,1)>1
                   scaleFactor.R = max(abs(stim(2,:)))/(2^15-1);
                   stimEnc(2,:) = stim(2,:)/scaleFactor.R;
               end

               if size(stim,1)>2
                   scaleFactor.E = max(abs(stim(3,:)))/(2^15-1);
                   stimEnc(3,:) = stim(3,:)/scaleFactor.E;
               end

           end
        end

        function stimDec = decode(obj, stim, scaleFactor)
            if isempty(stim)
                stimDec = [];
            else
                stimDec(1,:) = stim(1,:) * scaleFactor.L;

                if size(stim,1)>1
                    stimDec(2,:) = stim(2,:) * scaleFactor.R;
                end

                if size(stim,1)>2
                    stimDec(3,:) = stim(3,:) * scaleFactor.E;
                end

            end
        end


		function stim = downloadStim(obj, offset, nSamples, nStimChans)
            % why is nStimChans specified here? It should be obvious
            % from the stimDevice. i think that however channel numbers
            % are specified should be rationalised
            stim(1,:) = obj.handle.ReadTagVEX('WaveformL', offset, nSamples, 'I16', 'F64', 1);

            if nStimChans>1
                stim(2,:) = obj.handle.ReadTagVEX('WaveformR', offset, nSamples, 'I16', 'F64', 1);
            end

            if nStimChans>2
                stim(3,:) = obj.handle.ReadTagVEX('WaveformE', offset, nSamples, 'I16', 'F64', 1);
            end

            stim = obj.decode(stim, obj.getScaleFactor);
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

            [obj.currentStimEnc, obj.currentStimScaleFactor] = obj.encode(obj.currentStim);

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
            obj.setScaleFactor(obj.currentStimScaleFactor);

            % check that the stimulus on the device matches currentStim
            obj.checkStimOnDevice;

            % reset circuit
            obj.reset;

            % register the next stimulus so it can be uploaded
            % during the sweep
            obj.nextStim = nextStim;
            [obj.nextStimEnc, obj.nextStimScaleFactor] = obj.encode(obj.nextStim);
            obj.nextStimIndex = 0;

        end

        function workDuringSweep(obj)
            % check the current stimulus index
            % fill up the buffer to index-1

            if ~isempty(obj.nextStimEnc)
                % stimulus upload is limited by length of stimulus, or where the
                % stimDevice has got to in reading out the stimulus, whichever is lower
                maxStimIndex = floor((min(obj.getStimIndex, size(obj.nextStimEnc, 2)))/2)*2;

                if maxStimIndex>obj.nextStimIndex
                    obj.uploadStim(obj.nextStimEnc(:, obj.nextStimIndex+1:maxStimIndex), obj.nextStimIndex);
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
            obj.uploadWholeStim(obj.currentStimEnc);
        end

        function finishUploadingNextStim(obj)
            maxStimIndex = size(obj.nextStimEnc, 2);

            if maxStimIndex>obj.nextStimIndex

                obj.uploadStim(obj.nextStimEnc(:, obj.nextStimIndex+1:maxStimIndex), obj.nextStimIndex);
                obj.nextStimIndex = maxStimIndex;

                if obj.nextStimIndex==size(obj.nextStimEnc, 2)
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
            rnd = floor((100+rand*(stimLen-300))/2)*2;

            mxIdx = floor(size(obj.currentStim, 2)/2)*2;

            checkData = [obj.downloadStim(0, 100, nStimChans) ...
                obj.downloadStim(rnd, 100, nStimChans) ...
                obj.downloadStim(mxIdx-100, 100, nStimChans)];

            %fprintf('warning, skipping check');
            d = max(max(abs(checkData - [obj.currentStim(:, 1:100) obj.currentStim(:, rnd+1:rnd+100) obj.currentStim(:, mxIdx-99:mxIdx)])));
            if d>10e-4
                fprintf('Stimulus on stimDevice is not correct!\n');
                figure(9);
                subplot(2,1,1);
                plot(checkData(1,:)');
                hold all;
                plot([obj.currentStim(1, 1:100) obj.currentStim(1, rnd+1:rnd+100) obj.currentStim(1, mxIdx-99:mxIdx)]');
                plot(checkData(1,:)' - [obj.currentStim(1, 1:100) obj.currentStim(1, rnd+1:rnd+100) obj.currentStim(1, mxIdx-99:mxIdx)]');
                hold off;
                subplot(2,1,2);
                plot(checkData(2,:)');
                hold all;
                plot([obj.currentStim(2, 1:100) obj.currentStim(2, rnd+1:rnd+100) obj.currentStim(2, mxIdx-99:mxIdx)]');
                plot(checkData(2,:)' - [obj.currentStim(2, 1:100) obj.currentStim(2, rnd+1:rnd+100) obj.currentStim(2, mxIdx-99:mxIdx)]');
                hold off;
                keyboard
                %errorBeep('Stimulus on stimDevice is not correct!');
            end

        end

        function index = getStimIndex(obj)
            index = obj.handle.GetTagVal('StimIndex')*2;
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
                try
                success = obj.handle.WriteTagVEX('WaveformL',offset,'I16',stim(1,:));
                catch
                    keyboard
                end
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
                success = obj.handle.WriteTagVEX('WaveformR',offset,'I16',stim(2,:));
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
                success = obj.handle.WriteTagVEX('WaveformE',offset,'I16',stim(3,:));
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

            if ~obj.handle.WriteTagVEX('WaveformL',0,'I16',stim(1,:))
                errorBeep('WriteTagV WaveformL failed');
            end

            if size(stim, 1)==1
                return
            end

            if ~obj.handle.WriteTagVEX('WaveformR',0,'I16',stim(2,:))
                errorBeep('WriteTagV WaveformR failed');
            end

            if size(stim, 1)==2
                return
            end

            if ~obj.handle.WriteTagVEX('WaveformE',0,'I16',stim(3,:))
                errorBeep('WriteTagV WaveformE failed');
            end

            fprintf('done after %0.2f sec\n', toc-t);
        end

   end
end
