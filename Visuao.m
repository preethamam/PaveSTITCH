% Note: grayIM_30to40mphtank consists of potholes and distress from frame
% numbers 135-175 (particularly: 162 and 163). Further, grayIM_0to30mphtank 
% consists few of them in 425-475. Most of them are checked for depth values 
% seems there exists considerable amount of depth change. Also please use
% corresponding depth 4D arrays such as depthIM_30to40mphtank and others.

%% Purge
clc; clear; close all

%% Parameter Initialization

% Color and depth variables
colorvar = 'grayIM_0to30mphtank';
depthvar = 'depthIM_0to30mphtank';      
     
%% Load
clrtank = cell2mat(struct2cell(load('ZZ_Grayscale.mat', colorvar)));
dpttank = cell2mat(struct2cell(load('ZZ_Depth.mat', depthvar)));

%% Visualization Loop
%{
% Number of cameras
nocams = 4;

% Looper
switch nocams
    case 2
        
        figure;   
        for i = 1:size(clrtank, 4)    

            subplot(2,2,1:2)
            abutIM = [uint8(clrtank(:,:,1,i)) uint8(clrtank(:,:,2,i))];
            h1 = imshow(abutIM);

            subplot(2,2,3:4)
            abutdIM = [(dpttank(:,:,1,i)) fliplr(dpttank(:,:,2,i))];
            h2 = imshow(abutdIM,[0 9000]); 

            suptitle(['Frame number: ' num2str(i)])
            drawnow;

            pause(0.12);
        end

    case 4
        figure;
        for i = 320: 330    %size(clrtank, 4)    

        subplot(2,2,1:2)
        abutIM = [uint8(clrtank(:,:,2,i)) uint8(clrtank(:,:,1,i)); ...
                  uint8(clrtank(:,:,3,i)) uint8(clrtank(:,:,4,i))];
        h1 = imshow(abutIM);

        subplot(2,2,3:4)
        abutdIM = [(dpttank(:,:,1,i)) (dpttank(:,:,2,i)); ...
                   (dpttank(:,:,3,i)) (dpttank(:,:,4,i))];
        h2 = imshow(abutdIM,[0 9000]); 

        suptitle(['Frame number: ' num2str(i)])
        drawnow;

        pause(0.12);
        end           
        
        
    case 1
        
        figure;
        for i = 1:size(clrtank, 4)    

        subplot(2,1,1)
        abutIM = uint8(clrtank(:,:,1,i));
        h1 = imshow(abutIM);

        subplot(2,1,2)
        abutdIM = dpttank(:,:,1,i);
        h2 = imshow(abutdIM,[0 9000]); 

        suptitle(['Frame number: ' num2str(i)])
        drawnow;

        pause(0.12);
        end     
end
%}

%% Depth FInder
close all
% Initialize array and flag
ROIwindow = 50;
DPT = dpttank(:,:,1,327);
RGB = uint8(clrtank(:,:,1,327));


ROIpixcoord = zeros(ROIwindow^2,2);
flag = 1;

% Pick a pixel callback
figure(1);
[ROIXrgb,ROIYrgb,~] = funct_pickapixel(RGB,DPT);  
ROIXrgb = round(ROIXrgb);
ROIYrgb = round(ROIYrgb);
Xrgbstart = ROIXrgb -((ROIwindow-1)/2)-1;
Yrgbstart = ROIYrgb -((ROIwindow-1)/2)-1;


% Extract coordinates around PickAPixel
for m = 1:ROIwindow
    for k = 1:ROIwindow
        ROIpixcoord(flag,:) = round([Yrgbstart+m  Xrgbstart+k]);
        flag = flag+1; 
    end                    
end

dptta = zeros(length(ROIpixcoord), 1);
for p = 1:length(ROIpixcoord)
    dptta(p) = double(DPT(ROIpixcoord(p,1), ROIpixcoord(p,2)))/1000;
end

DepthValues = mean(dptta);

%%
pcdcnt = 1;
for i = 1:size(DPT,2)
    for j = 1:size(DPT,1)
        
        if (DPT(j,i)/1000 > 0.1)
            pcd (pcdcnt, :) = [i,j,DPT(j,i)];
        end
        pcdcnt = pcdcnt + 1;
    end
end



% scaledpcd = ((pcd-min(pcd(:))) ./ (max(pcd(:)-min(pcd(:)))));
% 
% for i = 1:length(scaledpcd)
%     if (norm(scaledpcd(i,:)) > 0.01)
%         newpcd(i,:) = scaledpcd(i,:);
%     end
% end

figure
plot3(pcd(:,1), pcd(:,2), pcd(:,3), '.', 'Markersize', 0.1)

%%
imagesc(DPT/1000)
hcb = colorbar('XTickLabel',{'meter'},'FontSize',24);
set(hcb,'XTickMode','manual')
axis off

%% Plot
%
% data = load ('ZZ_Ground-Truth.txt');

tileheight = data(:,1) - data(:,2);

mean(tileheight)
hold on
plot(1:1:20, tileheight, '.')
plot([1 20], [0.0508 0.0508], '-r')
xlabel('Number of Samples')
ylabel('Tile Height (meters)')
legend ('Tile Height by Kinect', 'Actual Tile Height')
grid on;
hold off
%}

