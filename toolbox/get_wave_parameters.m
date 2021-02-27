function [HscD,ThetacD,PeriodcD]=get_wave_parameters(Case,Hsc,Thetac,Periodc,n)

% get_wave_parameters() returns the wave parameter at a specific boundary
% location. The function averages the values of two points to get data for a
% segment.
% Inputs:
%   -Case: 'N','S','E' or 'W', indicates the side along which the data is
%    requested.
%   -Hsc: matrix 
%   -NS: length of the computational grid in the y-direction (#) 
%   -EW: length of the computational grid in the x-direction (#)
%   -n: index of the segment along the boundary (#-1)
%
% Outputs:
%   -HscD:    segment's Hsig
%   -ThetacD: segment's wave direction
%   PeriodcD: segment's wave period
%__________________________________________________________________________
% This function is based on the method used by the FYP group for averaging
%
% Author: Ahmad Kourani, PhD student, American University of Beirut
% Date  : Jan 2017
%__________________________________________________________________________

NS=length(Hsc(1,:));   %grid points number between the N and S sides
EW=length(Hsc(:,1));   %grid points number between the E and W sides

switch Case
    case 'N'
        HscD    =[    Hsc(n,NS)     Hsc(n+1,NS)];
        ThetacD =[ Thetac(n,NS)  Thetac(n+1,NS)]; 
        PeriodcD=[Periodc(n,NS) Periodc(n+1,NS)];

    case 'E'

        HscD    =[    Hsc(EW,n)     Hsc(EW,n+1)];
        ThetacD =[ Thetac(EW,n)  Thetac(EW,n+1)];
        PeriodcD=[Periodc(EW,n) Periodc(EW,n+1)];                                           
        
    case 'S'
        HscD    =[    Hsc(n+1,1)     Hsc(n+1,1)];
        ThetacD =[ Thetac(n+1,1)  Thetac(n+1,1)];
        PeriodcD=[Periodc(n+1,1) Periodc(n+1,1)];                                      
        
    case 'W'
        HscD    =[    Hsc(1,n+1)     Hsc(1,n+1)];
        ThetacD =[ Thetac(1,n+1)  Thetac(1,n+1)];
        PeriodcD=[Periodc(1,n+1) Periodc(1,n+1)];                                      
end

HscD=nanmean(HscD);
ThetacD=nanmean(ThetacD);
PeriodcD=nanmean(PeriodcD);

end
