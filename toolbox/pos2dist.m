function dist = pos2dist(lat1,lon1,lat2,lon2,mean_lontom,mean_lattom,method)
% function dist = pos2dist(lag1,lon1,lag2,lon2,method)
% calculates distance between two points on earth's surface
% given by their latitude-longitude pair.
% Inputs lat1,lon1,lat2 and lon2 are in degrees, without 'NSWE' indicators.
% Input method is 1 or 2. Default is 1.
%
% **Method 1: Equirectangular approximation
% uses plane approximation, only for points within several tens of kilometers 
% (angles in rads):
% d = sqrt(R_equator^2*(lat1-lat2)^2 + R_polar^2*(lon1-lon2)^2*cos((lat1+lat2)/2)^2)
%
% **Method 2: Spherical Law of Cosines
% calculates sphereic geodesic distance for points farther apart,
% but ignores flattening of the earth:
% d =
% R_aver * acos(cos(lat1)cos(lat2)cos(lon1-lon2)+sin(lat1)sin(lat2))
% Output dist is in km.
% Returns -99999 if input argument(s) is/are incorrect.
% Flora Sun, University of Toronto, Jun 12, 2004.
%-------------------------------------------------------------------
% Edited by Ahmad Kourani, PhD student, American University of Beirut
% Method 3 is added: uses (mean_lontom,mean_lattom) to calculare planar
% distances linearily.
% Nov 2016
%-------------------------------------------------------------------
% Method 2 editted: use (sind(),cosd()) instead of (sin(),cos())
%
% Detailed information about the methods used can be found in:
% http://www.movable-type.co.uk/scripts/latlong.html
%
% A more accurate formula is also available on:
% http://www.movable-type.co.uk/scripts/latlong-vincenty.html
% Vincenty solutions of geodesics on the ellipsoid can give accuracy for up
% to 0.5mm.
% it is advised to used the webpage to find the values manually and compare
% them with the results of this script. By experiment, the distances allong
% the x-axis (~1m/1km at 33N) are more accurate relative to distances on the 
% y-axis (~3m/1km at 33N)when
% compared to the Vincenty method.
% Date: Jan 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 6
    dist = -99999;
    disp('Number of input arguments error! distance = -99999');
    return;
end
if abs(lat1)>90 || abs(lat2)>90 || abs(lon1)>360 || abs(lon2)>360
    dist = -99999;
    disp('Degree(s) illegal! distance = -99999');
    return;
end
if lon1 < 0
    lon1 = lon1 + 360;
end
if lon2 < 0
    lon2 = lon2 + 360;
end
% Default method is 1.
if nargin == 6
    method = 1;
end

if method == 1
    km_per_deg_la = 111.3237;
    km_per_deg_lo = 111.1350;
    km_la = km_per_deg_la * (lat1-lat2);
    % Always calculates the shorter arc.
    if abs(lon1-lon2) > 180
        dif_lo = abs(lon1-lon2)-180;
    else
        dif_lo = abs(lon1-lon2);
    end
    km_lo = km_per_deg_lo * (dif_lo) * cosd( (lat1+lat2)/2 );
    dist = sqrt(km_la^2 + km_lo^2);
    
elseif method == 2
    R_aver = 6374;
    dist = R_aver * acos(cosd(lat1)*cosd(lat2)*cosd(lon1-lon2) + sind(lat1)*sind(lat2));

elseif method == 3
    km_per_deg_la = mean_lattom/1000;     %Calculated: 110.9209 
    km_per_deg_lo = mean_lontom/1000;     %Calculated: 092.4729    
    % Always calculate the shorter arc.
    km_la = km_per_deg_la * (lat1-lat2);
    if abs(lon1-lon2) > 180
        dif_lo = abs(lon1-lon2)-180;
    else
        dif_lo = abs(lon1-lon2);
    end
    km_lo = km_per_deg_lo * (dif_lo) * cosd( abs(lat1-lat2) );
    dist = sqrt(km_la^2 + km_lo^2);
    
end
    
end