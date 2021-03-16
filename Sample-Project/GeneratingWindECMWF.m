function []=GeneratingWindECMWF(StartingTime,EndTime)
%ECMWF WIND
WINDU=ncread('NCfiles\windwave.nc','u10');
WINDV=ncread('NCfiles\windwave.nc','v10');
WindSeriesID = fopen('Inputs\Wind\WindSeries.wndini','w');
OriginalTime=20160101.000000;
StartT1=(StartingTime-OriginalTime);
StartT=floor((floor(StartT1)*4+((StartT1-floor(StartT1))/6)*100)+1);
EndT1=(EndTime-OriginalTime);
EndT=floor(((floor(EndT1)*4)+((EndT1-floor(EndT1))/6)*100)+1);

for t=StartT:EndT
    WNDU=WINDU(:,:,t);
    WNDU=WNDU.';
    WNDU=flipud(WNDU);    
    WNDV=WINDV(:,:,t);
    WNDV=WNDV.';
    WNDV=flipud(WNDV);       
    windfile=['WIND' num2str(t,'%03d') '.wnd'];
    fid = fopen( ['Inputs\Wind\' windfile],'w' );

    fprintf(WindSeriesID,'%s',['.\Inputs\Wind\' windfile]);
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

end
fclose(WindSeriesID);
end