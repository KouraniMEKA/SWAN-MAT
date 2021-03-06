function [WindSeries_path]=get_wind_from_cycofos_nc(wind_nc_path,WindDir,WindSpeed,wnc_vector_type,output_path,tbeginp,tendinp,x0,y0,xn,yn)
% get_cycofos_wind_from_nc() function generates wind files for SWAN inputs for
% [idla]=1, a special layout read by SWAN (refere to SWAN userguide for
% descrition). The function is suitable for .nc data provided by CYCOFOS.
% Any different source of data should be investigated for compatibility,
% and modification in this fuction will be required.
% performe ncdisp('NCfiles/AREAwaveDATA/WIND/areaLev_W160425.nc') to get
% required information about the .nc files
%
% Inputs: 
%   -wind_nc_path: directory of the input data .nc file
%   -WindDir: parameter name of the wind direction in the .nc file
%   -WindSpeed: parameter of the wind speed in the .nc file
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
% The function was originaly created by the FYP group but with minimum capabilities. Major updates are curently applied. 
%
% Ahmad Kourani PhD student, American University of Beirut
% Jan 2017
%-------------------------------------------------------------------------&
%% Read wind files from directory:
% Wind data can be stored in different shapes, and obviously each shape
% nead a specific way to be read. 
% the function search_for_nc_date() will automatically identify the .nc files inside the
% specified directory, and get the dates for which the data is available
% It is assumed that the file names will include the data date in the
% format: 'yymmdd'
disp('Wind files generation process has been initiated...')
[wind_nc_files_names,all_dates]=search_for_nc_date(wind_nc_path);

%% Tranform start & end dates from string to number:
%exclude irrelevant numbers,data is stored as 1 day data/file
tbeg=str2grnum(tbeginp,3,8);
tend=str2grnum(tendinp,3,8);

%% Check wind data availability:
% Assuming available data is continuous:
if tbeg>=all_dates(1,:) && tend<=all_dates(length(all_dates),:)
    disp('Wind data is available.');
else
    disp('Wind data is not (fully) available [in time].'); 
    disp('No Wind data is generated!');
    return;  
end

%% Identify required .nc file:
[req_dates,days]=day_series_calendar(tbeg,tend);
sample_wind_nc_file_name=wind_nc_files_names(1,:);

for ii=1:days
    WINDDIR0  =ncread([wind_nc_path,sample_wind_nc_file_name(1:length(sample_wind_nc_file_name)-(3+6)),req_dates(ii,:),'.nc'],WindDir);
    WINDSPEED0=ncread([wind_nc_path,sample_wind_nc_file_name(1:length(sample_wind_nc_file_name)-(3+6)),req_dates(ii,:),'.nc'],WindSpeed);
    WINDDIR(:,:,:,ii)=WINDDIR0(x0:xn,y0:yn,:);
    WINDSPEED(:,:,:,ii)=1*WINDSPEED0(x0:xn,y0:yn,:);
end

%% Select Vector Type for wind data
disp('Input WINDDIR is assumed to be in deg.');
if strcmp(wnc_vector_type,'Nautical')
%Nautical:
    WINDU=1*WINDSPEED.*sind(WINDDIR-180);
    WINDV=1*WINDSPEED.*cosd(WINDDIR-180);
elseif strcmp(wnc_vector_type,'Cartesian')
%Cartesian:
    WINDV=WINDSPEED.*cosd(WINDDIR);
    WINDU=WINDSPEED.*sind(WINDDIR);
else
    disp('Incorrect format for input ''vector_type''! Choose ''Nautical'' or ''Cartesian'' ');
    disp('No Wind data has been generated!')
    return;
end

%% Remove problematic data (not handeled by SWAN?)
WINDU(isnan(WINDU)) = 0 ;
WINDV(isnan(WINDV)) = 0 ;
%% find number of files to be generated
time_resol=1; %HR, same the input data time resolution, or a multiplier of it if desired.
[StartTime,steps]=get_data_time_steps(tbeginp,tendinp,time_resol);

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
dd0=1;              %first read file, index is independent of actual day
dd=str2grnum(tbeginp,7,8);
mm=str2grnum(tbeginp,5,6);
yy=str2grnum(tbeginp,3,4);
hh=StartTime;       % actual hours for data reading
date_time=[num2str(str2grnum(tbeginp,3,8)),num2str(hh,'%02d')]; % actual date and hour

WindSeriesID = fopen([output_path 'WindSeries.wndini'],'w');

for t=StartTime:StartTime+steps

    WNDU=WINDU(:,:,hh+1,dd0); %hh:00-23 hrs   
    WNDU=WNDU.';
    WNDU=flipud(WNDU);
    
    WNDV=WINDV(:,:,hh+1,dd0);
    WNDV=WNDV.';
    WNDV=flipud(WNDV);       
    % individual wind file name:
    windfile=['WIND' num2str(yy,'%02d') num2str(mm,'%02d') num2str(dd,'%02d') num2str(hh,'%02d') '.wnd'];
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
    
    if ~mod(t,23)   % each 3D matrix includes data of 1 day (24h),reset at t=23:00
        dd0=1+dd0;     
    end
    [yy,mm,dd,hh]=date_after_hr_time_step(date_time,time_resol);
    date_time=[num2str(yy,'%02i'),num2str(mm,'%02i'),num2str(dd,'%02i'),num2str(hh,'%02i')];
        
end
fclose(WindSeriesID);
WindSeries_path=[output_path 'WindSeries.wndini'];
disp('Wind data successfully generated!');
end