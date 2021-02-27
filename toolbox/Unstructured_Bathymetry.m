function [Output_FileName]=Unstructured_Bathymetry(file_name,output_path)

% Unstructured_Bathymetry(file_name) generates a .bot file including an
% array of bathymetric data, sorted in the same order as the corresponding
% .node file given in the input.
% Input the base file name of the .node and the .ele files available in the
% working directory, or give the full path elsewhere.
% 
% This is not a standard function, and be should modified for each case.
% It can give an insight on how to modify the .node and .ele file and extract
% meaningfull data from them.
%
% Created by Ahmad Kourani, PhD student, American University of Beirut.
% Dec 2016

%-------------------------------------------------------------------------%

disp(['This is not a standard function, and be should modified for each case ..'...
      'It can give an insight on how to modify the .node and .ele file and extract ' ...
      'meaningfull data from them.'])
%% Read .node file
% file_name='Contour_122708_triangle.3';% remove when done editing!
fileID=fopen([file_name '.node'],'r');
[nsize,~]=fscanf(fileID,'%d',1);    % Read data length
nothing=fgetl(fileID);              % Move to next line
Node = zeros(nsize, 5);
for i=1:nsize
    Node(i,:)=fscanf(fileID,'%g',[5 1]); % Read in specific format
    nothing=fgetl(fileID);               % Move to next line
end
fclose(fileID);

Node_cor=Node;
%% Read .ele file

fileID=fopen([file_name '.ele'],'r');
[esize,~]=fscanf(fileID,'%d',1);          % Read data length
nothing=fgetl(fileID);                    % Move to next line
ele = zeros(esize, 4);
for i=1:esize
    ele(i,:)=fscanf(fileID,'%g',[4 1]);  % Read in specific format
    nothing=fgetl(fileID);               % Move to next line
end
fclose(fileID);

%% Read real coastline data
% fileID=fopen('Coastline_m.xy','r');
% [csize,~]=fscanf(fileID,'%d',1);         % Read data length
% 
% Coastline_m1 = zeros(csize, 2);
% for i=1:csize
%     Coastline_m1(i,:)=fscanf(fileID,'%g',[2 1]);% Read in specific format
%     nothing=fgetl(fileID);                      % Move to next line
% end
% fclose(fileID);

%% Compare Node data to real coastline
% % not necessairy anymore, inclusive method is used later
% for ii=1:nsize
%     for jj=1:csize
%        % Set zero depth for found coastline points
%        if Node_cor(ii,2)==Coastline_m1(jj,1) && Node_cor(ii,3)==Coastline_m1(jj,2)
%            Node_cor(ii,4)=0; 
%        end
%     end
% end

%% Find Edge Nodes

edge=[];
for ii=1:length(Node_cor)
    if Node_cor(ii,5)==1 % edge points are marked with nb. 1 by triangle
        edge=[edge ; Node_cor(ii,:)];
    end
end

%% Correct north-east open-water edge segment:
% Manual correction!!
for ii=3357:3405    % for every new data set, data should be investigated by its creator
    if edge(ii,4)<3 %set depth threshold at 3m
        Node_cor(edge(ii,1),4)=3;
    end
end

%% Correct coastline nodes
% exclude south, west and north water bounderies
% exclude the small open water segment at the north east region of the grid
% all the rest is definitly the coastline points (as defined in our case)
x_min=min(edge(:,2));
y_min=min(edge(:,3));
y_max=max(edge(:,3));
x=2;y=3; % colomn # in the edge matrix for x and y
for ii=1:length(edge)
    % the if arrangement is meaningful: to make East a full edge
    if edge(ii,y)==y_min     % && edge(ii,x)~=x_min
        Node_cor(edge(ii,1),5)=1; % South
    elseif edge(ii,y)==y_max % && edge(ii,x)~=x_min
        Node_cor(edge(ii,1),5)=3; % North
    elseif edge(ii,x)==x_min      
        Node_cor(edge(ii,1),5)=2; % East
    elseif edge(ii,1)>=edge(3357,1) && edge(ii,1)<=edge(3405,1)
         Node_cor(edge(ii,1),5)=4; % West (small strip to the north)
    else
        Node_cor(edge(ii,1),5)=5; % Coastline marker
        Node_cor(edge(ii,1),4)=0; % Correct depth 
        edge(ii,4)=0;
        edge(ii,5)=5;
    end
end

%% Find erronous nodes
er_nodes=[];
pos_er_nodes=[];
% erronous nodes: index zero(internal nodes) and depth zero 
for ii=1:length(Node_cor)
   if  Node_cor(ii,5)==0 && Node_cor(ii,4)==0 
       er_nodes=[er_nodes ; Node_cor(ii,:)];
   elseif Node_cor(ii,5)==0 && Node_cor(ii,4)<70 && Node_cor(ii,4)~=0 
       pos_er_nodes=[pos_er_nodes ; Node_cor(ii,:)];
   end
end

%% Diagnostic Plots
% Many thanks for Keston Smith & Ata Bilgili for their diagnostic_plots()
% function !!
x = Node_cor(:,2);
y = Node_cor(:,3);
z=Node_cor(:,4);
bat.x=x;bat.y=y;bat.z=z;bat.e=ele(:,2:4);
bat.battype='scattered';
g.x=x;g.y=y;g.z=z;g.e=ele(:,2:4);
% At least bathymetry plot will work here, choose option (3)
diagnostic_plots(g,bat)

