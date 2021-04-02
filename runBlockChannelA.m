% Soeren Sofke, IBS
% 2021-04-02

close all;
clear;

runBlock = PicoScopeRunBlock();

for blockIndex = 1:10
    data = runBlock();
    plot(data(1:1e5))
    drawnow();
end

delete(runBlock);