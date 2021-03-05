function []=print_TPAR_line(TPARID,yyyy,mm,dd,hh,HscD,PeriodcD,ThetacD,dds)

% print_TPAR_line() prints the wave information for a single time step in
% the TPAR format: yyyymmdd.hhmmss Hs T Dir dd
% Inputs:
%   -TPARID: .par file name
%   -yyyy: year
%   -mm: month
%   -dd: day
%   -hh: hour
%   -HscD    : Hsig           , single value
%   -PeriodcD: wave direction , single value
%   -ThetacD : wave period    , single value
%   -dds     : direction spread at the boundaries in degree
%   -
% The function supports dates any date with a resolution of 1 hour.
%
%Caution! 
% -Adding excess free spaces will prevent successull SWAN run!
% -using unequal or small spacing may produce errors! 
%__________________________________________________________________________
%
% Author: Ahmad Kourani, PhD student, American University of Beirut
% Date: Jan 2017
%__________________________________________________________________________

if ~isnan(HscD) % create boundary file only for wet grid points
    iso_date_time=iso_notation_time(yyyy,mm,dd,hh); %current date and hour      
    fprintf(TPARID,iso_date_time); % don't add space here!
    fprintf(TPARID,'%10g',HscD);
    fprintf(TPARID,'%10g',PeriodcD);
    fprintf(TPARID,'%10g',ThetacD); 
    fprintf(TPARID,'%10g',dds); 
    fprintf(TPARID,'\n');                
end

end