function [StartTime_hh,Steps]=get_data_time_steps(tbeginp,tendinp,TimeStep)

% get_data_time_steps() gives the count of the steps starting from
% tbeginp to tendinp for a specific time step (TimeStep).
% Inputs:
%   -tbeginp: starting time, as number of string, with a format
%   yyyymmddhh... or yyyymmdd.hh...
%   -tendinp: End time, same as tbeginp
%   -TimeStep: time step as number of "hours".
%
% Outputs:
%   -StartTime_hh: the hour at which the seqence starts, as hh
%   -Steps: the number of steps to reach 'tendinp' with 'TimeStep'
%   time-step.
%
% Literally this function can handle dates from any year (0-9999)
% The function has nothing to do with the actual available data, will only
% count sequentially.
%
% by Ahmad Kourani, PhD student, American University of Beirut
% Jan 2017
%-------------------------------------------------------------------------%

%% Case 1: Tstart>Tend => terminate
if str2grnum(tbeginp,1,length(tbeginp)-1)>str2grnum(tendinp,1,length(tendinp)-1)
    disp('Invalid order of input data,consider switching (get_data_time_steps())');   
    return;
end
%% Case 2: Tstart=Tend => set steps to zero
if str2grnum(tbeginp,1,length(tbeginp)-1)==str2grnum(tendinp,1,length(tendinp)-1)
    disp('start and end dates are equal (get_data_time_steps())');
    StartTime_hh=str2grnum(tbeginp,9,10);
    Steps=0;
    return;
end

%% Case 3: Tstart < Tend 
yyyy=str2grnum(tbeginp,1,4);
mm=str2grnum(tbeginp,5,6);
dd=str2grnum(tbeginp,7,8);
hh=str2grnum(tbeginp,9,10);

feb_cor=0;
ml=[31,28+feb_cor,31,30,31,30,31,31,30,31,30,31];

StartTime_hh=hh;
Steps=0;
while(Steps==0 || ~strcmp(date_hh,num2str(str2grnum(tendinp,1,10))) )
    Steps=Steps+1;        
    hh=hh+TimeStep;
    if hh>23
        hh=hh-24;
        dd=1+dd;
        if dd==ml(mm)+1
            dd=1;
            mm=mm+1;
            if mm==13
                yyyy=yyyy+1;
                if ~mod(yyyy,4) % Leap year adjustment
                     feb_cor=1;
                else
                     feb_cor=0;
                end
                ml(2)=28+feb_cor;
                mm=1;
            end
        end  
    end
    date_hh=[num2str(yyyy,'%04i'),num2str(mm,'%02i'),num2str(dd,'%02i'),num2str(hh,'%02i')];
end