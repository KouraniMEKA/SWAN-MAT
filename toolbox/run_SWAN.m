function run_SWAN(SWAN_fname)

% run SWAN excutes swanrun.exe for the a given 'fname'.swn file
%
%__________________________________________________________________________
%
% Author : Ahmad Kourani, PhD student, American University of Beirut
% Date   : Jan 2017
%__________________________________________________________________________


% !: command to the operating system
% &: background mode, return control to the command window immmediately
%----Run inside MATLAB: 
% system(['swanrun ' SWAN_fname])
% pause
%----Run on external command window:

disp('SWAN run is starting in backgroun mode...')
eval(sprintf(['!swanrun ',SWAN_fname,' &'])) 

end