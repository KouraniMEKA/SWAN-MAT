function [yyyy,mm,dd,hh]=date_after_hr_time_step(date_time,hr_step)

% date_after_hr_time_step() returns date and time after a given time step.
% The time step should be given in hours, and should be less than 24 hours.
% The inputs format is:
%   -date_time:yymmddhh, ex: 17010320 for 3 Jan 2017 20:00'
%   -hr_step: hh, ex: 1, or 12
%
%
% By Ahmad Kourani, PhD Student, American University of Beirut
% Jan 2017
% ------------------------------------------------------------------------%

yyyy=str2grnum(date_time,1,4);
mm=str2grnum(date_time,5,6);
dd=str2grnum(date_time,7,8);
hh=str2grnum(date_time,9,10);

if ~mod(yyyy,4) % Leap year adjustment
     feb_cor=1;
else
     feb_cor=0;
end
ml=[31,28+feb_cor,31,30,31,30,31,31,30,31,30,31];

hh=hh+hr_step;

if hh>23
    hh=hh-24;
    dd=1+dd;
    if dd-1==ml(mm)
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
