function []=write_SWAN(Base_Workspace)
%% Write_SWAN
% Write_SWAN_CYCOFOS() builds the the input data into the .swn file format
% Since the number of input arguments is large, it was best found to save
% the base workspace as a .mat file then load it again in this function.
% This function does not include every option available in SWAN, but the
% relevant ones for the cases within the focus of our research.
% This function is not independent of the inputs script.
% Input:
%    -Base_Workspace: base workspace file name (without extension)
% Output:
%    -.swn file, to be excuted by swanrun.
%
% Author: Ahmad Kourani, PhD student, American University of Beirut
% Date: Jan 2017
%-------------------------------------------------------------------------%
load(Base_Workspace)

%% Name of file to be run and project description.
fid = fopen([SWAN_fname '.swn'],'w');
fprintf(fid,'%s\n','!**********************************  HEADING  **********************************');
fprintf(fid,'%s\n',['Project ''' Project_Name ''' ''' nr '''']);
fprintf(fid,'%s\n',['''' title1 '''']);
fprintf(fid,'%s\n',['SET ' Set_CS]);
fprintf(fid,'%s\n','!********************************  MODEL Input  ********************************');

%% Mode
fprintf(fid,'%s\n',['MODE ' Mode ' TWOD']);
fprintf(fid,'%s\n',['COORDINATES '  CoordSys ' ' Projection ' ']);

%% Computation Grid
if strcmp(CGRID_type,'Regular')
    fprintf(fid,'%s\n',['CGRID REG ' num2str(xpc1) ' ' num2str(ypc1) ' 0 ' num2str(xlenc) ' ' num2str(ylenc) ...
                        ' ' num2str(mxc) ' ' num2str(myc) ' CIR ',mdc,f_low,f_high]);
             
elseif strcmp(CGRID_type,'Curvilinear')                     
    fprintf(fid,'%s\n',['CGRID CURV '  ' ' num2str(mxc) ' ' num2str(myc) ' CIR ',mdc,f_low,f_high]);
    fprintf(fid,'%s\n',['READ COOR '  CurvGrid]);

                                        
%%% Unstructured GRID:                    
elseif strcmp(CGRID_type,'Unstructured')   
    fprintf(fid,'%s\n',['CGRID UNSTRUC CIR ',mdc,f_low,f_high]); 
    fprintf(fid,'%s\n',['READ  UNSTRUC TRIANGLE ''./' Triangle_base_name ''' ']);
end

%% Bathymertry 

if strcmp(CGRID_type,'Regular') 
    fprintf(fid,'%s\n',['INP   BOT ' num2str(BOx) ' ' num2str(BOy) ' 0 ' num2str(length(lonB)-1) ...
                              ' ' num2str(length(latB)-1)  ' ' num2str(Bdx) ' ' num2str(Bdy)]);
    % ' EXC -10'
    fprintf(fid,'%s\n',['READ  BOT 1 ''' Reg_Bath_File_Path ''' ']);

elseif strcmp(CGRID_type,'Unstructured')
    fprintf(fid,'%s\n','INP   BOT UNSTRUC');
    fprintf(fid,'%s\n',['READ  BOT 1 ''' Unstr_Bath_File_Path ''' ']); %[''./' filename ''' ']
end

%% Wind
if strcmp(Wind,'on')
    fprintf(fid,'%s\n',['INP   WI ' num2str(WOx) ' ' num2str(WOy) ' 0 '  num2str(length(lonW)-1) ' ' num2str(length(latW)-1) ...
        ' ' num2str(Wdx) ' ' num2str(Wdy) ' NONSTAT ' tbeginp ' ' deltinp ' ' tendinp]);
    fprintf(fid,'%s\n',['READ  WI      1 SERI ''' WindSeries_path ''' 1']);
end
%% Current 
% fprintf(fid,'%s\n',['INP   CURRENT 0 0 0 '  num2str(length(lonW)-1) ' ' num2str(length(latW)-1) ...
%     ' ' num2str(Wdx) ' ' num2str(Wdy) ' NONSTAT ' tbeginp ' ' deltinp ' ' tendinp]);
% fprintf(fid,'%s\n','READ  CURRENT 1 SERI ''./Inputs/Current/CurrentSeries.curini'' 1');

%% Boundary Conditions

fprintf(fid,'%s\n','!***************************** Boundary Conditions *****************************');
fprintf(fid,'%s\n',['BOU SHAP JON ' num2str(gama) ' PEAK DSPR DEGR']); %Default? (DEGR is not difault I think)

% fprintf(fid,'%s\n','BOU SIDE 1 CON PAR 1 5 0 ');

if ~strcmp(Boundary,'disable')  
    for i=1:length(BOU(:,1))
        fprintf(fid,'%s\n',BOU(i,:));
    end
end
%% Physics
fprintf(fid,'%s\n','!**********************************  Physics  **********************************');
fprintf(fid,'%s\n',['FRIC JON CON ' num2str(cfjon) ]);% Remove if bottom friction is not to be included
fprintf(fid,'%s\n','INITial ZERO '); %Set initial condition to zero
fprintf(fid,'%s\n','GEN3 KOMEN AGROW '); % the waves can grow from zero initial conditions due to wind using Cavaleri Malanotte(1981) Wave Growth Term
if strcmp(Wind,'off')
    fprintf(fid,'%s\n','OFF QUAD ');
end
% fprintf(fid,'%s\n','GEN3 JANSsen 4.5 AGROW'); % Wind effect is hiegher

%% Numerics
fprintf(fid,'%s\n','!*********************************  Numerics  **********************************');
%%%%%%%%%% Unstructured Grid
% fprintf(fid,'%s\n','PROP BSBT'); %Use BSBT for sharp transition in the grid (Unstructured??)
if strcmp(BSBP,'on')
    fprintf(fid,'%s\n','PROP BSBT ');
end
fprintf(fid,'%s\n',['NUM STOPC NONSTAT ', mxitns]); 

%% Outputs
% The desired outputs are added here please check the SWAN user manual for outputs options
fprintf(fid,'%s\n','!******************************* OUTPUT REQUESTS *******************************');

FRAM01=[Out_Loc_Type,'''' Frame_name ''' ', xpfr, ypfr, alpfr, xlenfr, ylenfr,mxfr,myfr];
fprintf(fid,'%s\n',FRAM01);
FRAM02=[];
% Recheck this FRA02, should be flexible, calculate borders refering to (lon,lat)coordinates
% FRAM02='FRA ''FRA02'' 155000 65000 0 30000 30000 120 120';
% fprintf(fid,'%s\n',FRAM02);
% FRAM03_Unstr=['NGRid ''' sname_unstr ''' UNSTRUCtured TRIAngle ''' [CGRID_path,fname_unstr] ''''];
% fprintf(fid,'%s\n',FRAM03_Unstr);
% NESTOUT=['NESTout ''' sname_unstr ''' ''' fname_unstr_out ''' OUT ',tbegnst,deltnst];%'fname' OUTput [tbegnst] [deltnst]];
% fprintf(fid,'%s\n',NESTOUT);
BLOCK=[];
for ii=1:length(fname)
    fname_ii=['''' fname{ii,:} '.mat'' '];
    BLOCK=[BLOCK;{Write_Com,'''' Frame_name ''' ',Head_op,fname_ii,'LAY ',idla,[Output_ID{ii} ' '],unit,'OUTPUT ',tbegblk,deltblk}];
end
for ii=1:size(BLOCK,1)
    BLOCK_ii=[BLOCK{ii,:}];
    fprintf(fid,'%s\n',BLOCK_ii);
end



%% Computation
fprintf(fid,'%s\n','!********************************* Computation *********************************');
fprintf(fid,'%s\n',['COMP NONST ' tbeginp,deltc,tendinp]);
fprintf(fid,'%s\n','HOTFile ''Initial_Condition'' FREE');
fprintf(fid,'%s\n','STOP');

fclose(fid);
%% the following runs swan if you changed the name of the file edit it below
% fprintf('Please Delete last South Boundary line in .SWN before proceeding!')
% pause
% !swanrun 01_New_Tests& 
% clearvars
