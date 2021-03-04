function [dates,days]=day_series_calendar(from,to)

% day_series_calendar() returns individual days dates as yymmdd between 2
% given dates. It also returns the number of days elapsed between the two
% dates.
% Input data format:
%   -yymmdd, as number of string, ex: 170521 for 21 May 2017
%
% This fuction is not designed to handle wrong inputs such as 170532.
% The function is only valid for dates within th 21st century.
% By Ahmad Kourani, PhD student, American University of Beirut
% Jan 2017
%-------------------------------------------------------------------------%

if str2grnum(from,1,6)>str2grnum(to,1,6)
    disp('Invalid order of input data,consider switching');   
    return;
end
% disp('day_series_calendar() is only valid for dates within th 21st century.')
% disp('Consider updating if required.')

yy1=str2grnum(from,1,2);
mm1=str2grnum(from,3,4);
dd1=str2grnum(from,5,6);

if ~mod(yy1,4) % Leap year adjustment
     feb_cor=1;
else
     feb_cor=0;
end
ml=[31,28+feb_cor,31,30,31,30,31,31,30,31,30,31];

clear dates
yy=yy1;
dd=dd1;
mm=mm1;
days=0;
while(days==0 || ~strcmp(dates(days,:),num2str(to)) )
    days=days+1;    
    dates(days,:)=[num2str(yy,'%02i'),num2str(mm,'%02i'),num2str(dd,'%02i')];
    if dd==ml(mm)
        dd=0;
        mm=mm+1;
        if mm==13
            yy=yy+1;
            if ~mod(yy,4) % Leap year adjustment
                 feb_cor=1;
            else
                 feb_cor=0;
            end
            ml(2)=28+feb_cor;
            mm=1;
        end
    end                         
    dd=1+dd;
end