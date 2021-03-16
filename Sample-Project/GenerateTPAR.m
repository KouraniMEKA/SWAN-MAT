function [SWANBOU]=GenerateTPAR(StartingTime,EndTime,Wdx,Wdy,Distx,Disty)

%if tool is going to be created change values below currently     current
%origin(34.7E 32.85N) also time should be changed currently time difference
%is 6 hours

Hs=ncread('NCfiles\windwave.nc','swh');
Theta=ncread('NCfiles\windwave.nc','mwd');
Period=ncread('NCfiles\windwave.nc','mwp');
NS=length(Hs(:,1,1));
EW=length(Hs(1,:,1));

OriginalTime=20160100.000000;
StartT1=(StartingTime-OriginalTime);
StartT=floor((floor(StartT1)*4+((StartT1-floor(StartT1))/6)*100));
EndT1=(EndTime-OriginalTime);
EndT=floor(((floor(EndT1)*4)+((EndT1-floor(EndT1))/6)*100));

for i=1:4
    if i==1 %North side
        for n=1:NS-3;
            
            x1=floor((n-1)*Wdx+Distx);
            x2=floor(n*Wdx+Distx);
            y1=floor(Wdy*(EW-3)+Disty); 
            y2=y1;
            FileName=['TPARN' num2str(n,'%03d') '.par'];
            TPARID = fopen(['Inputs\TPAR\' FileName],'w');
            fprintf(TPARID,'%s','TPAR');
            fprintf(TPARID,'\n');
            
            time=StartingTime;                   % start time of the data 
            for t=StartT:EndT

                Hsc=Hs(:,:,t);
                Hsc=Hsc.';
                HscN=[Hsc(2,n+1) Hsc(2,n+2)];
                HscN=nanmean(HscN);

                Thetac=Theta(:,:,t);
                Thetac=Thetac.';
                ThetacN=[Thetac(2,n+1) Thetac(2,n+2)];
                ThetacN=nanmean(ThetacN);

                Periodc=Period(:,:,t);
                Periodc=Periodc.';
                PeriodcN=[Periodc(2,n+1) Periodc(2,n+2)];
                PeriodcN=nanmean(PeriodcN);

                fprintf(TPARID,'%6f',time);
                fprintf(TPARID,'%16g',HscN);
                fprintf(TPARID,'%16g',PeriodcN);
                fprintf(TPARID,'%16g',ThetacN);                  
                fprintf(TPARID,'\n');

                if (time-floor(time))>=0.17 % Afte 18:00 the next data is at midnight next day, if time between each point is different this shouldbe changed
                    time=floor(time)+1;            
                else 
                    time=time+0.06;         %0.06 difference between each reading in ECMWF it is 6 hours
                end
            end
            fclose(TPARID); 
            if n==1
               SWANBOU=['BOU SEGM XY ' num2str(x1,'%06d') ' ' num2str(y1,'%06d') ' ' num2str(x2,'%06d') ' ' num2str(y2,'%06d')...
                   ' VAR FILE ' num2str(0) ' ''.\Inputs\TPAR\' FileName ''' '];
            else
               SWANBOU=[ SWANBOU ;['BOU SEGM XY ' num2str(x1,'%06d') ' ' num2str(y1,'%06d') ' ' num2str(x2,'%06d') ' ' num2str(y2,'%06d')...
                   ' VAR FILE ' num2str(0) ' ''.\Inputs\TPAR\' FileName ''' '] ];
            end
        end
    else if i==2 %East side
            for n=1:EW-3;
            
                x1=floor((NS-3)*Wdx+Distx);
                x2=x1;
                y1=floor(Wdy*(n-1)+Disty); 
                y2=floor(Wdy*(n)+Disty);
                FileName=['TPARE' num2str(n,'%03d') '.par'];
                TPARID = fopen(['Inputs\TPAR\' FileName],'w');
                fprintf(TPARID,'%s','TPAR');
                fprintf(TPARID,'\n');

                time=StartingTime;                   % start time of the data 
                for t=StartT:EndT

                    Hsc=Hs(:,:,t);
                    Hsc=Hsc.';
                    HscE=[Hsc(EW-n,NS-1) Hsc(EW-(n+1),NS-1)];
                    HscE=nanmean(HscE);

                    Thetac=Theta(:,:,t);
                    Thetac=Thetac.';
                    ThetacE=[Thetac(EW-n,NS-1) Thetac(EW-(n+1),NS-1)];
                    ThetacE=nanmean(ThetacE);

                    Periodc=Period(:,:,t);
                    Periodc=Periodc.';
                    PeriodcE=[Periodc(EW-n,NS-1) Periodc(EW-(n+1),NS-1)];
                    PeriodcE=nanmean(PeriodcE);

                    fprintf(TPARID,'%6f',time);
                    fprintf(TPARID,'%16g',HscE);
                    fprintf(TPARID,'%16g',PeriodcE);
                    fprintf(TPARID,'%16g',ThetacE);                  
                    fprintf(TPARID,'\n');
                    % Afte 18:00 the next data is at midnight next day, if time between each point is different this shouldbe changed
                    if (time-floor(time))>=0.17 
                        time=floor(time)+1;            
                    else 
                        time=time+0.06;         %0.06 difference between each reading in ECMWF it is 6 hours
                    end
                end
                fclose(TPARID); 
                
                SWANBOU=[ SWANBOU ;['BOU SEGM XY ' num2str(x1,'%06d') ' ' num2str(y1,'%06d') ' ' num2str(x2,'%06d')...
                    ' ' num2str(y2,'%06d') ' VAR FILE ' num2str(0) ' ''.\Inputs\TPAR\' FileName ''' '] ];
            end
        else if i==3                %South side
                for n=1:NS-3;

                    x1=floor(Wdx*(n-1)+Distx);
                    x2=floor(Wdx*n+Distx);
                    y1=floor(Disty);
                    y2=y1;
                    FileName=['TPARS' num2str(n,'%03d') '.par'];
                    TPARID = fopen(['Inputs\TPAR\' FileName],'w');
                    fprintf(TPARID,'%s','TPAR');
                    fprintf(TPARID,'\n');

                    time=StartingTime;                   % start time of the data 
                    for t=StartT:EndT

                        Hsc=Hs(:,:,t);
                        Hsc=Hsc.';
                        HscS=[Hsc(EW-1,n+1) Hsc(EW-1,n+2)];
                        HscS=nanmean(HscS);

                        Thetac=Theta(:,:,t);
                        Thetac=Thetac.';
                        ThetacS=[Thetac(EW-1,n+1) Thetac(EW-1,n+2)];
                        ThetacS=nanmean(ThetacS);

                        Periodc=Period(:,:,t);
                        Periodc=Periodc.';
                        PeriodcS=[Periodc(EW-1,n+1) Periodc(EW-1,n+2)];
                        PeriodcS=nanmean(PeriodcS);

                        fprintf(TPARID,'%6f',time);
                        fprintf(TPARID,'%16g',HscS);
                        fprintf(TPARID,'%16g',PeriodcS);
                        fprintf(TPARID,'%16g',ThetacS);                  
                        fprintf(TPARID,'\n');
                        % Afte 18:00 the next data is at midnight next day, if time between each point is different this shouldbe changed
                        if (time-floor(time))>=0.17 
                            time=floor(time)+1;            
                        else 
                            time=time+0.06;         %0.06 difference between each reading in ECMWF it is 6 hours
                        end
                    end
                    fclose(TPARID); 

                    SWANBOU=[ SWANBOU ;['BOU SEGM XY ' num2str(x1,'%06d') ' ' num2str(y1,'%06d') ' ' num2str(x2,'%06d')...
                        ' ' num2str(y2,'%06d') ' VAR FILE ' num2str(0) ' ''.\Inputs\TPAR\' FileName ''' '] ];
                end
            else if i==4 %West side 
                    for n=1:EW-3;

                        x1=floor(Distx);
                        x2=x1;
                        y1=floor(Wdy*(n-1)+Disty); 
                        y2=floor(Wdy*n+Disty);
                        FileName=['TPARW' num2str(n,'%03d') '.par'];
                        TPARID = fopen(['Inputs\TPAR\' FileName],'w');
                        fprintf(TPARID,'%s','TPAR');
                        fprintf(TPARID,'\n');

                        time=StartingTime;                   % start time of the data 
                        for t=StartT:EndT

                            Hsc=Hs(:,:,t);
                            Hsc=Hsc.';
                            HscW=[Hsc(EW-n,2) Hsc(EW-(n+1),2)];
                            HscW=nanmean(HscW);

                            Thetac=Theta(:,:,t);
                            Thetac=Thetac.';
                            ThetacW=[Thetac(EW-n,2) Thetac(EW-(n+1),2)];
                            ThetacW=nanmean(ThetacW);

                            Periodc=Period(:,:,t);
                            Periodc=Periodc.';
                            PeriodcW=[Periodc(EW-n,2) Periodc(EW-(n+1),2)];
                            PeriodcW=nanmean(PeriodcW);

                            fprintf(TPARID,'%6f',time);
                            fprintf(TPARID,'%16g',HscW);
                            fprintf(TPARID,'%16g',PeriodcW);
                            fprintf(TPARID,'%16g',ThetacW);                  
                            fprintf(TPARID,'\n');
                            
                            % Afte 18:00 the next data is at midnight next day, if time between each point is different this shouldbe changed
                            if (time-floor(time))>=0.17 
                                time=floor(time)+1;            
                            else 
                                time=time+0.06;         %0.06 difference between each reading in ECMWF it is 6 hours
                            end
                        end
                        fclose(TPARID); 

                        SWANBOU=[ SWANBOU ;['BOU SEGM XY ' num2str(x1,'%06d') ' ' num2str(y1,'%06d') ' ' num2str(x2,'%06d') ' ' num2str(y2,'%06d') ...
                            ' VAR FILE ' num2str(0) ' ''.\Inputs\TPAR\' FileName ''' '] ];
                    end
                end
            end
        end
    end
end
end      