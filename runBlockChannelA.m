% Soeren Sofke, IBS
% 2021-04-02

close all;
clear;

runBlock = PicoScopeRunBlock();
runBlock.Channel = [...
    PICO_CHANNEL.A, ...
    PICO_CHANNEL.B ...
    ];

for blockIndex = 1:10
    tic;
    data = runBlock();
    toc;
    
    plot(data(1:1e5, :))
    drawnow();
end

delete(runBlock);