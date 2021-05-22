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
    data = runStream();
    
    numSamples = length(data);
    
    if numSamples > 100
        plot(gca(), data(1:100))
        drawnow();
    end
end

end

%%% Teardown
function tearDown(runStream)
runStream.release();
delete(runStream);

disp('Done!')
end