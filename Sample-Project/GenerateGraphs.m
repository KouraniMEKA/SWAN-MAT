close all
load('Outputs\BOT.mat')
load('Outputs\Dir.mat')
load('Outputs\H-sig.mat')
load('Outputs\TM01.mat')
load('Outputs\Wind.mat')

figure(1)
contourf(-1*Botlev,'showtext','on');
title('Bathymetry of Our Computational Grid with Wind on Jan 02 at 10am')
hold on
quiver(Windv_x_20160102_100000,Windv_y_20160102_100000,'white')

figure(2)
contourf(Hsig_20160102_100000,'showtext','on');
colorbar
title('Significant wave Height Jan 02 at 10am')

figure(3)
contourf(Dir_20160102_100000,'showtext','on')
title('Peak Direction Jan 02 at 10am')
colorbar

figure(4)
contourf(Tm01_20160102_100000,'showtext','on');
colorbar
title('Mean Period Jan 02 at 10am')


























% figure(1)
% BOT=ncread('NCfiles\bathymetry.nc','elevation');
% BOT=BOT.';
% contourf(BOT,'ShowText','on')
% colorbar
% title('Bathymetry of Our Computational Grid')
% hold on
% 
% WINDU=ncread('NCfiles\windwave.nc','u10');
% WINDV=ncread('NCfiles\windwave.nc','v10');
% WINDU1=WINDU(:,:,1).';
% WINDV1=WINDV(:,:,1).';
% WINDU2=zeros(121,145);
% WINDV2=zeros(121,145);
% 
% y=1;
% for i=1:10
%     x=1;    
% for j=1:11
%     WINDU2(y,x)=WINDU1(i,j);
%     x=x+13;
% end
%    y=y+12;
% end
% y=1;
% for i=1:10
%     x=1;    
% for j=1:11
%     WINDV2(y,x)=WINDU1(i,j);
%     x=x+13;
% end
%    y=y+12;
% end
% scale=10;
% 
% quiver(WINDU2,WINDV2,scale,'white')
% 
% clearvars
% %lAKKIS
% figure(2)
% BOT=ncread('NCfiles\bathymetry.nc','elevation');
% BOT=BOT.';
% contourf(BOT,'ShowText','on')
% colorbar
% title('Bathymetry of Our Computational Grid')
% hold on
% 
% LWINDU=ncread('wrf_grd3_09.nc','U10');
% LWINDV=ncread('wrf_grd3_09.nc','V10');
% LWINDU=LWINDU.';
% LWINDV=LWINDV.';
% LWINDU1=LWINDU(19:52,1:26);
% LWINDV1=LWINDV(19:52,1:26);
% LWINDU2=zeros(121,145);
% LWINDV2=zeros(121,145);
% 
% y=1;
% for i=1:34
%     x=1;    
% for j=1:26
%     LWINDU2(ceil(y),ceil(x)+1)=LWINDU1(i,j);
%     x=x+5.5;
% end
%    y=y+3.5;
% end
% y=1;
% for i=1:34
%     x=1;    
% for j=1:26
%     LWINDV2(ceil(y),ceil(x)+1)=LWINDU1(i,j);
%     x=x+5.5;
% end
%    y=y+3.5;
% end
% scale=3;
% quiver(LWINDU2,LWINDV2,scale,'white')