classdef PICO_TIME_UNITS < uint32
    enumeration
        PS4000A_FS (0)
        PS4000A_PS (1)
        PS4000A_NS (2)
        PS4000A_US (3)
        PS4000A_MS (4)
        PS4000A_S  (5)
        PS4000A_MAX_TIME_UNITS  (6)
    end
    
    methods (Static)
        function resultStruct = getStruct()
            [~, names] = enumeration(mfilename);            
            resultStruct = struct();
            
            for index = 1:numel(names)
                thisName = char(names(index));
                resultStruct.(thisName) = PICO_TIME_UNITS.(thisName);
            end
        end
    end
end