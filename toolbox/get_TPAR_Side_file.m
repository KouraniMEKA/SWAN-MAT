function [FileName,HscD]=get_TPAR_Side_file(Case,output_path,tbeginp,tendinp,time_resol,x,y,Hs,Theta,Period,dds)

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
%   -output_path: directory where the generated files should be placed (should not be global)
%   -tbeginp: start time for the requested data (iso)
%   -tendinp: end time for the requested data   (iso)
%   -time_resol: time resolution of the available data (hours)
%   -Hs: Significant wave hight  (4D matrix)
%   -Period: Wave period         (4D matrix)
%   -Theta: wave direction       (4D matrix)
%   -dds: wave direction spread at the boundaries in degrees

%% find number of files to be generated
[StartTime,steps]=get_data_time_steps(tbeginp,tendinp,time_resol);
%% Initiate wave boudary files generation:

yyyy=str2grnum(tbeginp,1,4);
mm=str2grnum(tbeginp,5,6);
dd=str2grnum(tbeginp,7,8);
hh=StartTime;       % actual hours for data reading
date_time=[num2str(yyyy,'%02i'),num2str(mm,'%02i'),num2str(dd,'%02i'),num2str(hh,'%02i')];    

for t=1:steps+1  %Time loop for single grid point
    HscD=Hs(x,y,t); %hh:00-23 hrs                
    ThetacD=Theta(x,y,t);    
    PeriodcD=Period(x,y,t);
    if ~isnan(HscD)
        if t==1
            FileName=['TPAR' Case '.par'];
            TPARID = fopen([output_path,FileName],'w');
            fprintf(TPARID,['TPAR','\n']);
        end
        print_TPAR_line(TPARID,yyyy,mm,dd,hh,HscD,PeriodcD,ThetacD,dds);
        [yyyy,mm,dd,hh]=date_after_hr_time_step(date_time,time_resol);
        date_time=[num2str(yyyy,'%02i'),num2str(mm,'%02i'),num2str(dd,'%02i'),num2str(hh,'%02i')];
    else
        FileName='blank';
    end % if ~isnan
end % time loop for single segment

if ~isnan(HscD) % create boundary file only for wet grid points
    fclose(TPARID);
end

end