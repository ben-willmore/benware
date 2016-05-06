classdef fakeStimDevice < handle
	properties
	  deviceInfo = '';
	  sampleRate = nan;
	  nChannels = nan;
		nSamples = -1
		triggerTime = -1
		intactWaveformL = [];
		intactWaveformR = [];
		timer = []
		waveformL = zeros(1,2000000)
		waveformR = zeros(1,2000000)
		leftActive = 1;
		rightActive = 1;
    stimIndex = 0
 	end

	methods

	  function obj = fakeStimDevice(deviceInfo, requestedSampleRateHz, nChannels)
		obj.deviceInfo = deviceInfo;
		obj.sampleRate = requestedSampleRateHz;
		obj.nChannels = nChannels;
      end
      
      function [ok, message] = checkDevice(obj, deviceInfo, sampleRate, nChannels)
          ok = 1;
          message = '';
      end
      
      function stim = downloadStim(obj, offset, nSamples, nStimChans)
		offset = offset + 1;
		stim = obj.waveformL(offset:offset+nSamples-1);

		if nStimChans==2
			 stim(2,:) = obj.waveformR(offset:offset+nSamples-1);
		end
	  end

	  function index = getStimIndex(obj)
	  	index = obj.stimIndex;
	  end

	  function nSamples = getStimLength(obj)
	  	nSamples = obj.nSamples;
	  end


      function prepareForSweep(obj, currentStim, nextStim)
        % at the end of this function, the stimDevice must be
        % be ready to receive a zBus trigger. It will then start
        % playing out stim.
	    obj.stimIndex = 0;
	    if isobject(obj.timer)
	      stop(obj.timer);
	      delete(obj.timer);
	      obj.timer = [];
        end
        
        obj.uploadWholeStim(currentStim);
      end
      
      function workDuringSweep(obj)
      end

      function workAfterSweep(obj)
      end

	  function setActiveStimChannels(obj, nChannels)
	  	obj.leftActive = 1;

	  	if nChannels==1
	  		obj.rightActive = 0;
	  	else
	  		obj.rightActive = 1;
	  	end
	  end

	  function setStimLength(obj, samples)
	  	obj.nSamples = samples;
	  end

	  function uploadStim(obj, stim, offset)
	  	offset = offset + 1;
	  	[nChannels, nSamples] = size(stim);

	  	obj.waveformL(offset:offset+nSamples-1) = stim(1,:);

	  	if nChannels==2
		  	obj.waveformR(offset:offset+nSamples-1) = stim(2,:);
	    end
	  end

	  function uploadWholeStim(obj, stim)
	  	[nChannels, nSamples] = size(stim);

	  	obj.waveformL(1:nSamples) = stim(1,:);

	  	if nChannels==2
		  	obj.waveformR(1:nSamples) = stim(2,:);
	    end
	    obj.nSamples = nSamples;
	  end

	  function trigger(obj)
        global player;
        if obj.sampleRate<50000
          fs = obj.sampleRate;
          idx = 1:obj.nSamples;
        elseif obj.sampleRate<100000
          fs = obj.sampleRate;
          idx = 1:2:obj.nSamples;    
        elseif obj.sampleRate>190000
          fs = obj.sampleRate/4;
          idx = 1:4:obj.nSamples;
        end
        %keyboard
        size([obj.waveformL(idx); obj.waveformR(idx)])
        player = audioplayer([obj.waveformL(idx); obj.waveformR(idx)], fs);
        play(player);
        obj.intactWaveformL = obj.waveformL(1:obj.nSamples);
        obj.intactWaveformR = obj.waveformR(1:obj.nSamples);
        
        obj.triggerTime = now;
        if isobject(obj.timer)
          delete(obj.timer);
          obj.timer = [];
        end
        obj.timer = timer('timerfcn', {@updateFakeStimDevice, obj}, ...
          'ExecutionMode', 'fixedRate', 'BusyMode', 'drop', 'Period', .05);
        start(obj.timer);
    end
  end
end