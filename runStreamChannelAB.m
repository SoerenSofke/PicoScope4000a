% Soeren Sofke, IBS
% 2021-05-22

function runStreamChannelAB()
%%% Instantiate
runStream = PicoScopeRunStream();
cleanupRunBlockBlock = onCleanup(@() tearDown(runStream));
 
%%% Initialize
runStream.setup();
end

%%% Teardown
function tearDown(runStream)
runStream.release();
delete(runStream);

disp('Done!')
end



