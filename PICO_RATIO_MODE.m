classdef PICO_RATIO_MODE < uint32
    enumeration
        NONE      (0)
        AGGREGATE (1)
        DECIMATE  (2)
        AVERAGE   (4)
    end
    
    methods (Static)
        function resultStruct = getStruct()
            [~, names] = enumeration(mfilename);
            resultStruct = struct();
            
            for index = 1:numel(names)
                thisName = char(names(index));
                resultStruct.(thisName) = PICO_RATIO_MODE.(thisName);
            end
        end
    end
end
