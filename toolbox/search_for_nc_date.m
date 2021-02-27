function [nc_file_name,date]=search_for_nc_date(nc_path)

%% Read wind files from directory:
% Wind data can be stored in different shapes, and obviously each shapes
% nead a specific way to be read. 
% This Code will try to handel data stored in .nc files, as 1 day data per
% file. The code will automatically identify the .nc files inside the
% specified directory.
% It is assumed that the file names will include the data date in the
% format: 'yymmdd'

% Created by Ahmad Kourani, PhD student, American University of Beirut
% Jan 2017
%------------------------------------------------------------------------%
count=0;
nc_file_name=[];
listing = dir(nc_path);
for ii=1:length(listing)
    %exclude irrelevant components:
    if length(listing(ii).name)>3
        %check file extention (.nc):
        if strcmp(listing(ii).name(length(listing(ii).name)-2:length(listing(ii).name)),'.nc')
            count=1+count;
            %read .nc file name:
            nc_file=listing(ii);
            nc_file_name0=nc_file.name;
            %search for digits in the name to find the date of the data:
            tf = isstrprop(nc_file_name0, 'digit');
            temp0=[];
            for jj=1:length(tf)
               if tf(jj)==1
                   temp0=[temp0,nc_file_name0(jj)];
               end
            end
            %sort the dates in a single matrix:
            date(count,:)=str2double(temp0); 
            nc_file_name=[nc_file_name ; nc_file_name0];
        end
    end    
end

date=sort(date); % Sort array in ascending order
end