%% Automatic denpth correction
x_min=min(edge(:,2));
y_min=min(edge(:,3));
y_max=max(edge(:,3));
figure()
hold on
frame_hight=3000; % m
for ii=1:ceil((y_max-y_min)/frame_hight) %round to greater integer,# of c-l strips
    
    % find coast-line nodes for each segment
    n_cl=[];
    for jj=1:length(edge)
        % devide the coast-line to (frame_hight) m strips:
        if edge(jj,5)==5 && edge(jj,3) > (y_min+frame_hight*(ii-1)) && edge(jj,3) < (y_min+frame_hight*ii)
           n_cl=[n_cl ; edge(jj,2:3)];     
        end
    end
    
    if ~isempty(n_cl) % exclude frames with no coast-line points
        % get the mean x-position of the coast-line strip:
        x_cl_mean=mean(n_cl(:,1));
        x_cl_min=min(n_cl(:,1));
        x_cl_max=max(n_cl(:,1));
        % define a rectangle for depth correction:
        n1=[x_cl_min-frame_hight, y_min+frame_hight*(ii-1)]; 
        n2=[x_cl_max            , y_min+frame_hight* ii   ];


        plot([n1(1),n2(1),n2(1),n1(1),n1(1)],[n1(2),n1(2),n2(2),n2(2),n1(2)],'color','g') %Correction frame
        plot(n_cl(:,1),n_cl(:,2),'*','color','r') % coast-line nodes
        % collect every node in this rectangle:
        n_enclosed=[];
        for kk=1:length(Node_cor)
             if    Node_cor(kk,2)>n1(1) && Node_cor(kk,2)<n2(1) ...
                && Node_cor(kk,3)>n1(2) && Node_cor(kk,3)<n2(2)    %rectangle boundaries        
                    if  Node_cor(kk,5)~=5   %exclude c-l points
                        n_enclosed= [n_enclosed ; Node_cor(kk,:)];
                    end           
             end
        end
        plot(n_enclosed(:,2),n_enclosed(:,3),'o','color','b') %enclosed nodes

        % find average maximum depth
        depth_max=[];     
        count=0;
        while  (length(depth_max)>10 || isempty(depth_max)) % prevent excessive input(may include shallow points)
            depth_max=[];
            for nn=1:length(n_enclosed)
                if n_enclosed(nn,2)<(n1(1)+1000-10*count) % reduce search area progressively
                    depth_max=[depth_max ; n_enclosed(nn,4)];
                end
            end            
            count=1+count;    
        end
        mean_max_depth=mean(depth_max); 
        
        % interpolat depth for each enclosed point
        for mm=1:length(n_enclosed)
            
            %find nearest coast-line point
            y_dist=[];
            for oo=1:length(n_cl)
                if n_enclosed(mm,2)<n_cl(oo,1) % exclude island nodes (compare x coordinates)
                    y_dist=[y_dist ; abs(n_enclosed(mm,3)-n_cl(oo,2))];
                else 
                    y_dist=[y_dist ; 9999999999]; % y_dist and p_cl should have the same length
                end
                
            end
            index=find(y_dist == min(y_dist(:))); % find nearest point
            index=index(1,1);
            depth(mm,1)=mean_max_depth*(1 - (n_enclosed(mm,2)-n1(1)) / (n_cl(index,1)-n1(1)) );           
            Node_cor(n_enclosed(mm,1),4)=depth(mm,1);                       
        end
        
    end
    
end

%% Diagnostic Plots
x = Node_cor(:,2);
y = Node_cor(:,3);
z=Node_cor(:,4);
bat.x=x;bat.y=y;bat.z=z;bat.e=ele(:,2:4);
bat.battype='scattered';
g.x=x;g.y=y;g.z=z;g.e=ele(:,2:4);
diagnostic_plots(g,bat)

%% Smoothing
for pp=1:size(Node_cor)
    % Apply smoothing for internal nodes with depth less than 50 m
    if Node_cor(pp,4)<50 && Node_cor(pp,5)==0 
        % Find surrounding nods, check connections insid .ele file:
        index1= find(ele(:,2) == Node_cor(pp,1));
        index2= find(ele(:,3) == Node_cor(pp,1));
        index3= find(ele(:,4) == Node_cor(pp,1));
        % group the indices:
        indexs =[ele(index1,2+1);ele(index1,3+1);
                 ele(index2,1+1);ele(index2,3+1);
                 ele(index3,1+1);ele(index3,2+1);];
        % Each surrouding node is shared between two elements,
        % then, filter the repetitions:
        temp=indexs;
        for qq=1:length(temp) 
            w=find(temp == temp(qq));
            indexs(w(2))=0;
        end   
        indexs=indexs(find(indexs ~= 0));
        
        % Find the depths of the surrounding nodes:
        depths=[];
        for rr=1:length(indexs)
            depths=[depths ; Node_cor(indexs(rr),4)];
        end
        % assigne the average depth value of the surrounding node to each
        % smoothed node:
        Node_cor(pp,4)=mean(depths);
        
    end
end

%% Diagnostic Plots
x = Node_cor(:,2);
y = Node_cor(:,3);
z=Node_cor(:,4);
bat.x=x;bat.y=y;bat.z=z;bat.e=ele(:,2:4);
bat.battype='scattered';
g.x=x;g.y=y;g.z=z;g.e=ele(:,2:4);
diagnostic_plots(g,bat)


%% Create .BOT file for SWAN
Output_FileName=[output_path 'unstructured_bathymetry.bot'];
fileID = fopen(Output_FileName,'w');
for i=1:length(Node_cor)
    fprintf(fileID,[num2str(round(Node_cor(i,4))) '\n']);
end
fclose(fileID);

end

