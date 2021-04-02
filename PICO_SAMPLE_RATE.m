classdef PICO_SAMPLE_RATE < uint32
    enumeration
        FS_80MHZ    (0)
        FS_40MHZ    (1)
        FS_26p67MHZ (2)
        FS_20MHZ    (3)
        FS_16MHZ    (4)
        FS_13p33MHZ (5)
        FS_11p43MHZ (6)
        FS_10MHZ    (7)
    end
    
    methods (Static)
        function resultStruct = getStruct()
            [~, names] = enumeration(mfilename);
            resultStruct = struct();
            
            for index = 1:numel(names)
                thisName = char(names(index));
                resultStruct.(thisName) = PICO_SAMPLE_RATE.(thisName);
            end
        end
    end
end