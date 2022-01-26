classdef Class_CompVision
    % CLASS_COMPVISION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = 'public', SetAccess = 'public') 
        nocams            = 1
        ONInames
        testfolder
        totalframes = 1000
        reqdframes  = 30
        camorder    = [1 2 3 4]
        IMwidth     = 640
        IMheight    = 480
        inputImage  = []
        videostate  = 'on'
        inputDImage = []
        SynKpacK_input
        initialDistance = 0.7
        Dispval
        blurindices
        mu    = 10000
        Hconv =  fspecial('gaussian', [9 9], 2)
        opts
        nominal_blurvalue = 0.25
        FrameRange = [1 1000]
        Frame_sorttype = 'speed'
        ROIwindow = 50
        ROIselType = 'oneframe'
    end
    
    methods
        
         % Constructor Initilaization
        function inputObj = Class_CompVision(inpstruct)      
            if nargin >= 1
                inputObj.nocams             = inpstruct.nocams;
                inputObj.totalframes        = inpstruct.totalframes;
                inputObj.reqdframes         = inpstruct.reqdframes;
                inputObj.videostate         = inpstruct.videostate;
                inputObj.ONInames           = inpstruct.ONInames; 
                inputObj.testfolder         = inpstruct.testfolder;
                inputObj.camorder           = inpstruct.camorder;
                inputObj.IMwidth            = inpstruct.IMwidth;
                inputObj.IMheight           = inpstruct.IMheight;
                inputObj.inputImage         = inpstruct.inputImage;
                inputObj.inputDImage        = inpstruct.inputDImage;
                inputObj.SynKpacK_input     = inpstruct.SynKpacK_input;
                inputObj.Dispval            = inpstruct.Dispval;
                inputObj.initialDistance    = inpstruct.initialDistance;
                inputObj.opts               = inpstruct.opts;
                inputObj.Hconv              = inpstruct.Hconv;
                inputObj.mu                 = inpstruct.mu;
                inputObj.FrameRange         = inpstruct.FrameRange;
                inputObj.blurindices        = inpstruct.blurindices;
                inputObj.nominal_blurvalue  = inpstruct.nominal_blurvalue;
                inputObj.Frame_sorttype     = inpstruct.Frame_sorttype;
                inputObj.ROIselType         = inpstruct.ROIselType;
                inputObj.ROIwindow          = inpstruct.ROIwindow;
                
            end
        end % InputData
              
        function output = addtestdatapath (inputObj)
            
           % Add test datset folder path
            currfolderpath = pwd;
            bkslash = regexp(currfolderpath,'\');
            onefolderup = currfolderpath(1:bkslash(end));
            output = [onefolderup 'Test DataSets\' inputObj.testfolder];

            addpath(output)             
        end
        
        function output = getOriginal_RGBDimages (inputObj)
            
            switch inputObj.Frame_sorttype
                case 'none'
                    % Initialize image storage array (tank)
                    grayIMtank = zeros(inputObj.IMheight, inputObj.IMwidth, inputObj.nocams,... 
                    inputObj.reqdframes);

                    depthIMtank = zeros(inputObj.IMheight, inputObj.IMwidth,inputObj.nocams,...
                        inputObj.reqdframes);

                    % Start index
                    startindx = inputObj.SynKpacK_input.ledRGBDsrtIdx;
                    
                    % Waitbar setup parameters
                    h = waitbar(0,'Please wait. This may take few seconds!','Name','Cooking up Images!',...
                                  'CreateCancelBtn',...
                                  'setappdata(gcbf,''canceling'',1)');
                    setappdata(h,'canceling',0)        % Waitbar setup parameters

                    for i = 1:inputObj.nocams

                        % Cancel button
                        if getappdata(h,'canceling')
                            break
                        end

                        % Get LED Kinect Handle
                        onipath       = gettestdatapath (inputObj.testfolder);
                        KinectHandles = func_getkinecthandles([onipath '\' ...
                                        inputObj.ONInames(inputObj.camorder(i),:)]);

                        % Counter
                        frmcount = 1;
                        for j = 1:inputObj.reqdframes
                            
                            if (j >= startindx)

                                if ((j >= inputObj.FrameRange(1) + startindx) && ...
                                    (j <= inputObj.FrameRange(2) + startindx))
                                        % Kinect Load Files
                                        [RGB,DPT]= func_KinRGBD(KinectHandles);     

                                        % Convert RGB to grayscale
                                        gryim = rgb2gray(RGB);  

                                        % Store temporarily                    
                                        grayIMtank(:,:,i,frmcount)  = gryim;
                                        depthIMtank(:,:,i,frmcount) = DPT;
                                        
                                        frmcount = frmcount + 1;
                                end
                            end

                            % Update video frame
                            mxNiUpdateContext(KinectHandles); 

                            % Report current estimate in the waitbar's message field
                            waitbar (j/inputObj.reqdframes,h, ...
                                sprintf('Camera: %i | Frame No.: %i',i, j))
                        end  

                            % Stop the Kinect Process
                            mxNiDeleteContext(KinectHandles);

                    end      

                    save ZZ_Grayscale.mat grayIMtank 
                    save ZZ_Depth.mat     depthIMtank
            
                case 'speed'
                    % Initialize image storage array (tank)
                    % 0 to 30 mph
                    grayIM_0to30mphtank = zeros(inputObj.IMheight, inputObj.IMwidth, inputObj.nocams,... 
                    inputObj.reqdframes);

                    depthIM_0to30mphtank = zeros(inputObj.IMheight, inputObj.IMwidth,inputObj.nocams,...
                        inputObj.reqdframes);
                    
                    % 30 to 40 mph
                    grayIM_30to40mphtank = zeros(inputObj.IMheight, inputObj.IMwidth, inputObj.nocams,... 
                    inputObj.reqdframes);

                    depthIM_30to40mphtank = zeros(inputObj.IMheight, inputObj.IMwidth,inputObj.nocams,...
                        inputObj.reqdframes);
                    
                    % 40 to 50 mph
                    grayIM_40to50mphtank = zeros(inputObj.IMheight, inputObj.IMwidth, inputObj.nocams,... 
                    inputObj.reqdframes);

                    depthIM_40to50mphtank = zeros(inputObj.IMheight, inputObj.IMwidth,inputObj.nocams,...
                        inputObj.reqdframes);
                          
                    % 50 to 60 mph
                    grayIM_50to60mphtank = zeros(inputObj.IMheight, inputObj.IMwidth, inputObj.nocams,... 
                    inputObj.reqdframes);

                    depthIM_50to60mphtank = zeros(inputObj.IMheight, inputObj.IMwidth,inputObj.nocams,...
                        inputObj.reqdframes);
                    
                    % 60+ mph
                    grayIM_60plusmphtank = zeros(inputObj.IMheight, inputObj.IMwidth, inputObj.nocams,... 
                    inputObj.reqdframes);

                    depthIM_60plusmphtank = zeros(inputObj.IMheight, inputObj.IMwidth,inputObj.nocams,...
                        inputObj.reqdframes);

                    % Start index
                    startindx = inputObj.SynKpacK_input.ledRGBDsrtIdx;
                    
                    % Waitbar setup parameters
                    h = waitbar(0,'Please wait. This may take few seconds!','Name','Cooking up Images!',...
                                  'CreateCancelBtn',...
                                  'setappdata(gcbf,''canceling'',1)');
                    setappdata(h,'canceling',0)        % Waitbar setup parameters

                    for i = 1:inputObj.nocams

                        % Cancel button
                        if getappdata(h,'canceling')
                            break
                        end

                        % Get LED Kinect Handle
                        onipath       = gettestdatapath (inputObj.testfolder);
                        KinectHandles = func_getkinecthandles([onipath '\' ...
                                        inputObj.ONInames(inputObj.camorder(i),:)]);

                        % Speed click counters
                        count0to30 = 1;
                        count30to40 = 1;
                        count40to50 = 1;
                        count50to60 = 1;
                        count60plus = 1;
                        
                        for j = 1:inputObj.totalframes
                            
                            if (j >= startindx)

                                if ((j >= inputObj.FrameRange(1) + startindx) && ...
                                    (j <= inputObj.FrameRange(2) + startindx))

                                    % Kinect Load Files
                                    [RGB,DPT]= func_KinRGBD(KinectHandles);     

                                    % Convert RGB to grayscale
                                    gryim = rgb2gray(RGB);  

                                    % Store temporarily
                                    if ((inputObj.SynKpacK_input.GPS_vehiclespeed(j,3) > 0 && ...
                                         inputObj.SynKpacK_input.GPS_vehiclespeed(j,3) < 30)&& ...
                                         (count0to30 <= inputObj.reqdframes)) 
                                        
                                        % Copy image in temp variable
                                        grayIM_0to30mphtank(:,:,i,count0to30)  = gryim;
                                        depthIM_0to30mphtank(:,:,i,count0to30) = DPT;
                                        
                                        % Counter increment
                                        count0to30 = count0to30 + 1;
                                        
                                    elseif ((inputObj.SynKpacK_input.GPS_vehiclespeed(j,3) > 30 && ...
                                             inputObj.SynKpacK_input.GPS_vehiclespeed(j,3) < 40)&& ...
                                             (count30to40 <= inputObj.reqdframes))
                                    
                                        % Copy image in temp variable
                                        grayIM_30to40mphtank(:,:,i,count30to40)  = gryim;
                                        depthIM_30to40mphtank(:,:,i,count30to40) = DPT;
                                        
                                        % Counter increment
                                        count30to40 = count30to40 + 1;                                         
                                        
                                    elseif ((inputObj.SynKpacK_input.GPS_vehiclespeed(j,3) > 40 && ...
                                             inputObj.SynKpacK_input.GPS_vehiclespeed(j,3) < 50)&& ...
                                             (count40to50 <= inputObj.reqdframes))
                                    
                                        % Copy image in temp variable
                                        grayIM_40to50mphtank(:,:,i,count40to50)  = gryim;
                                        depthIM_40to50mphtank(:,:,i,count40to50) = DPT;
                                        
                                        % Counter increment
                                        count40to50 = count40to50 + 1;
                                        
                                    elseif ((inputObj.SynKpacK_input.GPS_vehiclespeed(j,3) > 50 && ...
                                             inputObj.SynKpacK_input.GPS_vehiclespeed(j,3) < 60)&& ...
                                             (count50to60 <= inputObj.reqdframes))
                                    
                                        % Copy image in temp variable
                                        grayIM_50to60mphtank(:,:,i,count50to60)  = gryim;
                                        depthIM_50to60mphtank(:,:,i,count50to60) = DPT;
                                        
                                        % Counter increment
                                        count50to60 = count50to60 + 1;
                                    
                                    elseif ((inputObj.SynKpacK_input.GPS_vehiclespeed(j,3) > 60) && ...
                                            (count60plus <= inputObj.reqdframes))
                                    
                                        % Copy image in temp variable
                                        grayIM_60plusmphtank(:,:,i,count60plus)  = gryim;
                                        depthIM_60plusmphtank(:,:,i,count60plus) = DPT;
                                        
                                        % Counter increment
                                        count60plus = count60plus + 1; 
                                    end
                                end
                            end
                            % Update video frame
                            mxNiUpdateContext(KinectHandles); 

                            % Report current estimate in the waitbar's message field
                            waitbar (j/inputObj.totalframes,h, ...
                                sprintf('Camera: %i | Frame No.: %i',i, j))
                        end  

                            % Stop the Kinect Process
                            mxNiDeleteContext(KinectHandles);

                    end      

                    save ZZ_Grayscale.mat grayIM_0to30mphtank grayIM_30to40mphtank ...
                                          grayIM_40to50mphtank grayIM_50to60mphtank ...
                                          grayIM_60plusmphtank
                    save ZZ_Depth.mat     depthIM_0to30mphtank depthIM_30to40mphtank ...
                                          depthIM_40to50mphtank depthIM_50to60mphtank ...
                                          depthIM_60plusmphtank

                case 'maxdisp' 

            end
            
            output = 'Success';
            
        end
        
        function output = getDenoised_RGBDimages (inputObj)
            
            % Initialize image storage array (tank)
            DNgrayIMtank = zeros(inputObj.IMheight, inputObj.IMwidth, inputObj.nocams,... 
            inputObj.reqdframes);
        
            DNdepthIMtank = zeros(inputObj.IMheight, inputObj.IMwidth,inputObj.nocams,...
                inputObj.reqdframes);
            
            % Waitbar setup parameters
            h = waitbar(0,'Please wait. This may take few seconds!','Name','Cooking up Denoised Images!',...
                          'CreateCancelBtn',...
                          'setappdata(gcbf,''canceling'',1)');
            setappdata(h,'canceling',0)        % Waitbar setup parameters
            
            for i = 1:inputObj.nocams
                
                % Cancel button
                if getappdata(h,'canceling')
                    break
                end
                
                % Get LED Kinect Handle
                onipath       = gettestdatapath (inputObj.testfolder);
                KinectHandles = func_getkinecthandles([onipath '\' ...
                                inputObj.ONInames(inputObj.camorder(i),:)]);
                                
                for j = 1:inputObj.reqdframes
                    % Kinect Load Files
                    [RGB,DPT]= func_KinRGBD(KinectHandles);     

                    % Convert RGB to grayscale
                    imgray = rgb2gray(RGB);  
 
                    % To double
                    imgrayD = double(imgray);
                        
                    % Denoise the RGB image
                    denoiseIM = deconvtv(imgrayD, inputObj.Hconv, inputObj.mu, inputObj.opts);
                                               
                    % Store temporarily                    
                    DNgrayIMtank(:,:,i,j)  = denoiseIM.f;
                    DNdepthIMtank(:,:,i,j) = DPT;
                    
                    % Update video frame
                    mxNiUpdateContext(KinectHandles); 
                    
                    % Report current estimate in the waitbar's message field
                    waitbar (j/inputObj.reqdframes,h, ...
                        sprintf('Camera: %i | Frame No.: %i',i, j))
                end  
                
                    % Stop the Kinect Process
                    mxNiDeleteContext(KinectHandles);
                
            end      
            
            save ZZ_DenoisedGrayscale.mat DNgrayIMtank 
            save ZZ_DenoisedDepth.mat     DNdepthIMtank
            
            output = 'Success';
            
        end
        
        function output = loadImageMATfiles (inputObj)
            
            % Load Grayscale image tank
            if exist('ZZ_Grayscale.mat', 'file')
              % File exists and load when the same experiment is ran
                load ZZ_Grayscale.mat
            else
              % File does not exist.
              warningMessage = sprintf('Warning: file does not exist:\n%s', ...
                                       'ZZ_Grayscale.mat');
              uiwait(msgbox(warningMessage));
            end
            
            % Load Depth image tank
            if exist('ZZ_Depth.mat', 'file')
              % File exists and load when the same experiment is ran
               load ZZ_Depth.mat 
              
            else
              % File does not exist.
              warningMessage = sprintf('Warning: file does not exist:\n%s', ...
                                       'ZZ_Depth.mat');
              uiwait(msgbox(warningMessage));
            end
            
            output = 'Success';
            
        end

        function blurindex = blurMetricDetector(inputObj)
            % original : entry image

            % The idea is from "The Blur Effect: Perception and Estimation with a New No-Reference Perceptual Blur Metric"
            % Crété-Roffet F., Dolmiere T., Ladret P., Nicolas M. - GRENOBLE - 2007
            % In SPIE proceedings - SPIE Electronic Imaging Symposium Conf Human Vision and Electronic Imaging, États-Unis d'Amérique (2007)

            % Written by DO Quoc Bao, PhD Student in L2TI Laboratory, Paris 13 University, France
            % Email: doquocbao@gmail.com, do.quocbao@l2ti.univ-paris13.fr
            % Last changed: 21-09-2008

            %%%%%%%%%%%%%%%%%%Note: the output (blur) is in [0,1]; 0 means sharp, 1 means blur%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Please cite the author when you use this code. All remarks are welcome. %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            I = double(inputObj.inputImage);
            [y, x] = size(I);

            Hv = [1 1 1 1 1 1 1 1 1]/9;
            Hh = Hv';

            B_Ver = imfilter(I,Hv);%blur the input image in vertical direction
            B_Hor = imfilter(I,Hh);%blur the input image in horizontal direction

            D_F_Ver = abs(I(:,1:x-1) - I(:,2:x));%variation of the input image (vertical direction)
            D_F_Hor = abs(I(1:y-1,:) - I(2:y,:));%variation of the input image (horizontal direction)

            D_B_Ver = abs(B_Ver(:,1:x-1)-B_Ver(:,2:x));%variation of the blured image (vertical direction)
            D_B_Hor = abs(B_Hor(1:y-1,:)-B_Hor(2:y,:));%variation of the blured image (horizontal direction)

            T_Ver = D_F_Ver - D_B_Ver;%difference between two vertical variations of 2 image (input and blured)
            T_Hor = D_F_Hor - D_B_Hor;%difference between two horizontal variations of 2 image (input and blured)

            V_Ver = max(0,T_Ver);
            V_Hor = max(0,T_Hor);

            S_D_Ver = sum(sum(D_F_Ver(2:y-1,2:x-1)));
            S_D_Hor = sum(sum(D_F_Hor(2:y-1,2:x-1)));

            S_V_Ver = sum(sum(V_Ver(2:y-1,2:x-1)));
            S_V_Hor = sum(sum(V_Hor(2:y-1,2:x-1)));

            blur_F_Ver = (S_D_Ver-S_V_Ver)/S_D_Ver;
            blur_F_Hor = (S_D_Hor-S_V_Hor)/S_D_Hor;
            
            blurindex = max(blur_F_Ver,blur_F_Hor);
            
        end
        
        function dblurindex = DblurMetricDetector(inputObj)

            count  = 0;
            for i =  1:size(inputObj.inputDImage, 1)
                for j =  1:size(inputObj.inputDImage, 2)

                    if (~( (inputObj.inputDImage(i,j)/1000 > inputObj.initialDistance - 0.25 * abs(inputObj.Dispval)) && ...
                           (inputObj.inputDImage(i,j)/1000 < inputObj.initialDistance + 2.5 * abs(inputObj.Dispval))))
                                   count = count + 1;
                    end

                end
            end

            dblurindex = count / (size(inputObj.inputDImage, 1) * size(inputObj.inputDImage, 2));           
        end
        
        function DepthValues = Depth_ROI (inputObj)
           
            % Initialize image blur and depth blur storage array (tank)
            DepthValues.frames = zeros( inputObj.reqdframes, inputObj.nocams);
            
            % Waitbar setup parameters
            h = waitbar(0,'Please wait. This may take few seconds!','Name','Finding up RoI Depth Values!',...
                          'CreateCancelBtn',...
                          'setappdata(gcbf,''canceling'',1)');
            setappdata(h,'canceling',0)        % Waitbar setup parameters
            
            
            for i = 1:inputObj.nocams
           
               % Cancel button
                if getappdata(h,'canceling')
                    break
                end
                
               % Get LED Kinect Handle
                onipath       = gettestdatapath (inputObj.testfolder);
                KinectHandles = func_getkinecthandles([onipath '\' ...
                                inputObj.ONInames(inputObj.camorder(i),:)]);

                for j = 1 : inputObj.reqdframes

                    [RGB,DPT]= func_KinRGBD(KinectHandles);

                    %{
                    switch inputObj.ROIselType
                        case 'oneframe'
                            if ((j==1))

                                % Initialize array and flag
                                ROIpixcoord = zeros(inputObj.ROIwindow^2,2);
                                flag = 1;

                                % Pick a pixel callback
                                [ROIXrgb,ROIYrgb,~] = func_pickapixel(RGB,DPT);  
                                ROIXrgb = round(ROIXrgb);
                                ROIYrgb = round(ROIYrgb);
                                Xrgbstart = ROIXrgb -((inputObj.ROIwindow-1)/2)-1;
                                Yrgbstart = ROIYrgb -((inputObj.ROIwindow-1)/2)-1;

                                % Extract coordinates around PickAPixel
                                for m = 1:inputObj.ROIwindow
                                    for k = 1:inputObj.ROIwindow
                                        ROIpixcoord(flag,:) = round([Yrgbstart+m  Xrgbstart+k]);
                                        flag = flag+1; 
                                    end                    
                                end

                                % Save the center and surrounding coordinates
                                save ZZ_ROIcentroid.mat ROIXrgb ROIYrgb ROIpixcoord
                            else

                                % Load when the same experiment is ran
                                load ZZ_ROIcentroid.mat                
                            end
                            
                        case 'allframe'

                    end
            %}
                    % Show video
                    % Grayscale conversion
                    % imgray = rgb2gray(RGB);

                    startindx = inputObj.SynKpacK_input.ledRGBDsrtIdx;
                    
                    if (j >= startindx)
                        %{
                        dpttank = zeros(length(ROIpixcoord), 1);
                        for p = 1:length(ROIpixcoord)
                            dpttank(p) = double(DPT(ROIpixcoord(p,1), ROIpixcoord(p,2)))/1000;
                        end
                        
                        cnt = 0;
                        for q = 1:length(dpttank)
                             if ((dpttank(q) < 0.45))
                                 cnt = cnt + 1;
                             end
                        end
                        
                        if (cnt > round (length(ROIpixcoord)/2))
                            DepthValues.frames(j,i) =  DepthValues.frames(j-1,i);
                        else
                            DepthValues.frames(j,i) = mean(dpttank);
                        end
                        %}
                        
                        cnt = 1;
                        dummy  = zeros(size(DPT,1)*size(DPT,2),1);
                        for ii = 1:size(DPT,1)
                            for jj = 1:size(DPT,2)
                                if (~(double(DPT(ii,jj))/1000 < 0.01) && ...
                                     ((double(DPT(ii,jj))/1000 > 0.35) && ...
                                     (double(DPT(ii,jj))/1000 < 0.9) ))                                 
                                    dummy(cnt) = double(DPT(ii,jj))/1000;
                                    cnt  = cnt + 1;
                                end
                                
                            end
                        end
                       
                        dummy(dummy==0) = [];
                        DepthValues.frames(j,i) = mean(dummy);
                        
                        % Display video callback
                        if (strncmp(inputObj.videostate,'on',3))
                            func_showvideo(ROIpixcoord,ROIpixcoord,RGB,DPT);                        
                        end
                    end
                        
                        
                    
                    % Report current estimate in the waitbar's message field
                    waitbar (j/inputObj.reqdframes,h, ...
                    sprintf('Camera: %i | Frame No.: %i',i, j))

                    % Update video frame
                    mxNiUpdateContext(KinectHandles); 
                end

                % Stop the Kinect Process
                mxNiDeleteContext(KinectHandles);

            end
        end
        
        function noiseindices = Image_noiseIndex  (inputObj)
           
            % Initialize image blur and depth blur storage array (tank)
            noiseindices.blur = zeros( inputObj.reqdframes, inputObj.nocams);
            noiseindices.dblur = zeros( inputObj.reqdframes, inputObj.nocams);
            
            % Waitbar setup parameters
            h = waitbar(0,'Please wait. This may take few seconds!','Name','Finding up Indices!',...
                          'CreateCancelBtn',...
                          'setappdata(gcbf,''canceling'',1)');
            setappdata(h,'canceling',0)        % Waitbar setup parameters
            
            
            for i = 1:inputObj.nocams
           
               % Cancel button
                if getappdata(h,'canceling')
                    break
                end
                
               % Get LED Kinect Handle
                onipath       = gettestdatapath (inputObj.testfolder);
                KinectHandles = func_getkinecthandles([onipath '\' ...
                                inputObj.ONInames(inputObj.camorder(i),:)]);

                for j = 1 : inputObj.reqdframes

                    [RGB,DPT]= func_KinRGBD(KinectHandles);

                    % Show video
                    % Grayscale conversion
                    imgray = rgb2gray(RGB);

                    startindx = inputObj.SynKpacK_input.ledRGBDsrtIdx;
                    
                    if (j > startindx)
                        % Blur detection/index
                        noiseindices.blur(j,i) = blurMetricDetector(imgray);                    

                        % Dblur detection/index
                        noiseindices.dblur(j,i) = DblurMetricDetector( DPT, inputObj.initialDistance, ...
                                                    (inputObj.SynKpacK_input.Disp(j-startindx,3) + inputObj.SynKpacK_input.Disp(j-startindx,6)/2) );

                        % Display video callback
                        if (strncmp(inputObj.videostate,'on',3))
                            func_showvideo_Indices([],imgray,RGB,DPT, ['Camera: ' num2str(i) ' | ' 'Frame: ' num2str(j)...
                                        ' | ' 'BlurIndx: ' num2str(noiseindices.blur(j,i))  ' | ' 'DblurIndx: ' num2str(noiseindices.dblur(j,i))]);
                        end

                    else
                        noiseindices.blur(j,i)  = -1;
                        noiseindices.dblur(j,i) = -1;
                    end
                    
                    % Report current estimate in the waitbar's message field
                    waitbar (j/inputObj.reqdframes,h, ...
                    sprintf('Camera: %i | Frame No.: %i',i, j))

                    % Update video frame
                    mxNiUpdateContext(KinectHandles); 
                end

                % Stop the Kinect Process
                mxNiDeleteContext(KinectHandles);

            end
        end
        
        function output = Image_denoiser(inputObj)
            
            % Waitbar setup parameters
            h = waitbar(0,'Please wait. This may take few seconds!','Name','Denoising Images!',...
                          'CreateCancelBtn',...
                          'setappdata(gcbf,''canceling'',1)');
            setappdata(h,'canceling',0)        % Waitbar setup parameters
            
            
            for i = 1:inputObj.nocams
           
               % Cancel button
                if getappdata(h,'canceling')
                    break
                end
                
               % Get LED Kinect Handle
                onipath       = gettestdatapath (inputObj.testfolder);
                KinectHandles = func_getkinecthandles([onipath '\' ...
                                inputObj.ONInames(inputObj.camorder(i),:)]);

                for j = 1 : inputObj.reqdframes

                    [RGB,DPT]= func_KinRGBD(KinectHandles);

                    % Show video
                    % Grayscale conversion
                    imgray = rgb2gray(RGB);
                    
                    imgrayD = double(imgray);

                    startindx = inputObj.SynKpacK_input.ledRGBDsrtIdx;
                    
                    if ((j > startindx) && (inputObj.blurindices.blur(j,i) > ...
                            inputObj.nominal_blurvalue))
                        
                        % Denoise the RGB image
                        denoiseIM = deconvtv(imgrayD, inputObj.Hconv, inputObj.mu, inputObj.opts);
                        
                        % Blur index after denoise
                        output.denoised_blur(j,i) = blurMetricDetector(denoiseIM.f);
                        
                        % Display video callback
                        if (strncmp(inputObj.videostate,'on',3))
                            
                            subplot(1,2,1), 
                            imshow(imgray);
                            title(['BlurIndx: ' num2str(inputObj.blurindices.blur(j,i))])

                            subplot(1,2,2), 
                            imshow(uint8(denoiseIM.f));
                            title(['DeBlurIndx: ' num2str(output.denoised_blur(j,i)) ])
                            
                            suptitle (['Camera: ' num2str(i) ' | ' 'Frame: ' num2str(j)]);
                            
                            drawnow;                                    
                        end
                               
                    elseif ((inputObj.blurindices.blur(j,i) <  inputObj.nominal_blurvalue) && ...
                             (inputObj.blurindices.blur(j,i) > 0))
                            output.denoised_blur(j,i) = inputObj.blurindices.blur(j,i);
                    else
                            output.denoised_blur(j,i) = -1;
                    end
                    
                    % Report current estimate in the waitbar's message field
                    waitbar (j/inputObj.reqdframes,h, ...
                    sprintf('Camera: %i | Frame No.: %i',i, j))

                    % Update video frame
                    mxNiUpdateContext(KinectHandles); 
                end

                % Stop the Kinect Process
                mxNiDeleteContext(KinectHandles);

            end
        end

    end
    
end

%% Class only special functions (No access outside the class)
%-------------------------------------------------------------------------

% Get Dblur index
function dblurindex = DblurMetricDetector(inputDImage, initialDistance, Dispval)

inputDImage = double(inputDImage);
count  = 0;
for i =  1:size(inputDImage, 1)
    for j =  1:size(inputDImage, 2)        
        
        if ( ~( (inputDImage(i,j)/1000 > initialDistance - 0.25 * abs(Dispval)) && (inputDImage(i,j)/1000 < ...
                                         initialDistance + initialDistance * 0.5 + 2.5 * abs(Dispval) ) ))
                       count = count + 1;
        end
        
    end
end
dblurindex = count / (size(inputDImage, 1) * size(inputDImage, 2));           
end

% Get blur index
function blurindex = blurMetricDetector(inputImage)
            % original : entry image

            % The idea is from "The Blur Effect: Perception and Estimation with a New No-Reference Perceptual Blur Metric"
            % Crété-Roffet F., Dolmiere T., Ladret P., Nicolas M. - GRENOBLE - 2007
            % In SPIE proceedings - SPIE Electronic Imaging Symposium Conf Human Vision and Electronic Imaging, États-Unis d'Amérique (2007)

            % Written by DO Quoc Bao, PhD Student in L2TI Laboratory, Paris 13 University, France
            % Email: doquocbao@gmail.com, do.quocbao@l2ti.univ-paris13.fr
            % Last changed: 21-09-2008

            %%%%%%%%%%%%%%%%%%Note: the output (blur) is in [0,1]; 0 means sharp, 1 means blur%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Please cite the author when you use this code. All remarks are welcome. %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            I = double(inputImage);
            [y, x] = size(I);

            Hv = [1 1 1 1 1 1 1 1 1]/9;
            Hh = Hv';

            B_Ver = imfilter(I,Hv);%blur the input image in vertical direction
            B_Hor = imfilter(I,Hh);%blur the input image in horizontal direction

            D_F_Ver = abs(I(:,1:x-1) - I(:,2:x));%variation of the input image (vertical direction)
            D_F_Hor = abs(I(1:y-1,:) - I(2:y,:));%variation of the input image (horizontal direction)

            D_B_Ver = abs(B_Ver(:,1:x-1)-B_Ver(:,2:x));%variation of the blured image (vertical direction)
            D_B_Hor = abs(B_Hor(1:y-1,:)-B_Hor(2:y,:));%variation of the blured image (horizontal direction)

            T_Ver = D_F_Ver - D_B_Ver;%difference between two vertical variations of 2 image (input and blured)
            T_Hor = D_F_Hor - D_B_Hor;%difference between two horizontal variations of 2 image (input and blured)

            V_Ver = max(0,T_Ver);
            V_Hor = max(0,T_Hor);

            S_D_Ver = sum(sum(D_F_Ver(2:y-1,2:x-1)));
            S_D_Hor = sum(sum(D_F_Hor(2:y-1,2:x-1)));

            S_V_Ver = sum(sum(V_Ver(2:y-1,2:x-1)));
            S_V_Hor = sum(sum(V_Hor(2:y-1,2:x-1)));

            blur_F_Ver = (S_D_Ver-S_V_Ver)/S_D_Ver;
            blur_F_Hor = (S_D_Hor-S_V_Hor)/S_D_Hor;
            
            blurindex = max(blur_F_Ver,blur_F_Hor);
            
end
        
% Get Kinect handles for the given ONI file
function [KinectHandles] = func_getkinecthandles(onifilename)

% This function FUNC_GETKINECTHANDLES extracts the kinect handles for ONI
% conversion

% Read files
SAMPLE_XML_PATH = 'Config\SamplesConfig.xml';

if (exist('Mex','dir') == 7)
    addpath('Mex');
end

onifile = onifilename;

% Start the Kinect Process
KinectHandles = mxNiCreateContext(SAMPLE_XML_PATH, onifile);

end

% Get RGBD data for the ONI file
 function [I,D] = func_KinRGBD(KinectHandles)

 % This function FUNC_KINRGBD Converts and provides RGBD format of Images
 
    % Start the Kinect Process
    I = mxNiPhoto(KinectHandles);
    I = permute(I,[3 2 1]);
	D = mxNiDepth(KinectHandles);
    D = permute(D,[2 1]);
    
 end
 
% Show the stream video RGB | Depth | Grayscale 
 function [] = func_showvideo(Corpts,Icorpts,RGB,DPT)

subplot(2,2,1), 
imshow(RGB);
title('RGB Image','fontsize',14)

subplot(2,2,2), 
imshow(DPT,[0 9000]);
colorbar;

if (isempty(Corpts) == 0)
    hold on
    plot(Corpts(:,1), Corpts(:,2), 'r*');
    hold off
end
title('Depth Map Image','fontsize',14)

   
if (isempty(Icorpts) == 0) 
    subplot(2,2,3:4),
    imshow(Icorpts);
    if (isempty(Corpts) == 0)
        hold on
        plot(Corpts(:,1), Corpts(:,2), 'r*');
        hold off
    end
    title('Grayscale / Corner Detection','fontsize',14)
end

drawnow;

 end

% Show the stream video RGB | Depth | Grayscale 
 function [] =  func_showvideo_Indices(Corpts,Icorpts,RGB,DPT, supertitle)

subplot(2,2,1), 
imshow(RGB);
title('RGB Image','fontsize',10)

subplot(2,2,2), 
imshow(DPT,[0 9000]);
colorbar;

if (isempty(Corpts) == 0)
    hold on
    plot(Corpts(:,1), Corpts(:,2), 'r*');
    hold off
end
title('Depth Map Image','fontsize',10)

   
if (isempty(Icorpts) == 0) 
    subplot(2,2,3:4),
    imshow(Icorpts);
    if (isempty(Corpts) == 0)
        hold on
        plot(Corpts(:,1), Corpts(:,2), 'r*');
        hold off
    end
    title('Grayscale / Corner Detection','fontsize',10)
end

suptitle (supertitle);

drawnow;

 end
 
% Get files folder path 
 function folderpath = gettestdatapath (input_testfolder)

   % Add test datset folder path
    currfolderpath = pwd;
    bkslash = regexp(currfolderpath,'\');
    onefolderup = currfolderpath(1:bkslash(end));
    folderpath = [onefolderup 'Test DataSets\' input_testfolder];
 end

  
% Get LED pixel coordinates by a mouse click
 function [Xrgb,Yrgb,BUTTON] = func_pickapixel(RGB,DPT)
     
    subplot(1,2,1),
    imshow(RGB);
    title('RGB Image','fontsize',14)

    subplot(1,2,2),
    imshow(DPT,[0 9000]); 
    colormap('jet');              
    title('Depth Map Image','fontsize',14)

    zoom on;
    waitfor(gcf,'CurrentCharacter',13)
    zoom reset
    zoom off
    [Xrgb,Yrgb,BUTTON] = ginput(1);
        
 end
 
% Deconvolution by Chan and et. al
function out = deconvtv(g, H, mu, opts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% out = deconvtvl1(g, H, mu, opts)
% deconvolves image g by solving the following TV minimization problem
%
% min  mu  || Hf - g ||_1 + ||f||_TV
% min mu/2 || Hf - g ||^2 + ||f||_TV
%
% where ||f||_TV = sum_{x,y,t} sqrt( a||Dxf||^2 + b||Dyf||^2 + c||Dtf||^2),
% Dxf = f(x+1,y, t) - f(x,y,t)
% Dyf = f(x,y+1, t) - f(x,y,t)
% Dtf = f(x,y, t+1) - f(x,y,t)
%
% Input:      g      - the observed image, can be gray scale, color, or video
%             H      - point spread function
%            mu      - regularization parameter
%     opts.method    - either 'l1' or {'l2'}
%     opts.rho_r     - initial penalty parameter for ||u-Df||   {2}
%     opts.rho_o     - initial penalty parameter for ||Hf-g-r|| {50}
%     opts.beta      - regularization parameter [a b c] for weighted TV norm {[1 1 0]}
%     opts.gamma     - update constant for rho_r {2}
%     opts.max_itr   - maximum iteration {20}
%     opts.alpha     - constant that determines constraint violation {0.7}
%     opts.tol       - tolerance level on relative change {1e-3}
%     opts.print     - print screen option {false}
%     opts.f         - initial  f {g}
%     opts.y1        - initial y1 {0}
%     opts.y2        - initial y2 {0}
%     opts.y3        - initial y3 {0}
%     opts.z         - initial  z {0}
%     ** default values of opts are given in { }.
%
% Output: out.f      - output video
%         out.itr    - total number of iterations elapsed
%         out.relchg - final relative change
%         out.Df1    - Dxf, f is the output video
%         out.Df2    - Dyf, f is the output video
%         out.Df3    - Dtf, f is the output video
%         out.y1     - Lagrange multiplier for Df1
%         out.y2     - Lagrange multiplier for Df2
%         out.y3     - Lagrange multiplier for Df3
%         out.rho_r  - final penalty parameter
%
% Stanley Chan
% Copyright 2011
% University of California, San Diego
%
% Last Modified:
% 30 Apr, 2010 (deconvtvl2)
%  4 May, 2010 (deconvtvl2)
%  5 May, 2010 (deconvtvl2)
%  4 Aug, 2010 (deconvtvl1)
% 20 Jan, 2011 (deconvtv)
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    path(path,genpath(pwd));

    if nargin<3
        error('not enough inputs, try again \n');
    elseif nargin==3
        opts = [];
    end

    if ~isnumeric(mu)
        error('mu must be a numeric value! \n');
    end

    [rows cols frames] = size(g);
    memory_condition = memory;
    max_array_memory = memory_condition.MaxPossibleArrayBytes/16;
    if rows*cols*frames>0.1*max_array_memory
        fprintf('Warning: possible memory issue \n');
        reply = input('Do you want to continue? [y/n]: ', 's');
        if isequal(reply, 'n')
            out.f = 0;
            return
        end
    end

    if ~isfield(opts,'method')
        method = 'l2';
    else
        method = opts.method;
    end

    switch method
        case 'l2'
            out = deconvtvl2(g,H,mu,opts);
        case 'l1'
            out = deconvtvl1(g,H,mu,opts);
        otherwise
            error('unknown method \n');
    end
end

% Convolution by L2 minimization
 function out = deconvtvl2(g, H, mu, opts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% out = deconvtv(g, H, mu, opts)
% deconvolves image g by solving the following TV minimization problem
%
% min (mu/2) || Hf - g ||^2 + ||f||_TV
%
% where ||f||_TV = sqrt( a||Dxf||^2 + b||Dyf||^2 c||Dtf||^2),
% Dxf = f(x+1,y, t) - f(x,y,t)
% Dyf = f(x,y+1, t) - f(x,y,t)
% Dtf = f(x,y, t+1) - f(x,y,t)
%
% Input:      g      - the observed image, can be gray scale, or color
%             H      - point spread function
%            mu      - regularization parameter
%     opts.rho_r     - initial penalty parameter for ||u-Df||   {2}
%     opts.rho_o     - initial penalty parameter for ||Hf-g-r|| {50}
%     opts.beta      - regularization parameter [a b c] for weighted TV norm {[1 1 0]}
%     opts.gamma     - update constant for rho_r {2}
%     opts.max_itr   - maximum iteration {20}
%     opts.alpha     - constant that determines constraint violation {0.7}
%     opts.tol       - tolerance level on relative change {1e-3}
%     opts.print     - print screen option {false}
%     opts.f         - initial f  {g}
%     opts.y1        - initial y1 {0}
%     opts.y2        - initial y2 {0}
%     opts.y3        - initial y3 {0}
%     opts.z         - initial z {0}
%     ** default values of opts are given in { }.
%
% Output: out.f      - output video
%         out.itr    - total number of iterations elapsed
%         out.relchg - final relative change
%         out.Df1    - Dxf, f is the output video
%         out.Df2    - Dyf, f is the output video
%         out.Df3    - Dtf, f is the output video
%         out.y1     - Lagrange multiplier for Df1
%         out.y2     - Lagrange multiplier for Df2
%         out.y3     - Lagrange multiplier for Df3
%         out.rho_r  - final penalty parameter
%
% Stanley Chan
% Copyright 2010-2011
% University of California, San Diego
%
% Last Modified:
% 30 Apr, 2010 (deconvtv)
%  4 May, 2010 (deconvtv)
%  5 May, 2010 (deconvtv)
% 29 Jul, 2010 (deconvtvl2)
% 11 Feb, 2011 (add Obj Val in output)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[rows cols frames] = size(g);


% Check inputs
if nargin<3
    error('not enough input, try again \n');
elseif nargin==3
    opts = [];
end

% Check defaults
if ~isfield(opts,'rho_r')
    opts.rho_r = 2;
end
if ~isfield(opts,'gamma')
    opts.gamma = 2;
end
if ~isfield(opts,'max_itr')
    opts.max_itr = 20;
end
if ~isfield(opts,'tol')
    opts.tol = 1e-3;
end
if ~isfield(opts,'alpha')
    opts.alpha = 0.7;
end
if ~isfield(opts,'print')
    opts.print = false;
end
if ~isfield(opts,'f')
    opts.f = g;
end
if ~isfield(opts,'y1')
    opts.y1 = zeros(rows, cols, frames);
end
if ~isfield(opts,'y2')
    opts.y2 = zeros(rows, cols, frames);
end
if ~isfield(opts,'y3')
    opts.y3 = zeros(rows, cols, frames);
end
if ~isfield(opts,'u1')
    opts.u1 = zeros(rows, cols, frames);
end
if ~isfield(opts,'u2')
    opts.u2 = zeros(rows, cols, frames);
end
if ~isfield(opts,'u3')
    opts.u3 = zeros(rows, cols, frames);
end
if ~isfield(opts,'beta')
    opts.beta = [1 1 0];
end

% initialize
max_itr = opts.max_itr;
tol     = opts.tol;
alpha   = opts.alpha;
beta    = opts.beta;
gamma   = opts.gamma;
rho     = opts.rho_r;
f       = opts.f;
y1      = opts.y1;
y2      = opts.y2;
y3      = opts.y3;
u1      = opts.u1;
u2      = opts.u2;
u3      = opts.u3;


% define operators
eigHtH      = abs(fftn(H, [rows cols frames])).^2;
eigDtD      = abs(beta(1)*fftn([1 -1],  [rows cols frames])).^2 + abs(beta(2)*fftn([1 -1]', [rows cols frames])).^2;
if frames>1
    d_tmp(1,1,1)= 1; d_tmp(1,1,2)= -1;
    eigEtE  = abs(beta(3)*fftn(d_tmp, [rows cols frames])).^2;
else
    eigEtE = 0;
end
Htg         = imfilter(g, H, 'circular');
[D,Dt]      = defDDt(beta);

[Df1 Df2 Df3] = D(f);
out.relchg = [];
out.objval = [];


if opts.print==true
    fprintf('Running deconvtv (L2 version)  \n');
    fprintf('mu =   %10.2f \n\n', mu);
    fprintf('itr        relchg        ||Hf-g||^2       ||f||_TV         Obj Val            rho   \n');
end

rnorm = sqrt(norm(Df1(:))^2 + norm(Df2(:))^2 + norm(Df3(:))^2);

for itr=1:max_itr
    % solve f-subproblem
    f_old = f;
    rhs   = fftn((mu/rho)*Htg + Dt(u1-(1/rho)*y1,  u2-(1/rho)*y2, u3-(1/rho)*y3));
    eigA  = (mu/rho)*eigHtH + eigDtD + eigEtE;
    f     = real(ifftn(rhs./eigA));
    
    % solve u-subproblem
    [Df1 Df2 Df3] = D(f);
    v1 = Df1+(1/rho)*y1;
    v2 = Df2+(1/rho)*y2;
    v3 = Df3+(1/rho)*y3;
    v  = sqrt(v1.^2 + v2.^2 + v3.^2);
    v(v==0) = 1;
    v  = max(v - 1/rho, 0)./v;
    u1 = v1.*v;
    u2 = v2.*v;
    u3 = v3.*v;
    
    % update y
    y1   = y1 - rho*(u1 - Df1);
    y2   = y2 - rho*(u2 - Df2);
    y3   = y3 - rho*(u3 - Df3);
    
    % update rho
    if (opts.print==true)
        r1         = imfilter(f, H, 'circular')-g;
        r1norm     = sum(r1(:).^2);
        r2norm     = sum(sqrt(Df1(:).^2 + Df2(:).^2 + Df3(:).^2));
        objval     = (mu/2)*r1norm+r2norm;
    end
    
    rnorm_old  = rnorm;
    rnorm      = sqrt(norm(Df1(:)-u1(:), 'fro')^2 + norm(Df2(:)-u2(:), 'fro')^2 + norm(Df3(:)-u3(:), 'fro')^2);
    
    if rnorm>alpha*rnorm_old
        rho  = rho * gamma;
    end
    
    % relative change
    relchg = norm(f(:)-f_old(:))/norm(f_old(:));
    out.relchg(itr) = relchg;
    
    if (opts.print==true)
        out.objval(itr) = objval;
    end
    
    % print
    if (opts.print==true)
        fprintf('%3g \t %6.4e \t %6.4e \t %6.4e \t %6.4e \t %6.4e\n ', itr, relchg, r1norm, r2norm, objval, rho);
    end
    
    
    % check stopping criteria
    if relchg < tol
        break
    end
end

out.f  = f;
out.itr  = itr;
out.y1   = y1;
out.y2   = y2;
out.y3   = y3;
out.rho  = rho;
out.Df1  = Df1;
out.Df2  = Df2;
out.Df3  = Df3;

if (opts.print==true)
    fprintf('\n\n');
end

end

function [D,Dt] = defDDt(beta)
D  = @(U) ForwardD(U, beta);
Dt = @(X,Y,Z) Dive(X,Y,Z, beta);
end

function [Dux,Duy,Duz] = ForwardD(U, beta)
frames = size(U, 3);
Dux = beta(1)*[diff(U,1,2), U(:,1,:) - U(:,end,:)];
Duy = beta(2)*[diff(U,1,1); U(1,:,:) - U(end,:,:)];
Duz(:,:,1:frames-1) = beta(3)*diff(U,1,3); 
Duz(:,:,frames)     = beta(3)*(U(:,:,1) - U(:,:,end));
end

function DtXYZ = Dive(X,Y,Z, beta)
frames = size(X, 3);
DtXYZ = [X(:,end,:) - X(:, 1,:), -diff(X,1,2)];
DtXYZ = beta(1)*DtXYZ + beta(2)*[Y(end,:,:) - Y(1, :,:); -diff(Y,1,1)];
Tmp(:,:,1) = Z(:,:,end) - Z(:,:,1);
Tmp(:,:,2:frames) = -diff(Z,1,3);
DtXYZ = DtXYZ + beta(3)*Tmp;
end

% Convolution by L1 minimization
function out = deconvtvl1(g, H, mu, opts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% out = deconvtvl1(g, H, mu, opts)
% deconvolves image g by solving the following TV minimization problem
%
% min (mu/2) || Hf - g ||_1 + ||f||_TV
%
% where ||f||_TV = sqrt( a||Dxf||^2 + b||Dyf||^2 c||Dtf||^2),
% Dxf = f(x+1,y, t) - f(x,y,t)
% Dyf = f(x,y+1, t) - f(x,y,t)
% Dtf = f(x,y, t+1) - f(x,y,t)
%
% Input:      g      - the observed image, can be gray scale, or color
%             H      - point spread function
%            mu      - regularization parameter
%     opts.rho_r     - initial penalty parameter for ||u-Df||   {2}
%     opts.rho_o     - initial penalty parameter for ||Hf-g-r|| {50}
%     opts.beta      - regularization parameter [a b c] for weighted TV norm {[1 1 2.5]}
%     opts.gamma     - update constant for rho_r {2}
%     opts.max_itr   - maximum iteration {20}
%     opts.alpha     - constant that determines constraint violation {0.7}
%     opts.tol       - tolerance level on relative change {1e-3}
%     opts.print     - print screen option {false}
%     opts.f         - initial f  {g}
%     opts.y1        - initial y1 {0}
%     opts.y2        - initial y2 {0}
%     opts.y3        - initial y3 {0}
%     opts.z         - initial z {0}
%     ** default values of opts are given in { }.
%
% Output: out.f      - output video
%         out.itr    - total number of iterations elapsed
%         out.relchg - final relative change
%         out.Df1    - Dxf, f is the output video
%         out.Df2    - Dyf, f is the output video
%         out.Df3    - Dtf, f is the output video
%         out.y1     - Lagrange multiplier for Df1
%         out.y2     - Lagrange multiplier for Df2
%         out.y3     - Lagrange multiplier for Df3
%         out.rho_r  - final penalty parameter
%
% Stanley Chan
% Copyright 2010
% University of California, San Diego
%
% Last Modified:
% 30 Apr, 2010 (deconvtv)
%  4 May, 2010 (deconvtv)
%  5 May, 2010 (deconvtv)
%  4 Aug, 2010 (deconvtv_L1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[rows cols frames] = size(g);

% Check inputs
if nargin<3
    error('not enough input, try again \n');
elseif nargin==3
    opts = [];
end

if ~isnumeric(mu)
    error('mu must be a numeric value! \n');
end


% Check defaults
if ~isfield(opts,'rho_o')
    opts.rho_o = 50;
end
if ~isfield(opts,'rho_r')
    opts.rho_r = 2;
end
if ~isfield(opts,'gamma')
    opts.gamma = 2;
end
if ~isfield(opts,'max_itr')
    opts.max_itr = 20;
end
if ~isfield(opts,'tol')
    opts.tol = 1e-3;
end
if ~isfield(opts,'alpha')
    opts.alpha = 0.7;
end
if ~isfield(opts,'print')
    opts.print = false;
end
if ~isfield(opts,'f')
    opts.f = g;
end
if ~isfield(opts,'y1')
    opts.y1 = zeros(rows, cols, frames);
end
if ~isfield(opts,'y2')
    opts.y2 = zeros(rows, cols, frames);
end
if ~isfield(opts,'y3')
    opts.y3 = zeros(rows, cols, frames);
end
if ~isfield(opts,'z')
    opts.z = zeros(rows, cols, frames);
end
if ~isfield(opts,'beta')
    opts.beta = [1 1 0];
end


% initialize
max_itr   = opts.max_itr;
tol       = opts.tol;
alpha     = opts.alpha;
beta      = opts.beta;
gamma     = opts.gamma;
rho_r     = opts.rho_r;
rho_o     = opts.rho_o;
f         = opts.f;
y1        = opts.y1;
y2        = opts.y2;
y3        = opts.y3;
z         = opts.z;


eigHtH      = abs(fftn(H, [rows cols frames])).^2;
eigDtD      = abs(beta(1)*fftn([1 -1],  [rows cols frames])).^2 + abs(beta(2)*fftn([1 -1]', [rows cols frames])).^2;
if frames>1
    d_tmp(1,1,1)= 1; d_tmp(1,1,2)= -1;
    eigEtE  = abs(beta(3)*fftn(d_tmp, [rows cols frames])).^2;
else
    eigEtE = 0;
end

Htg         = imfilter(g, H, 'circular');
[D,Dt]      = defDDt(beta);

[Df1 Df2 Df3] = D(f);
w       = imfilter(f, H, 'circular') - g;
rnorm   = sqrt(norm(Df1(:))^2 + norm(Df2(:))^2 + norm(Df3(:))^2);

out.relchg = [];
out.objval = [];




if opts.print==true
    fprintf('Running deconvtv (L1 version)  \n');
    fprintf('mu =   %10.2f \n\n', mu);
    fprintf('itr        relchg        ||Hf-g||_1       ||f||_TV         Obj Val            rho_r   \n');
end

for itr = 1:max_itr
    
    % u-subproblem
    v1 = Df1+(1/rho_r)*y1;
    v2 = Df2+(1/rho_r)*y2;
    v3 = Df3+(1/rho_r)*y3;
    v  = sqrt(v1.^2 + v2.^2 + v3.^2);
    v(v==0) = 1e-6;
    v  = max(v - 1/rho_r, 0)./v;
    u1 = v1.*v;
    u2 = v2.*v;
    u3 = v3.*v;
    
    % r-subproblem
    r = max(abs(w + 1/rho_o*z)-mu/rho_o, 0).*sign(w+1/rho_o*z);
    
    % f-subproblem
    f_old = f;
    rhs  = rho_o*Htg + imfilter(rho_o*r-z, H, 'circular') + Dt(rho_r*u1-y1, rho_r*u2-y2, rho_r*u3-y3);
    eigA = rho_o*eigHtH + rho_r*eigDtD + rho_r*eigEtE;
    f    = real(ifftn(fftn(rhs)./eigA));
    
    % y and z -update
    [Df1 Df2 Df3] = D(f);
    w    = imfilter(f, H, 'circular') - g;
    
    y1   = y1 - rho_r*(u1 - Df1);
    y2   = y2 - rho_r*(u2 - Df2);
    y3   = y3 - rho_r*(u3 - Df3);
    z    = z  - rho_o*(r - w);

    
    if (opts.print==true)
        r1norm     = sum(abs(w(:)));
        r2norm     = sum(sqrt(Df1(:).^2 + Df2(:).^2 + Df3(:).^2));
        objval     = mu*r1norm+r2norm;
    end
    
    rnorm_old  = rnorm;
    rnorm      = sqrt(norm(Df1(:)-u1(:), 'fro')^2 + norm(Df2(:)-u2(:), 'fro')^2 + norm(Df3(:)-u3(:), 'fro')^2);
    
    if rnorm>alpha*rnorm_old
        rho_r  = rho_r * gamma;
    end
    
    
    % relative change
    relchg = norm(f(:)-f_old(:))/norm(f_old(:));
    out.relchg(itr) = relchg;
    if (opts.print==true)
        out.objval(itr) = objval;
    end
    
    % print
    if (opts.print==true)
        fprintf('%3g \t %6.4e \t %6.4e \t %6.4e \t %6.4e \t %6.4e\n ', itr, relchg, r1norm, r2norm, objval, rho_r);
    end
    
    % check stopping criteria
    if relchg < tol
        break
    end
end

out.f    = f;
out.itr  = itr;
out.y1   = y1;
out.y2   = y2;
out.y3   = y3;
out.z    = z;
out.rho_r  = rho_r;
out.Df1  = Df1;
out.Df2  = Df2;
out.Df3  = Df3;


if (opts.print==true)
    fprintf('\n');
end

end