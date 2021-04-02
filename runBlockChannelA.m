% Soeren Sofke, IBS
% 2021-04-02

close all;
clear;

runBlock = PicoScopeRunBlock();

runBlock.SampleRate = PICO_SAMPLE_RATE.FS_10MHZ;
runBlock.NumSamplesPerRun = 10e6;
runBlock.Channels = [...
    PICO_CHANNEL.A, ...
    PICO_CHANNEL.B, ...
    ];

for blockIndex = 1:10
    tic;
    data = runBlock();
    toc;
    
    plot(data(1:1e5, :))
    drawnow();
end

delete(runBlock);