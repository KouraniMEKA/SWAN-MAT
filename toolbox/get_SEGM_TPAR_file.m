function [FileName,HscD]=get_SEGM_TPAR_file(Case,n,output_path,tbeginp,tendinp,time_resol,Hs,Theta,Period,dds)

% get_SEGM_TPAR_file() generates a .par file including wave parameters at a
% boundary segment of the computational grid.
% The generated file has the following format:
% _____________________________________
% |TPAR
% |yyyymmdd.hhmmss Hs T Dir dd
% |.
% |.
% _____________________________________

% Inputs:
%   -Case: 'N','S','E' or 'W', indicates the side along which the data is
%    requested.
%   -n: index of the segment along the boundary side (#)
%   -output_path: directory where the generated files should be placed (should not be global)
%   -tbeginp: start time for the requested data (iso)
%   -tendinp: end time for the requested data   (iso)
%   -time_resol: time resolution of the available data (hours)
%   -Hs: Significant wave hight  (4D matrix)
%   -Period: Wave period         (4D matrix)
%   -Theta: wave direction       (4D matrix)
%   -dds: wave direction spread at the boundaries in degrees

%
% Author: Ahmad Kourani, PhD student, American University of Beirut
% Date  : Jan 2017
%__________________________________________________________________________

%% find number of files to be generated
[StartTime,steps]=get_data_time_steps(tbeginp,tendinp,time_resol);
%% Initiate wave boudary files generation:

yy=str2grnum(tbeginp,3,4);
mm=str2grnum(tbeginp,5,6);
dd=str2grnum(tbeginp,7,8);
dd0=1;              %first read file, index is independent of actual day
hh=StartTime;       % actual hours for data reading
date_time=[num2str(yy,'%02i'),num2str(mm,'%02i'),num2str(dd,'%02i'),num2str(hh,'%02i')];    

for t=StartTime:StartTime+steps  %Time loop for single grid point
    Hsc=Hs(:,:,hh+1,dd0); %hh:00-23 hrs                
    Thetac=Theta(:,:,hh+1,dd0);    
    Periodc=Period(:,:,hh+1,dd0);
    [HscD,ThetacD,PeriodcD]=get_wave_parameters(Case,Hsc,Thetac,Periodc,n);
    if ~isnan(HscD)
        if t==StartTime
            FileName=['TPAR',Case,num2str(n,'%03d') '.par'];
            TPARID = fopen([output_path,FileName],'w');
            fprintf(TPARID,['TPAR','\n']);
        end
        print_TPAR_line(TPARID,yy,mm,dd,hh,HscD,PeriodcD,ThetacD,dds);
        if ~mod(t,23)   % each 3D matrix includes data of 1 day (24h),reset at t=23:00
            dd0=1+dd0;     
        end
        [yy,mm,dd,hh]=date_after_hr_time_step(date_time,time_resol);
        date_time=[num2str(yy,'%02i'),num2str(mm,'%02i'),num2str(dd,'%02i'),num2str(hh,'%02i')];
    else
        FileName='blank';
    end % if ~isnan
end % time loop for single segment

if ~isnan(HscD) % create boundary file only for wet grid points
    fclose(TPARID);
end

end