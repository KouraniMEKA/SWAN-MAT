function [SWANBOU]=get_reg_BC_SEGM_CYCOFOS(wave_nc_path,output_path,tbeginp,tendinp,time_resol,Wadx,Wady,xpc1,ypc1,xpc2,ypc2,x0,y0,xn,yn,len,dds)

% get_reg_BC_SEGM_CYCOFOS() function generates the wave boundary conditions
% required for a SWAN run. This function supports boundary of type SEGMENT
% and stores the data in seperate files with the TPAR format. Each file
% contains data for a single segment but for every input time step.
% the function returns a SWANBOU vector identifying each segment and  and
% linking it to its proper TPAR file.
% 
% Inputs:
%   -wave_nc_path: directory of the input data .nc file
%   -output_path: directory where the generated files should be placed (should not be global)
%   -tbeginp: start time for the requested data
%   -tendinp: end time for the requested data
%   -time_resol: time resolution of the available data
%   -Wadx,Wady: distance between the grid points of the wave data
%   -xpc1,ypc1,xpc2,ypc2: origin coordinates of the computational grid (m)
%   -x0,y0,xn,yn: % Size of the selected grid
%   -len:
%   -dds:
% Some inputs need to be adjusted if the computation grid and the wave data
% grid do not match.
%
%   Output:
%   -SWANBOU: Vector including the commandes that need to be written in the
%   .swn file.
%   -PAR files for each boundary segment.
%
%   Caution: Recheck the use of xpc1,ypc1,xpc2,ypc2 when necessairy!
%-------------------------------------------------------------------------
% The generation of the TPAR files was originally initiated by the FYP
% group, this fuction buids on their concept.
%
% Author: Ahmad Kourani, PhD student, American University of Beirut.
% Date  : Jan 2017
%-------------------------------------------------------------------------

%% Read Wave files from directory:
% Wave data can be stored in different shapes, and obviously each shape
% nead a specific way to be read. 
% the function search_for_nc_date() will automatically identify the .nc files inside the
% specified directory, and get the dates for which the data is available
% It is assumed that the file names will include the data set date in the
% format: 'yymmdd'

disp('Wave boudary data generation process has been initiated...')
[wave_nc_files_names,all_dates]=search_for_nc_date(wave_nc_path);

%% Check Wave data availability:
tbeg=str2grnum(tbeginp,3,8);
tend=str2grnum(tendinp,3,8);
% Assuming available data is continuous:
if tbeg>=all_dates(1,:) && tend<=all_dates(length(all_dates),:)
    disp('Wave data is available.');
else
    disp('Wave data is not (fully) available.'); 
    disp('No wave boundary data is generated!');
    return;  
end

%% Identify required .nc file:
[req_dates,days]=day_series_calendar(tbeg,tend);
sample_wave_nc_file_name=wave_nc_files_names(1,:);

for ii=1:days
    Hs0    =ncread([wave_nc_path,sample_wave_nc_file_name(1:length(sample_wave_nc_file_name)-(3+6)),req_dates(ii,:),'.nc'],'SWH'); %Significant wave height
    Theta0 =ncread([wave_nc_path,sample_wave_nc_file_name(1:length(sample_wave_nc_file_name)-(3+6)),req_dates(ii,:),'.nc'],'MEANWDIR'); %Meam Wave Direction (Peak is Required!!)
    Period0=ncread([wave_nc_path,sample_wave_nc_file_name(1:length(sample_wave_nc_file_name)-(3+6)),req_dates(ii,:),'.nc'],'MAXWP'); %Peak wave period (for JHONSWAP PEAK)
    Hs(:,:,:,ii)    =Hs0(x0:xn,y0:yn,:);
    Theta(:,:,:,ii) =Theta0(x0:xn,y0:yn,:);
    Period(:,:,:,ii)=Period0(x0:xn,y0:yn,:);
end

%Transform .nc file data from nautical(From) to cartesian(To) Directions for Waves
disp('Input MEANWDIR is assumed to be in deg.');
Theta=270.-Theta;
Theta=Theta+360.*(Theta<0);


%% Inputs read
NS=length(Hs(1,:,1,1));   %grid points number between the N and S sides
EW=length(Hs(:,1,1,1));   %grid points number between the E and W sides

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
y1=(NS-1)*Wady-ypc1-ypc2; 
y2=y1;
len0=len*Wadx;
disp('Writing northern boundary data files..');
for n=1:(EW-1)  %North Side grid points loop         
    x1=(n-1)*Wadx + xpc1;
    x2=  n  *Wadx + xpc1;
    [FileName,HscN]=get_SEGM_TPAR_file(Case,n,output_path,tbeginp,tendinp,time_resol,Hs,Theta,Period,dds);   
    if ~isnan(HscN) % create boundary file only for wet grid points
        SWANBOU0=get_SWANBOU(x1,y1,x2,y2,len0,[output_path,FileName]);
        SWANBOU=[ SWANBOU ;SWANBOU0 ];
    end   
end

%% East side
Case='E';
x1=(EW-1)*Wadx-xpc1-xpc2;
x2=x1;  
len0=len*Wady;
disp('Writing eastern  boundary data files..');
for n=1:(NS-1);  %East Side grid points loop
    y1=(n-1)*Wady + ypc1; 
    y2=  n  *Wady + ypc1;                
    [FileName,HscE]=get_SEGM_TPAR_file(Case,n,output_path,tbeginp,tendinp,time_resol,Hs,Theta,Period,dds);    
    if ~isnan(HscE)
        SWANBOU0=get_SWANBOU(x1,y1,x2,y2,len0,[output_path,FileName]);
        SWANBOU=[ SWANBOU ;SWANBOU0 ];
    end   
end

%% South side
Case='S';
y1=ypc1;
y2=y1;      
len0=len*Wadx;
disp('Writing southern boundary data files..');
for n=1:(EW-1);  %South Side grid points loop
    x1=(n-1)*Wadx + xpc1;
    x2=  n  *Wadx + xpc1;
    [FileName,HscS]=get_SEGM_TPAR_file(Case,n,output_path,tbeginp,tendinp,time_resol,Hs,Theta,Period,dds);                     
    if ~isnan(HscS)
        SWANBOU0=get_SWANBOU(x1,y1,x2,y2,len0,[output_path,FileName]);
        SWANBOU=[ SWANBOU ;SWANBOU0 ];
    end   
end

%% West side 
Case='W';
x1=xpc1;
x2=x1;         
len0=len*Wady;
disp('Writing western  boundary data files..');
for n=1:(NS-1);  %West Side grid points loop
    y1=(n-1)*Wady + ypc1; 
    y2=  n  *Wady + ypc1;                      
    [FileName,HscW]=get_SEGM_TPAR_file(Case,n,output_path,tbeginp,tendinp,time_resol,Hs,Theta,Period,dds);                     
    if ~isnan(HscW)
        SWANBOU0=get_SWANBOU(x1,y1,x2,y2,len0,[output_path,FileName]);
        SWANBOU=[ SWANBOU ;SWANBOU0 ];
    end   
end 

if ~isempty(SWANBOU)
    disp('Wave boundary files successfully generated.')
else
    disp('No wave boundary files has been generated')
end  