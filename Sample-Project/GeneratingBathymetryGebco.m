function []=GeneratingBathymetryGebco()
% Creating Input Files
% netcdf to wind, TPAR files, and bathymetry
% 2+ files for wind, 1 for TPAR, and 1 for bathymetry

%Bathymetry
BOT=ncread('NCfiles\bathymetry.nc','elevation');
BOT=BOT.';
BOT=flipud(BOT);
BathymetryID = fopen('Inputs\Bathymetry.bot','w');

for i=1:length(BOT(:,1))
    
    fprintf(BathymetryID,'%16g',BOT(i,:));
    fprintf(BathymetryID,'\n');
    
end

fclose(BathymetryID);
end