function [WindSeries_path]=get_wind_from_ecmwf_nc(wind_nc_name,U,V,output_path,tbeginp,tendinp,index_corr,x0W,y0W,xnW,ynW)
% get_wind_from_ecmwf_nc() function generates wind files for SWAN inputs for
% [idla]=1, a special layout read by SWAN (refere to SWAN userguide for
% descrition). The function is suitable for .nc data provided by ECMWF.
% Any different source of data should be investigated for compatibility,
% and modification in this fuction will be required.
% performe ncdisp('<datafile>.nc') to get required information about the
% data.
%
% Inputs: 
%   -wind_nc_name: directory and name of the input data .nc file
%   -u10: parameter name of the u-component of the wind speed in the .nc file
%   -v10: parameter name of the v-component of the wind speed in the .nc file
%   -wnc_vector_type: specifies if the input wind vector from the .nc file
%   is defined in 'Nautical' or 'Cartesian' Coordinate system. 
%   -output_path: directory where the generated wind data files should be
%   placed.
%   -StartingTime,EndTime: yyyymmddhh...
%   -x0,y0,xn,yn: start and end reading area boundaries inside wind matrices.
%
%
% Outputs:
%   -WindSeries_path: directory of the final file containing the wind data list (input for SWAN) 
% ------------------------------------------------------------------------
% Ahmad Kourani PhD student, American University of Beirut
% April 2017
%-------------------------------------------------------------------------&

disp('Wind files generation process has been initiated...')
time_index=ncread(wind_nc_name,'time')+index_corr;

%% Tranform start & end dates from string to number:

Cyear=str2grnum(tbeginp,1,4);
Cmonth=str2grnum(tbeginp,5,6);
Cday=str2grnum(tbeginp,7,8);
Chour=str2grnum(tbeginp,9,10);
start_index=ECMWF_time2index(Cyear,Cmonth,Cday,Chour);

Cyear=str2grnum(tendinp,1,4);
Cmonth=str2grnum(tendinp,5,6);
Cday=str2grnum(tendinp,7,8);
Chour=str2grnum(tendinp,9,10);
end_index=ECMWF_time2index(Cyear,Cmonth,Cday,Chour);
%% Check wind data availability:
% Assuming available data is continuous:
if start_index>=time_index(1) && end_index<=time_index(length(time_index))
    disp('Wind data is available.');
else
    disp('Wind data is not (fully) available [in time].'); 
    disp('No Wind data is generated!');
    return;  
end
 
%% Import required data from .nc file:

time_resolution=time_index(2)-time_index(1);  %HR, same as the input data time resolution, or a multiplier of it if desired.
U10 = ncread(wind_nc_name,U);
V10 = ncread(wind_nc_name,V);
ss=find(time_index==start_index);

for ii=1:(end_index-start_index)/time_resolution+1
    u(:,:,ii)=fliplr(U10(:,:,ss+ii-1));
    v(:,:,ii)=fliplr(V10(:,:,ss+ii-1));      
    u10(:,:,ii)=u(x0W:xnW,y0W:ynW,ii);
    v10(:,:,ii)=v(x0W:xnW,y0W:ynW,ii);
end

%% Remove problematic data (not handeled by SWAN?)
u10(isnan(u10)) = 0 ;
v10(isnan(v10)) = 0 ;
%% find number of files to be generated
[StartTime,steps]=get_data_time_steps(tbeginp,tendinp,time_resolution);

%% Delete previously available files from Wind inputs directory to prevent confusion:
prompt='Do you want do delete Previously generated wind data files? y/n [y]:';
del = input(prompt,'s');
if isempty(del)
    del = 'y';
end
if del=='y'
    disp('Previously generated wind data files will be deleted!');
    delete([output_path '*.wnd']) %Delete previous wind files from directory 
else
    disp('Previously generated wind data files will be overwritten!');
end


%% Initiate wind files generation:
dd=str2grnum(tbeginp,7,8);
mm=str2grnum(tbeginp,5,6);
yyyy=str2grnum(tbeginp,1,4);
hh=StartTime;       % actual hours for data reading
date_time=[num2str(str2grnum(tbeginp,1,8)),num2str(hh,'%02d')]; % actual date and hour

WindSeriesID = fopen([output_path 'WindSeries.wndini'],'w');

for t=1:steps+1

    WNDU=u10(:,:,t); %hh:00-23 hrs   
    WNDU=WNDU';
    WNDU=flipud(WNDU);
    
    WNDV=v10(:,:,t);
    WNDV=WNDV';
    WNDV=flipud(WNDV);
      
    % individual wind file name:
    windfile=['WIND' num2str(yyyy,'%04d') num2str(mm,'%02d') num2str(dd,'%02d') num2str(hh,'%02d') '.wnd'];
    fid = fopen( [output_path,windfile],'w' );
    % write wind file name inside wind series file:
    fprintf(WindSeriesID,'%s',[output_path,windfile]);
    fprintf(WindSeriesID,'\n');

    for i=1:(length(WNDU(:,1))+length(WNDV(:,1)))
        if i<=length(WNDU(:,1))
            fprintf(fid,'%16g',WNDU(i,:));
            fprintf(fid,'\n');
        else
            fprintf(fid,'%16g',WNDV(i-length(WNDU(:,1)),:));
            fprintf(fid,'\n');  
        end
    end
    fclose(fid);
    
    [yyyy,mm,dd,hh]=date_after_hr_time_step(date_time,time_resolution);
    date_time=[num2str(yyyy,'%02i'),num2str(mm,'%02i'),num2str(dd,'%02i'),num2str(hh,'%02i')];
        
end
fclose(WindSeriesID);
WindSeries_path=[output_path 'WindSeries.wndini'];
disp('Wind data successfully generated!');
end