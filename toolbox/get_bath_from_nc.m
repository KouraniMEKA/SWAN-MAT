function [Reg_Bath_File_Path]=get_bath_from_nc(in_path,depth,lonB,latB,out_path,bath_file_name,k,trans,flip_ud,x0,y0,xn,yn)

% This function creates a .bot bathymetry file from .nc file.
% the created file is a simple text file showing the bathymetric data as 
% a nxm matrix.

% Inputs:
%   -in_path: include the file name with extention (.nc)
%   -elevation:elevation variable name in the .nc file
%   -out_path: output file path and name without extention (.bot)
%   -k: bathymetry coefficient, depth is defined as positive in SWAN,     default: k=1
%   -x0,y0,xn,yn: specifies the borders of size of the matrix to be read, default: max size
%   -transpose: Transpose the bathymetry matrix  (0 or 1)                 default: 1   
%   -flip_ud: Flip up/down the bathymetry matrix,(0 or 1)                 default: 1
%   
%
%
%
% Created by Ahmad Kourani, PhD student, Feb 2016
% American University of Beirut
% 
% Updated: Jan 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ncdisp('NCfiles/AREAwaveDATA/WIND/areaLev_W160425.nc')
% ncdisp('NCfiles/AREAwaveDATA/SWELL/areaLev_S160425.nc')

% BOT=ncread('NCfiles/AREAwaveDATA/WIND/areaLev_W160425.nc','DEPTH');
% BOT=-1.*BOT(xi:xe,yi:ye,1);
disp('Generating regular bathymetry...')

if (nargin <3 || nargin > 13)
    disp('Number of input arguments error!')
    disp('Input format(10): in_path,depth,out_path,bath_file_name,k,trans,flip_ud,x0,y0,xn,yn')
    disp('At least first 3 inputs are required')
    return;
end

if ~exist('k','var')
     k=1;
end

BOT=ncread(in_path,depth);
BOT=BOT(:,:,1);

if ~exist('xn','var') && ~exist('yn','var')
    disp('Generating bathymetry file for the whole available area..');
    x0=1;y0=1;
    xn=size(BOT,1);
    yn=size(BOT,2);
end

BOT=k.*BOT(x0:xn,y0:yn); % adjust the depth sign (+1,-1)

if  ~exist('trans','var')|| trans==1
    BOT=BOT.'; % (x,y)=(y,x)
end

if ~exist('flip_ud','var') || flip_ud==1
    BOT=flipud(BOT); 
end

% To eliminate SWAN errors, BOT should not include NaN

disp('Potential NaN values will be replaced by constant elevation -10 m (land)..');
disp('Potential -ve values will be replaced by constant elevation -10 m (land)..')
% disp('In order to use the EXCEPTION command, the land grid points should have the same value.')
% The effect is reduction in the computational time
BOT(isnan(BOT))=-10;
for i=1:size(BOT,1)
    for j=1:size(BOT,2)       
        if BOT(i,j)<-10 
             BOT (i,j)=-10;                 
        end 
        if and(lonB(j)>35.25,latB(i)<33)
            BOT(size(BOT,1)-i,j)=-10;
        elseif and(lonB(j)>35,latB(i)<31)
            BOT(size(BOT,1)-i,j)=-10;
        end
    end
end

prompt='Do you want do preview generated bathymetry? y/n [y]:';
plot_bath = input(prompt,'s');
if isempty(plot_bath)
    plot_bath = 'y';
end
if plot_bath=='y'
    for i=1:size(BOT,1)
        for j=1:size(BOT,2)
            if BOT(i,j)==-10
                BOT (i,j)=NaN;
            end
%             if lonB(i)>35 && latB(j)<33
%                BOT(i,j)=NaN;
%             end
        end
    end
    BOT_plot=-flipud(BOT);
    contourf(lonB,latB,BOT_plot)
    colormap winter
    caxis([-3000, 0])    
    grid on
end

%% Create .bot file:
BathymetryID = fopen([out_path bath_file_name],'w');

for i=1:length(BOT(:,1))   
     fprintf(BathymetryID,'%16g',BOT(i,:)); 
     fprintf(BathymetryID,'\n');   
end

fclose(BathymetryID);
Reg_Bath_File_Path=[out_path bath_file_name];

if exist(Reg_Bath_File_Path,'file')~=0
    disp('Bathymetry file successfully generated!')
else
    disp('Bathymetry file generation failed!')
end



end