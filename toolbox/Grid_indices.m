function [x0,xn,y0,yn]=Grid_indices(LatS,LatN,LonW,LonE,Lat,Lon)

% Grid_indices(LatS,LatN,LonW,LonE,Lat,Lon) function returns the indices
% of an earth coordinates systems in a given (lat,lon arrays)
% Inputs:
%   -LatS: South boundary
%   -LatN: North boundary
%   -LonW: West boundary
%   -LonE: East boudary
%   -Lat : reference latiture  array
%   -Lon : reference longitude array
% Outputs:
%   -x0: LonW index
%   -xn: LatS index
%   -y0: LatS index
%   -yn: LatN index
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created by Ahmad Kourani, PhD student, April 2017
% American University of Beirut
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


x0=[];
xn=[];
y0=[];
yn=[];
for ii=1:length(Lat)-1    
    if LatS>=Lat(ii) && LatS<=Lat(ii+1)
        y0=ii;
        break
    end
end
for ii=1:length(Lat)-1    
    if LatN>=Lat(ii) && LatN<=Lat(ii+1)
        yn=ii+1;
        break
    end
end
for ii=1:length(Lon)-1    
    if LonW>=Lon(ii) && LonW<=Lon(ii+1)
        x0=ii;
        break
    end
end
for ii=1:length(Lon)-1    
    if LonE>=Lon(ii) && LonE<=Lon(ii+1)
        xn=ii+1;
        break
    end
end

if isempty(x0) || isempty(xn) || isempty(y0) || isempty(yn)
    disp('Requested boundaries are not within the provided data!')
    return;   
end