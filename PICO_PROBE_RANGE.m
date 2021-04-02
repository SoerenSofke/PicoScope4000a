classdef PICO_PROBE_RANGE < uint32
    enumeration
        DIFFERENTIAL_10MV   (0)
        DIFFERENTIAL_20MV   (1)
        DIFFERENTIAL_50MV   (2)
        DIFFERENTIAL_100MV  (3)
        DIFFERENTIAL_200MV  (4)
        DIFFERENTIAL_500MV  (5)
        DIFFERENTIAL_1V     (6)
        DIFFERENTIAL_2V     (7)
        DIFFERENTIAL_5V     (8)
        DIFFERENTIAL_10V    (9)        
    end
    
    methods (Static)
        function resultStruct = getStruct()
            [~, names] = enumeration(mfilename);
            resultStruct = struct();
            
            for index = 1:numel(names)
                thisName = char(names(index));
                resultStruct.(thisName) = PICO_PROBE_RANGE.(thisName);
            end
        end
    end
end