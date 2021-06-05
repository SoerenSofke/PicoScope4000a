% Soeren Sofke, IBS
% 2021-04-02

classdef PicoScope4000a < coder.ExternalDependency %#codegen
    properties (Constant = true)
        CHANNEL = PICO_CHANNEL.getStruct();
        PROBE_RANGE = PICO_PROBE_RANGE.getStruct();
        COUPLING = PICO_COUPLING.getStruct();
        SAMPLE_RATE = PICO_SAMPLE_RATE.getStruct();
        RATIO_MODE = PICO_RATIO_MODE.getStruct();
    end
    
    
    methods (Static)
        %% Basic functions defined in _ps4000aApi.h_
        function [status, handle] = openUnit()
            handle = int16(1);
            serial = int8([]);
            [status, handle] = calllib('ps4000a', 'ps4000aOpenUnit', handle, serial);
        end
        
        function [status] = setChannel(handle, CHANNEL, enabled, COUPLING, PROBE_RANGE, analogOffset)
            status = calllib('ps4000a', 'ps4000aSetChannel', handle, double(CHANNEL), enabled, double(COUPLING), double(PROBE_RANGE), analogOffset);
        end
        
        function [status, bufferPtr] = setDataBuffer(handle, CHANNEL, bufferLth, segmentIndex, RATIO_MODE)
            bufferPtr = libpointer('int16Ptr', zeros(bufferLth, 1));
            status = calllib('ps4000a', 'ps4000aSetDataBuffer', handle, double(CHANNEL), bufferPtr, bufferLth, segmentIndex, double(RATIO_MODE));
        end
        
        function [status] = runStreaming(...
                handle, ...
                sampleInterval, ...
                SAMPLE_INTERVAL_TIME_UNITS, ...
                maxPreTriggerSamples, ...
                maxPostTriggerSamples, ...
                autoStop, ...
                downSampleRatio, ...
                RATIO_MODE, ...
                overviewBufferSize ...
                )
            sampleIntervalPointer = libpointer('uint32Ptr', sampleInterval);
            
            status = calllib(...
                'ps4000a', ...                          % name of dll to call
                'ps4000aRunStreaming', ...              % name of function to call
                handle, ...                             % identifier for the scope device
                sampleIntervalPointer, ...              % on entry, the requested time interval between data points on entry; on exit, the actual time interval assigned
                double(SAMPLE_INTERVAL_TIME_UNITS), ... % the unit of time that the sampleInterval is set to
                maxPreTriggerSamples, ...               % the maximum number of raw samples before a trigger event for each enabled channel
                maxPostTriggerSamples, ...              % the maximum number of raw samples after a trigger event for each enabled channel
                autoStop, ...                           % a flag to specify if the streaming should stop when all of maxPreTriggerSamples + maxPostTriggerSamples have been taken
                downSampleRatio, ...                    % the number of raw values to each downsampled value
                double(RATIO_MODE), ...                 % the type of data reduction to use.
                overviewBufferSize ...                  % the size of the overview buffers (the buffers passed by the application to the driver). The size must be less than or equal to the bufferLth value passed to ps4000aSetDataBuffer().
                );
        end
        
        function [status, noOfSamples, overflow] = getValues(handle, startIndex, noOfSamples, downSampleRatio, RATIO_MODE, segmentIndex)
            noOfSamplesPrt = libpointer('uint32Ptr', noOfSamples);
            overflowPtr = libpointer('int16Ptr', 0);
            
            status = calllib('ps4000a', 'ps4000aGetValues', handle, startIndex, noOfSamplesPrt, downSampleRatio, double(RATIO_MODE), segmentIndex, overflowPtr);
            
            noOfSamples = get(noOfSamplesPrt, 'value');
            overflow = get(overflowPtr, 'value');
        end
        
        function [status] = closeUnit(handle)
            status = calllib('ps4000a', 'ps4000aCloseUnit', handle);
        end
        
        %% Advanced function defined in _ps4000aWrap.h_
        function [status] = runBlock(handle, preTriggerSamples, postTriggerSamples, SAMPLE_RATE, segmentIndex)
            status = calllib('ps4000aWrap', 'RunBlock', handle, preTriggerSamples, postTriggerSamples, double(SAMPLE_RATE), segmentIndex);
        end                
        
        function [isReady] = isReady(handle)
            isReady = calllib('ps4000aWrap', 'IsReady', handle);
        end
        
        function [status] = setChannelCount(handle, channelCount)
            status = calllib('ps4000aWrap', 'setChannelCount', handle, channelCount);
        end
        
        function [status] = setEnabledChannels(handle, enabledChannels)
            status = calllib('ps4000aWrap', 'setEnabledChannels', handle, enabledChannels);            
        end
        
        function [status, appBufferPointer] = setAppAndDriverBuffers(handle, CHANNEL, driverBufferPointer, bufferLength)        
            appBufferPointer = libpointer('int16Ptr', zeros(bufferLength, 1));            
            status = calllib('ps4000aWrap', 'setAppAndDriverBuffers', handle, double(CHANNEL), appBufferPointer, driverBufferPointer, bufferLength);
        end
        
        function [status] = getStreamingLatestValues(handle)
            status = calllib('ps4000aWrap', 'GetStreamingLatestValues', handle);
        end
        
        function [numberOfSamplesCollected, startIndex] = availableData(handle)                        
            startIndexPointer = libpointer('uint32Ptr', 0);
            numberOfSamplesCollected = calllib('ps4000aWrap', 'AvailableData', handle, startIndexPointer);
            startIndex = startIndexPointer.Value;
        end
        
        %% Helper functions
        function loadLibrary()
            if not(libisloaded('ps4000a'))
                loadlibrary('ps4000a.dll', @ps4000a);
            end
            
            if not(libisloaded('ps4000aWrap'))
                loadlibrary('ps4000aWrap.dll', @ps4000aWrap);
            end
        end
        
        function unloadLibrary()
            if libisloaded('ps4000a')
                unloadlibrary('ps4000a');
            end
            
            if libisloaded('ps4000aWrap')
                unloadlibrary('ps4000aWrap');
            end
        end
        
        function waitUntilDataIsReady(handle)
            while ~PicoScope4000a.isReady(handle)
            end
        end
    end
end

