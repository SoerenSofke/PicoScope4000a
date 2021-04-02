classdef PICO_CHANNEL < uint32
    enumeration
        A (0)
        B (1)
        C (2)
        D (3)
        E (4)
        F (5)
        G (6)
        H (7)
    end
    
    methods (Static)
        function resultStruct = getStruct()
            [~, names] = enumeration(mfilename);            
            resultStruct = struct();
            
            for index = 1:numel(names)
                thisName = char(names(index));
                resultStruct.(thisName) = PICO_CHANNEL.(thisName);
            end
        end
    end
end