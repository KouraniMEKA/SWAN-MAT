%This code can be used for wind and wave data from ECMWF if data was
%collected from another source edditing is required.
%READ comments carefully before using the code  


format long

StartingTime=20160101.000000; % Starting time of the simulation
EndTime=20160105.000000; %End time of the simulation
Cmesh=5000; %Computational grid distance between grid point (in m)

latB=ncread('NCfiles\Bathymetry.nc','lat');
lonB=ncread('NCfiles\Bathymetry.nc','lon');
lonE=ncread('NCfiles\windwave.nc','longitude');
latE=ncread('NCfiles\windwave.nc','latitude');

%Name of file to be run and project description.
fid = fopen('LebaneseJanRun.swn','w');
fprintf(fid,'%s\n','!***********************  HEADING  ****************************************');
fprintf(fid,'%s\n','Project ''Jan Run'' ''1''');
fprintf(fid,'%s\n','!*********************  MODEL Input  **************************************');

%Mode
fprintf(fid,'%s\n','MODE NONST TWOD');

%Computation Grid
CgridOX=pos2dist(latE(length(latE)-1),lonE(2),latE(length(latE)-1),lonE(1),1);%CgridOX and CgridOY are the origins of the computational grid
CgridOY=pos2dist(latE(length(latE)-1),lonE(2),latE(length(latE)),lonE(2),1);

Wdx=floor(pos2dist(latE(1),lonE(1),latE(1),lonE(2),1)*1000);%Wdx and Wdy are distance between the gridpoints of the Wind.
Wdy=floor(pos2dist(latE(length(latE)-1),lonE(1),latE(length(latE)),lonE(1),1)*1000);

NS=length(latE);
EW=length(lonE);
CgridLY=floor((NS-3)*Wdy);%CgridLY and CgridLX are the lengths of the computational grid
CgridLX=floor((EW-3)*Wdx);

fprintf(fid,'%s\n',['CGRID REG ' num2str(floor(CgridOX*1000)) ' ' num2str(floor(CgridOY*1000)) ' 0 ' num2str(floor(CgridLX)) ' ' num2str(floor(CgridLY)) ...
    ' ' num2str(floor(CgridLX/Cmesh)-1) ' ' num2str(floor(CgridLY/Cmesh)-1) ' CIR 12 0.03 1']); %0.2 is computation with mesh of 200m

%Bathymertry 
GeneratingBathymetryGebco();
BOx=pos2dist(latB(1),lonB(1),latB(1),lonE(1),1)*1000; %BOx and Boy are the origins of the bathymetry. (for our test case Wind grid was bigger than bathymetry)
BOy=pos2dist(latB(1),lonB(1),latE(length(latE)),lonB(1),1)*1000;

Bdx=pos2dist(latB(1),lonB(1),latB(1),lonB(2),1)*1000;%Bdx and Bdy are the distance between the grid points
Bdy=pos2dist(latB(1),lonB(1),latB(2),lonB(1),1)*1000;

fprintf(fid,'%s\n',['INP BOT ' num2str(floor(BOx))  ' ' num2str(floor(BOy)) ' 0 '  num2str(length(lonB)-1) ' ' num2str(length(latB)-1) ...
    ' ' num2str(floor(Bdx)) ' ' num2str(floor(Bdy))]);
fprintf(fid,'%s\n','READ BOT -1 ''.\Inputs\Bathymetry.bot'' ');

%Wind
%The wind files are generated in the following directory .\Inputs\WInd\
GeneratingWindECMWF(StartingTime,EndTime);
fprintf(fid,'%s\n',['INP WI 0 0 0 '  num2str(length(lonE)-1) ' ' num2str(length(latE)-1) ' ' num2str(floor(Wdx)) ' ' num2str(floor(Wdy)) ...
    ' NONSTAT ' num2str(StartingTime) ' ' num2str(6) ' HR ' num2str(EndTime)]);
fprintf(fid,'%s\n','READ WI 1 SERI ''.\Inputs\WInd\WindSeries.wndini'' ');

%Boundary Conditions
fprintf(fid,'%s\n','!*********************** Boundary Conditions *******************************');
% the following function generates the required TPAR files 
%and the SWAN code lines the files are added to the following directory .\Inputs\TPAR\ and the lines are written to BOU.
BOU=GenerateTPAR(StartingTime,EndTime,Wdx,Wdy,floor(CgridOX*1000),floor(CgridOY*1000));
for i=1:length(BOU(:,1))
    fprintf(fid,'%s\n',BOU(i,:));
end

%Numerics
fprintf(fid,'%s\n','!*********************  Numerics  **************************************');
fprintf(fid,'%s\n','PROP BSBT');
fprintf(fid,'%s\n','NUM STOPC NONSTAT 1'); %The higher the number the better the accuracy.I recommend a minimum value of at least 5.
    
%Outputs
% The outputs you want are added here please check the SWAN user manual if
% you want more outputs and remove any that you dont want.
fprintf(fid,'%s\n','!*********************** OUTPUT REQUESTS *******************************');
fprintf(fid,'%s\n',['FRA ''FRA01'' ' num2str(floor(CgridOX*1000)) ' ' num2str(floor(CgridOY*1000)) ' 0 ' num2str(floor(CgridLX)) ' ' num2str(floor(CgridLY))...
    ' ' num2str(floor(CgridLX/Cmesh)-1) ' ' num2str(floor(CgridLY/Cmesh)-1) ]);
fprintf(fid,'%s\n',['BLO ''FRA01'' NOHEAD ''.\Outputs\H-sig.mat'' LAY 3 HS 1 OUTPUT ' num2str(StartingTime) ' 30 MIN']);    %sigificant wave height
fprintf(fid,'%s\n',['BLO ''FRA01'' NOHEAD ''.\Outputs\Dir.mat'' LAY 3 DIR 1 OUTPUT ' num2str(StartingTime) ' 30 MIN']);   %Peak direction
fprintf(fid,'%s\n',['BLO ''FRA01'' NOHEAD ''.\Outputs\TM01.mat'' LAY 3 TM01 1 OUTPUT ' num2str(StartingTime) ' 30 MIN']);  %mean absolute wave period
fprintf(fid,'%s\n',['BLO ''FRA01'' NOHEAD ''.\Outputs\Wind.mat'' LAY 3 WIND 1 OUTPUT ' num2str(StartingTime) ' 30 MIN']);  %WIND
fprintf(fid,'%s\n','BLO ''FRA01'' NOHEAD ''.\Outputs\BOT.mat'' LAY 3 BOTL 1');                             %Bathymetry


%Computation
fprintf(fid,'%s\n','!*********************** Computation *******************************');
fprintf(fid,'%s\n',['COMP NONST ' num2str(StartingTime,'%06f') ' 5 MI ' num2str(EndTime,'%06f')]);
fprintf(fid,'%s\n','STOP');

fclose(fid);
% the following runs swan if you changed the name of the file edit it below
!swanrun LebaneseJanRun& 
clearvars
