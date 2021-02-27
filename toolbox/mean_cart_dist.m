function [mean_m_per_deg_lon,mean_m_per_deg_lat] = mean_cart_dist(lat)
% function [] = mean_cart_dist()
% calculates the mean distance in m/deg of longitude and latitude
% given the latitude array of area of study
% Input latitude as positve/negative values in degrees
% Returns -99999 if input argument(s) is/are incorrect.
%
% Equations and parameters used in this script are referenced to
% https://en.wikipedia.org/wiki/Latitude
%
% A part of this script is inspired from "pos2_dit.m" by Flora Sun, 
% University of Toronto, Jun 12, 2004. 
%
% Created By Ahmad Kourani, American University of Beirut, Nov 12, 2016.
% ----------------------------------------------------------------------%
%% This part is inspired from "pos2_dit.m" by Flora Sun, University of Toronto, Jun 12, 2004.
for i=1:length(lat)
    if abs(lat)>90  
        mean_m_per_deg_lon = -99999;
        mean_m_per_deg_lat = -99999;
        disp('Degree(s) illegal! distance = -99999');
     return;
    end  
end

%% Main Script
e=sqrt(0.00669437999014); % eccentricity of the earth
a= 6378137.0;             % equatorial radius of the earth (m)
lat_rad=lat.*pi/180;      % convert from degree to radian

Delta_lat=nan(length(lat),1);
Delta_lon=nan(length(lat),1);

for i=1:length(lat)
    % Reference: https://en.wikipedia.org/wiki/Latitude
    Delta_lat(i)=(111132.954-559.822*cos(2*lat_rad(i))+1.175*cos(4*lat_rad(i)));
    Delta_lon(i)=(pi*a*cos(lat_rad(i))/(180*sqrt(1-e^2*sin(lat_rad(i))^2)));    
end
mean_m_per_deg_lon=round( mean(Delta_lon) );
mean_m_per_deg_lat=round( mean(Delta_lat) );

end
%% From http://msi.nga.mil/MSISiteContent/StaticFiles/Calculators/degree.html
% we get:
%      lat(deg)   |    33     |    34   |   35
% ------------------------------------------------
% km_per_deg_lon  |  093.453  | 092.385 |  091.288
% km_per_deg_lat  |  110.904  | 110.922 |  110.941


% Compared to the calculated one:
% mean_km_per_deg_lon= 092.4729
% mean_km_per_deg_lat= 110.9209

% The difference is less than one km in lon