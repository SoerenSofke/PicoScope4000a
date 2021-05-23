% Soeren Sofke, IBS
% 2021-05-22

function runStreamChannelAB()
%%% Instantiate
runStream = PicoScopeRunStream();
cleanupRunBlockBlock = onCleanup(@() tearDown(runStream));

%%% Initialize
hFig = figure();
runStream.setup();

while ishandle(hFig)
    tic;
    data = runStream();    
    plot(gca(), data(1:100))
    drawnow();
    toc
end
end

%%% Teardown
function tearDown(runStream)
runStream.release();
delete(runStream);

disp('Done!')
end