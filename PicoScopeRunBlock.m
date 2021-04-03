classdef PicoScopeRunBlock < matlab.System
    properties (Constant)
        DEFAULT_CHANNEL = PicoScope4000a.CHANNEL.A;
        DEFAULT_COUPLING = PicoScope4000a.COUPLING.DC;
        DEFAULT_PROBE_RANGE = PicoScope4000a.PROBE_RANGE.DIFFERENTIAL_5V;
        DEFAULT_SAMPLE_RATE = PicoScope4000a.SAMPLE_RATE.FS_40MHZ;
        DEFAULT_ANALOG_OFSET_V = 0;
        DEFAULT_DOWN_SAMPLE_RATIO = 1;
        DEFAULT_RATIO_MODE = PicoScope4000a.RATIO_MODE.NONE
        DEFAULT_SEGMENT_INDEX = 0;
        DEFAULT_NUM_SAMPLES_PER_RUN = 40e6;
    end
    
    properties (Access = public)
        NumSamplesPerRun
        Channels
        Coupling
        ProbeRange
        SampleRate
        AnalogOffsetInV
    end
    
    properties (Access = public, Hidden)
        Handle
        BufferPtr
    end
    
    
    methods (Access = public)
        function obj = PicoScopeRunBlock()
            obj.NumSamplesPerRun = obj.DEFAULT_NUM_SAMPLES_PER_RUN;
            obj.Channels = obj.DEFAULT_CHANNEL;
            obj.Coupling = obj.DEFAULT_COUPLING;
            obj.ProbeRange = obj.DEFAULT_PROBE_RANGE;
            obj.SampleRate = obj.DEFAULT_SAMPLE_RATE;
            obj.AnalogOffsetInV = obj.DEFAULT_ANALOG_OFSET_V;
        end
    end
    
    methods (Access = protected)
        function setupImpl(obj)
            obj.BufferPtr = repmat(libpointer, 1, numel(obj.Channels));
            
            obj.openUnit()
            obj.releaseAllChannelss();
            obj.setupDesiredChannelss();
            obj.allocateBuffer();
            obj.stepImpl();
        end
        
        function data = stepImpl(obj)
            obj.acquireData();
            PicoScope4000a.waitUntilDataIsReady(obj.Handle)
            obj.fetchDataFromDevice();
            data = obj.unpackData();
        end
        
        function releaseImpl(obj)
            status = PicoScope4000a.closeUnit(obj.Handle);
            assert(status == 0, 'Failure on closeUnit().')
            PicoScope4000a.unloadLibrary();
        end
    end
    
    
    methods (Access = private)
        function openUnit(obj)
            PicoScope4000a.loadLibrary();
            
            [status, obj.Handle] = PicoScope4000a.openUnit();
            assert(status == 0, 'Failure on openUnit().')
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
                assert(status == 0, 'Failure on resetAllChannelss().')
            end
        end
        
        function setupDesiredChannelss(obj)
            enabled = true;
            for channelId = uint8(obj.Channels)
                status = PicoScope4000a.setChannel(...
                    obj.Handle, ...
                    channelId, ...
                    enabled, ...
                    obj.Coupling, ...
                    obj.ProbeRange, ...
                    obj.AnalogOffsetInV ...
                    );
                assert(status == 0, 'Failure on setupDesiredChannelss().')
            end
        end
        
        function allocateBuffer(obj)
            bufferLth = obj.NumSamplesPerRun;
            for channelId = uint8(obj.Channels)
                [status, obj.BufferPtr(channelId+1)] = PicoScope4000a.setDataBuffer(...
                    obj.Handle, ...
                    channelId, ...
                    bufferLth, ...
                    obj.DEFAULT_SEGMENT_INDEX, ...
                    obj.DEFAULT_RATIO_MODE ...
                    );
                assert(status == 0, 'Failure on allocateBuffer().')
            end
        end
        
        function acquireData(obj)
            preTriggerSamples = 0;
            postTriggerSamples = obj.NumSamplesPerRun;
            [status] = PicoScope4000a.runBlock(...
                obj.Handle, ...
                preTriggerSamples, ...
                postTriggerSamples, ...
                obj.SampleRate, ...
                obj.DEFAULT_SEGMENT_INDEX...
                );
            assert(status == 0, 'Failure on acquireData().')
        end
        
        function [noOfSamples, overflow] = fetchDataFromDevice(obj)
            startIndex = 0;
            noOfSamples = obj.NumSamplesPerRun;
            [status, noOfSamples, overflow] = PicoScope4000a.getValues(...
                obj.Handle, ...
                startIndex, ...
                noOfSamples, ...
                obj.DEFAULT_DOWN_SAMPLE_RATIO, ...
                obj.DEFAULT_RATIO_MODE, ...
                obj.DEFAULT_SEGMENT_INDEX ...
                );
            assert(status == 0, 'Failure on fetchDataFromDevice().')
        end
        
        function data = unpackData(obj)
            data = zeros(obj.NumSamplesPerRun, numel(obj.Channels));
            for channelId = uint8(obj.Channels)
                data(:, channelId+1) = obj.BufferPtr(channelId+1).Value;
            end
        end
    end
end
