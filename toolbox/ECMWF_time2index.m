function [time_index]=ECMWF_time2index(Cyear,Cmonth,Cday,Chour)
%ECMWF time2index function returns the equivalent index of a specific time
%in the ECMWM archive structure.
% Inputs: 
%   -Cyear:  current year 
%   -Cmonth: current month
%   -Cday:   current day
%   -Chour:  current hour
%
% Outputs: 
%   -time_index: equivalent ECMWF index
%-------------------------------------------------------------------------&
% Description and examples:
% units     = 'hours since 1900-01-01 00:00:0.0'
% long_name = 'time'
% calendar  = 'gregorian'
% each 1 hour is 1 unit
% 00:00 1 nov 1979 is 699792

% example: 00:00 2 nov 1979 is 699792+24= 699816
% example: 00:00 1 jan 1980 is 699792+24*(30+31)=701256
% 4 years cycle: 24*(366+365*3)=35064
% till 1976: 19*35064=666216
% till 01/11: 666216 +24*(366+365*2) +24*sum([31,28,31,30,31,30,31,31,30,31])

%-------------------------------------------------------------------------&
% Ahmad Kourani PhD student, American University of Beirut
% Jan 2017
%-------------------------------------------------------------------------&
Ndays=0;
% Count with year time step:
for yy=1900:Cyear-1
    if ~mod(yy,4) % Leap year adjustment
        feb_cor=1;
    else
        feb_cor=0;
    end
    ml=[31,28+feb_cor,31,30,31,30,31,31,30,31,30,31];
    Ndays=sum(ml)+Ndays;
end

% Count with month time step:
if ~mod(Cyear,4) % Leap year adjustment
    feb_cor=1;
else
    feb_cor=0;
end
ml=[31,28+feb_cor,31,30,31,30,31,31,30,31,30,31];

if Cmonth~=1   
    Ndays=sum(ml(1:Cmonth-1))+Ndays;
end

% Count with day time step:
Ndays=(Cday-1)+Ndays;
% Count with hour time step:
time_index=Ndays*24+Chour;



  



