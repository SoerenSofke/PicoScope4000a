% Soeren Sofke, IBS
% 2021-04-02
%
% Reference: http://www.mathworks.com/matlabcentral/answers/103180
% Reference: https://www.mathworks.com/matlabcentral/fileexchange/38946

%% Generate the prototype file for ps4000a.dll 
loadlibrary ps4000a.dll ps4000aApi.h mfilename ps4000a.m

%%% Unload the library
unloadlibrary ps4000a

%%% Reload the library with the modified prototype file.
loadlibrary('ps4000a.dll', @ps4000a)
unloadlibrary ps4000a

%% Generate the prototype file for ps4000aWrap.dll 
loadlibrary ps4000aWrap.dll ps4000aWrap.h mfilename ps4000aWrap.m

%%% Unload the library
unloadlibrary ps4000aWrap

%%% Reload the library with the modified prototype file.
loadlibrary('ps4000aWrap.dll', @ps4000aWrap)
unloadlibrary ps4000aWrap