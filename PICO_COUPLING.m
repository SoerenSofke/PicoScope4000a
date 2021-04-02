classdef PICO_COUPLING < uint32
    enumeration
        AC (0)
        DC (1)
    end
    
    methods (Static)
        function resultStruct = getStruct()
            [~, names] = enumeration(mfilename);            
            resultStruct = struct();
            
            for index = 1:numel(names)
                thisName = char(names(index));
                resultStruct.(thisName) = PICO_COUPLING.(thisName);
            end
        end
    end
end