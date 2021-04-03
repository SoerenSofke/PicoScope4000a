# PicoScope4000a

MATLAB Interface to PicoScope 4000A Series Oscilloscopes, tested with PicoScope 4824 in _block mode_.

```matlab
% Instantiate
runBlock = PicoScopeRunBlock();

% Set parameters
runBlock.SampleRate = PICO_SAMPLE_RATE.FS_10MHZ;
runBlock.NumSamplesPerRun = 10e6;
runBlock.Channels = [...
    PICO_CHANNEL.A, ...
    PICO_CHANNEL.B, ...
    ];

% Initialize
runBlock.setup();

% Operate
for blockIndex = 1:10
    tic;
    data = runBlock();
    toc;

    plot(data(1:1e5, :))
    drawnow();
end

% Teardown
runBlock.release();
delete(runBlock)
```
