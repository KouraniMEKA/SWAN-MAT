function [SWANBOU]=get_reg_BC_SIDE_ECMWF(wave_nc_name,output_path,tbeginp,tendinp,x0,xn,y0,yn,dds)

% get_reg_BC_SIDE_ECMWF() function generates the wave boundary conditions
% required for a SWAN run. This function supports boundary of type SIDE
% and stores the data in seperate files with the TPAR format. Each file
% contains data for a single side but for every input time step.
% the function returns a SWANBOU vector identifying each side and 
% linking it to its proper TPAR file.
% 
% Inputs:
%   -wave_nc_path: directory of the input data .nc file
%   -output_path: directory where the generated files should be placed (should not be global)
%   -tbeginp: start time for the requested data
%   -tendinp: end time for the requested data
%   -time_resol: time resolution of the available data
%   -x0,y0,xn,yn: % Size of the selected grid
%   -dds:
% Some inputs need to be adjusted if the computation grid and the wave data
% grid do not match.
%
%   Output:
%   -SWANBOU: Vector including the commandes that need to be written in the
%   .swn file.
%   -PAR files for each boundary segment.
%
%-------------------------------------------------------------------------
% The generation of the TPAR files was originally initiated by the FYP
% group, this fuction buids on their concept.
%
% Author: Ahmad Kourani, PhD student, American University of Beirut.
% Date  : May 2017
%-------------------------------------------------------------------------

%% Read Wave files from directory:
% Wave data can be stored in different shapes, and obviously each shape
% nead a specific way to be read. 
% the function search_for_nc_date() will automatically identify the .nc files inside the
% specified directory, and get the dates for which the data is available
% It is assumed that the file names will include the data set date in the
% format: 'yymmdd'

disp('Wave boudary data generation process has been initiated...')

time_index=ncread(wave_nc_name,'time');

%% Check Wave data availability:
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

% Assuming available data is continuous:
if start_index>=time_index(1) && end_index<=time_index(length(time_index))
    disp('Wave data is available.');
else
    disp('Wave data is not (fully) available.'); 
    disp('No wave boundary data is generated!');
    return;  
end

%% Identify required .nc file:
time_resolution=time_index(2)-time_index(1);  %HR, same as the input data time resolution, or a multiplier of it if desired.
ss=find(time_index==start_index);
ee=(end_index-start_index)/time_resolution;
Hs0    =ncread(wave_nc_name,'swh'); %Significant wave height
Theta0 =ncread(wave_nc_name,'mwd'); %Meam Wave Direction (Peak is Required!!)
Period0=ncread(wave_nc_name,'mwp'); %Peak wave period (for JHONSWAP PEAK)

    Hs =     Hs0(x0:xn,y0:yn,ss:ss+ee);
 Theta =  Theta0(x0:xn,y0:yn,ss:ss+ee);
Period = Period0(x0:xn,y0:yn,ss:ss+ee);



%Transform .nc file data from nautical(From) to cartesian(To) Directions for Waves
disp('Input MEANWDIR is assumed to be in deg.');
Theta=270.-Theta;
Theta=Theta+360.*(Theta<0);

%% Inputs read
NS=size(Hs,2);   %grid points number between the N and S sides
EW=size(Hs,1);   %grid points number between the E and W sides

%% Delete previously available files from wave boundary inputs directory to prevent confusion:
% fIDs = fopen('all');
% for ff=1:length(fIDs)
%     fclose(fIDs(ff));
% end

prompt='Do you want do delete Previously generated wave boundary data files? y/n [y]:';
del = input(prompt,'s');
if isempty(del)
    del = 'y';
end
if del=='y'
    disp('Previously generated wave boundary data files will be deleted!');
    delete([output_path '*.par']) %Delete previous wave boundary files from directory 
else
    disp('Previously generated wave boundary data files will be overwritten!');
end

SWANBOU=[];

%% North side
Case='N';
x=ceil(EW/2);
y=NS;
disp('Writing northern boundary data files..');
[FileName,HscN]=get_TPAR_Side_file(Case,output_path,tbeginp,tendinp,time_resolution,x,y,Hs,Theta,Period,dds);   
if ~isnan(HscN) % create boundary file only for wet grid points
    SWANBOU0=get_SWAN_BOUndspec_Side('N',[output_path,FileName]);
    SWANBOU=[ SWANBOU ;SWANBOU0 ];
end   


%% East side
Case='E';
x=EW;
y=ceil(NS/2);
disp('Writing eastern  boundary data files..');
[FileName,HscE]=get_TPAR_Side_file(Case,output_path,tbeginp,tendinp,time_resolution,x,y,Hs,Theta,Period,dds);
if ~isnan(HscE) % create boundary file only for wet grid points
    SWANBOU0=get_SWAN_BOUndspec_Side('E',[output_path,FileName]);
    SWANBOU=[ SWANBOU ;SWANBOU0 ];
end


%% South side
Case='S';
x=ceil(EW/2);
y=1;
disp('Writing eastern  boundary data files..');
[FileName,HscS]=get_TPAR_Side_file(Case,output_path,tbeginp,tendinp,time_resolution,x,y,Hs,Theta,Period,dds);
if ~isnan(HscS) % create boundary file only for wet grid points
    SWANBOU0=get_SWAN_BOUndspec_Side('S',[output_path,FileName]);
    SWANBOU=[ SWANBOU ;SWANBOU0 ];
end

%% West side 
Case='W';
x=1;
y=ceil(NS/2);
disp('Writing eastern  boundary data files..');
[FileName,HscS]=get_TPAR_Side_file(Case,output_path,tbeginp,tendinp,time_resolution,x,y,Hs,Theta,Period,dds);
if ~isnan(HscS) % create boundary file only for wet grid points
    SWANBOU0=get_SWAN_BOUndspec_Side('W',[output_path,FileName]);
    SWANBOU=[ SWANBOU ;SWANBOU0 ];
end

if ~isempty(SWANBOU)
    disp('Wave boundary files successfully generated.')
else
    disp('No wave boundary files has been generated.')
end  