function [yyyy,mm,dd,hh]=ECMWF_index2time(index)
%ECMWF_index2time function returns the equivalent time of a specific index
%in the ECMWM archive structure.
% Inputs: 
%   -index: equivalent ECMWF index
%
% Outputs: 
%   -yyyy:  current year 
%   -mm:    current month
%   -dd:    current day
%   -hh:    current hour
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
% index=1016832
index_4y=35064;

fyears=fix(index/index_4y);   % integer part
yyyy=1900+4*fyears;
feb_cor=1; % current yyyy is a leap year
ml=[31,28+feb_cor,31,30,31,30,31,31,30,31,30,31];
index_1y=24*sum(ml);

Rem=double(rem(index,index_4y));   % remainder



y_add=0;
while Rem-index_1y>index_1y
    if y_add>0
        feb_cor=0; % next 3 year are not leap
        ml(2)=28+feb_cor;
        index_1y=24*sum(ml);
    end
    yyyy=yyyy+1;
    Rem=Rem-index_1y;
    y_add=y_add+1;
end

nn=0;
hh=0;
dd=1;
mm=1;

while nn<double(rem(Rem,index_1y))
    nn=nn+1;
    hh=hh+1;
    if hh>23
        hh=hh-24;
        dd=1+dd;
        if dd-1==ml(mm)
            dd=1;
            mm=mm+1;
        end
    end

end