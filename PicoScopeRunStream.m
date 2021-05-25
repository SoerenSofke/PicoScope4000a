classdef PicoScopeRunStream < matlab.System
    properties (Constant)
        DEFAULT_CHANNEL = PicoScope4000a.CHANNEL.A;
        DEFAULT_COUPLING = PicoScope4000a.COUPLING.DC;
        DEFAULT_PROBE_RANGE = PicoScope4000a.PROBE_RANGE.DIFFERENTIAL_5V;
        DEFAULT_ANALOG_OFSET_V = 0;
        DEFAULT_DOWN_SAMPLE_RATIO = 1;
        DEFAULT_RATIO_MODE = PicoScope4000a.RATIO_MODE.NONE;
        DEFAULT_SEGMENT_INDEX = 0;
        DEFAULT_MAX_CHANNEL = 8;
        DEFAULT_SAMPLE_RATE_HZ = 20e6;
        DEFAULT_NUM_SAMPLES_PER_RUN = 20e6;
    end
    
    properties (Access = public)
        NumSamplesPerRun
        Channels
        Coupling
        ProbeRange
        AnalogOffsetInV
        SampleRate
    end
    
    properties (Access = public, Hidden)
        Handle
        DeviceBufferPointer
        AppBufferPointer
    end
    
    methods (Access = public)
        function obj = PicoScopeRunStream()
            obj.NumSamplesPerRun = obj.DEFAULT_NUM_SAMPLES_PER_RUN;
            obj.Channels = obj.DEFAULT_CHANNEL;
            obj.Coupling = obj.DEFAULT_COUPLING;
            obj.ProbeRange = obj.DEFAULT_PROBE_RANGE;
            obj.AnalogOffsetInV = obj.DEFAULT_ANALOG_OFSET_V;
            obj.SampleRate = obj.DEFAULT_SAMPLE_RATE_HZ;
        end
    end
    
    methods (Access = protected)
        function setupImpl(obj)
            obj.openUnit()
            obj.releaseAllChannelss();
            obj.setupDesiredChannelss();
            obj.allocateBuffer();
            obj.startStreaming();
        end
        
        function data = stepImpl(obj)
            veryFirstSampleIndex = inf;
            data = zeros(obj.NumSamplesPerRun, numel(obj.Channels), 'int16');
            
            while true
                obj.fetchDataFromDevice();                                
                [data, startIndex, endIndex] = obj.aggregateDataFromAppBuffer(data);

                veryFirstSampleIndex = min(veryFirstSampleIndex, startIndex);
                if endIndex == obj.NumSamplesPerRun && veryFirstSampleIndex == 1
                    break
                end
            end
        end
        
        function releaseImpl(obj)
            obj.closeUnit()
        end
    end
    
    methods (Access = private)
        function openUnit(obj)
            PicoScope4000a.loadLibrary();
            
            [status, obj.Handle] = PicoScope4000a.openUnit();
            assert(status == 0, 'Failure on openUnit() with PICO_STATUS: %d.', status)
            
            PicoScope4000a.setChannelCount(obj.Handle, obj.DEFAULT_MAX_CHANNEL);
        end
        
        function closeUnit(obj)
            status = PicoScope4000a.closeUnit(obj.Handle);
            assert(status == 0, 'Failure on closeUnit() with PICO_STATUS: %d.', status)
            PicoScope4000a.unloadLibrary();
        end
        
        function releaseAllChannelss(obj)
            enabled = false;
            for channelId = uint8(PicoScope4000a.CHANNEL.A):uint8(PicoScope4000a.CHANNEL.H)
                status = PicoScope4000a.setChannel(...
                    obj.Handle, ...
                    channelId, ...
                    enabled, ...
                    obj.DEFAULT_COUPLING, ...
                    obj.DEFAULT_PROBE_RANGE, ...
                    obj.DEFAULT_ANALOG_OFSET_V ...
                    );
                assert(status == 0, 'Failure on resetAllChannelss() with PICO_STATUS: %d.', status)
            end
        end
        
        function setupDesiredChannelss(obj)
            enabled = true;
            enabledChannels = zeros(1, obj.DEFAULT_MAX_CHANNEL);
            
            for channelId = uint8(obj.Channels)
                status = PicoScope4000a.setChannel(...
                    obj.Handle, ...
                    channelId, ...
                    enabled, ...
                    obj.Coupling, ...
                    obj.ProbeRange, ...
                    obj.AnalogOffsetInV ...
                    );
                assert(status == 0, 'Failure on setupDesiredChannelss() with PICO_STATUS: %d.', status)
                
                enabledChannels(channelId + 1) = true;
            end
            
            [status] = PicoScope4000a.setEnabledChannels(obj.Handle, enabledChannels);
            assert(status == 0, 'Failure on setEnabledChannels() with PICO_STATUS: %d.', status)
        end
        
        function allocateBuffer(obj)
            obj.DeviceBufferPointer = repmat(libpointer, 1, numel(obj.Channels));
            obj.AppBufferPointer = repmat(libpointer, 1, numel(obj.Channels));
            
            bufferLength = obj.NumSamplesPerRun;
            for channelId = uint8(obj.Channels)
                [status, obj.DeviceBufferPointer(channelId+1)] = PicoScope4000a.setDataBuffer(...
                    obj.Handle, ...
                    channelId, ...
                    bufferLength, ...
                    obj.DEFAULT_SEGMENT_INDEX, ...
                    obj.DEFAULT_RATIO_MODE ...
                    );
                assert(status == 0, 'Failure on allocateBuffer() with PICO_STATUS: %d.', status)
                
                [status, obj.AppBufferPointer(channelId+1)] = PicoScope4000a.setAppAndDriverBuffers(...
                    obj.Handle, ...
                    channelId, ...
                    obj.DeviceBufferPointer(channelId+1), ...
                    bufferLength ...
                    );
                assert(status == 0, 'Failure on setAppAndDriverBuffers() with PICO_STATUS: %d.', status)
            end
        end
        
        function startStreaming(obj)
            sampleInterval_ns = floor(((1e15/obj.SampleRate)+0.5));
            maxPreTriggerSamples = 0;
            maxPostTriggerSamples = obj.NumSamplesPerRun;
            autoStop = false;
            
            status = PicoScope4000a.runStreaming(...
                obj.Handle, ...
                sampleInterval_ns, ...
                PICO_TIME_UNITS.PS4000A_FS, ...
                maxPreTriggerSamples, ...
                maxPostTriggerSamples, ...
                autoStop, ...
                obj.DEFAULT_DOWN_SAMPLE_RATIO, ...
                obj.DEFAULT_RATIO_MODE, ...
                obj.NumSamplesPerRun ...
                );
            
            assert(status == 0, 'Failure on runStreaming() with PICO_STATUS: %d.', status)
        end
        
        function fetchDataFromDevice(obj)           
                while true
                    status = PicoScope4000a.getStreamingLatestValues(obj.Handle);                    
                    
                    if status == 0
                        break
                    else
                        dateTime = datetime('now');
                        warning('%s -- PICO_STATUS: %d', dateTime, status);
                    end
                end  
        end
        
        function [data, startIndex, endIndex] = aggregateDataFromAppBuffer(obj, data)
            [numberOfSamplesCollected, startIndexZeroBased] = PicoScope4000a.availableData(obj.Handle);
            
            startIndex = startIndexZeroBased + 1;
            endIndex = numberOfSamplesCollected + startIndexZeroBased;
            
            for channelId = uint8(obj.Channels)
                data(:, channelId+1) = obj.AppBufferPointer(channelId+1).Value;
            end
        end
        
    end
end
