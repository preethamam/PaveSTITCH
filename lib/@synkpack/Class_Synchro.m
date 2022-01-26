classdef Class_Synchro
    % CLASS_SYNCHRO
    % SYNC_KINECT_PAVEMENT_DATA METHOD OUTPUTS
    % [ | | |....] REPRENSTS THE MATRIX COLUMNS
    % FRMLEDTHRESVAL    --> LED threshold values [total frame length captured from the camera]
    % LEDRGBDSRTIDX     --> Frame number corresponding to LED start
    % FRMNO_TIME        --> Frame numbers and time [Corrected frame no. | Original fr]
    % DISP              --> Displacement vector(s) [1 | 2 | 3 |... no. of accelerometers]
    % VELO              --> Velocity vector(s) [1 | 2 | 3 |... no. of accelerometers]
    % ACCL              --> Accelerometer vector(s) [1 | 2 | 3 |... no. of accelerometers]
    % LEDSTATE          --> Corrected LED state array [on --> 1 | off --> 0]
    % GPS_LATNLOG       --> GPS latitude logitude matrix [latitude | logitude]
    % GPS_VEHICLESPEED  --> Vehicle speed matrix [lat m/s | long m/s | MPH | KMPH]
    
    properties
        DVAarray
        LEDcamdata
        LEDthreshld           = 127
        videostate            = 'on'
        ledwindow             = 5
        ONInames       
        GPSfile               = 'ZZZ_GPSoutput.txt'
        ONIname 
        handles
        testfolder
        alignerType           = 'camfirst'
        chessgrid_BBox
        NumofSensors          = [6 1 1 1]
        LVDTdata              = []
    end
    
    methods
        

        % Constructor Initilaization
        function inputObj = Class_Synchro(inpstruct)      
            if nargin >= 1
                inputObj.LEDcamdata       = inpstruct.LEDcamdata;
                inputObj.DVAarray         = inpstruct.DVAarray;
                inputObj.LEDthreshld      = inpstruct.LEDthreshld;
                inputObj.videostate       = inpstruct.videostate;
                inputObj.ledwindow        = inpstruct.ledwindow;                              
                inputObj.ONInames         = inpstruct.ONInames;              
                inputObj.GPSfile          = inpstruct.GPSfile;
                inputObj.handles          = inpstruct.handles;
                inputObj.ONIname          = inpstruct.ONIname;
                inputObj.testfolder       = inpstruct.testfolder;
                inputObj.alignerType      = inpstruct.alignerType; 
                inputObj.chessgrid_BBox   = inpstruct.chessgrid_BBox;
                inputObj.NumofSensors     = inpstruct.NumofSensors;
                inputObj.LVDTdata         = inpstruct.lvdtarray;
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
        
        function paveoutput  = sync_Kinect_pavement_data  (inputObj)           
        
        %************************************************************************
        % Stage I: get On/off state
        %************************************************************************
        
        % Variable initialization
        if (exist('ZZ_LEDcentroid.mat','file') == 0)
            error (['LED pixels details are not present.'...
                    'Please check the presence of ZZ_LEDcentroid.mat']);
        else
            load ('ZZ_LEDcentroid.mat');
        end
        
        ledpixcoords = ledpixcoord;
        ledwinsize   = inputObj.ledwindow;
        ledthres     = inputObj.LEDthreshld;
            
        % Get LED Kinect Handle
        onipath    = gettestdatapath (inputObj.testfolder);
        KinectHandles = func_getkinecthandles([onipath '\' inputObj.ONIname]);  
        
        % Array initilaization
        onoff = zeros(inputObj.LEDcamdata.nofrms,1);

        % Waitbar setup parameters
        h = waitbar(0,'Please wait. This may take few minutes!','Name','Synhronizing the Pavement Dataset',...
                    'CreateCancelBtn',...
                    'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
        
        
            for i = 1:inputObj.LEDcamdata.nofrms
                
                % Check for Cancel button press
                if getappdata(h,'canceling')
                    break
                end

                % Call figure instance
                if ((i==1) && (strncmp(inputObj.videostate,'on',3)))
                    figure;
                end
                
                % Kinect Load Files
                [RGB,DPT]= func_KinRGBD(KinectHandles);        

                % Convert RGB to grayscale
                gryim = rgb2gray(RGB);               

                % Turn on/off the video
                if (strncmp(inputObj.videostate,'on',3))
                    func_showvideo([],gryim,RGB,DPT);
                end

                
                % On/off state determination
                [onoffstate, thresval]= func_findonoffstate(gryim, ...
                            ledpixcoords, ledwinsize, ledthres);
                       
                onoff(i,1) = onoffstate;
                paveoutput.FrmLEDthresVal(i,1) = thresval;
                
                mxNiUpdateContext(KinectHandles);      

                % Report current estimate in the waitbar's message field
                waitbar (i/inputObj.LEDcamdata.nofrms,h,  sprintf('Please wait. Current Frame No.: %i',i))
            end
            
            % DELETE the waitbar; don't try to CLOSE it.
            delete(h)       
            
            % Stop the Kinect Process
            mxNiDeleteContext(KinectHandles);
            
        %************************************************************************
        % Stage II: Use On/off state and align the sensor data to frame data
        %************************************************************************
        
        % Load GPS data
        gpsdata = load(inputObj.GPSfile);   
        
        
        % Get LED start frame 
            for i = 1:ceil(length(onoff)*0.5)
                if (onoff(i)== 1)
                    paveoutput.ledRGBDsrtIdx(1,1) = i;
                    break;
                end
            end
            
        

        % Synhesize time stamps
        % Timestamp rearrangement from start to end
        New_frametime_range = inputObj.LEDcamdata.clrts (paveoutput.ledRGBDsrtIdx : end);
        New_frametime       = cumsum([0; diff(New_frametime_range)]);
        New_Unixframetime   = inputObj.LEDcamdata.clrUts (paveoutput.ledRGBDsrtIdx : end);

        % Frame number ans its corresponding time 
        paveoutput.frmno_time = [ (1:length(New_frametime))' (paveoutput.ledRGBDsrtIdx:length(inputObj.LEDcamdata.clrts))' New_frametime ];

        % Find the sensors (acc, LVDT, acoustic, GPS or others) data close to frames 
        Stime    = inputObj.DVAarray(1).timeVec;        % Sensor (acc) time
        Gtime    = gpsdata(:,size(gpsdata,2));                        % GPS epoch time

        % Array initialize
        DAQIndx = zeros(length(New_frametime),1);
        gpsIndx = zeros(length(New_frametime),1);
            
            parfor i = 1:length(New_frametime)
            
                % DAQ index
                [~,Sensorind] = min(abs(Stime - New_frametime(i)));            
                DAQIndx(i) = Sensorind;
                
                % GPS index
                [~, GPSind] = min(abs(Gtime - New_Unixframetime(i)));            
                gpsIndx(i) = GPSind;            
                
            end
           
           % Use indices and make a portable structure 
           for i = 1:length(New_frametime)               
               
               % Extarct accelerometer data
               for noacc = 1:inputObj.NumofSensors(1)                  
                    paveoutput.Disp(i,noacc)  = inputObj.DVAarray(noacc).FinalDisp(DAQIndx(i));                   
                    paveoutput.Velo(i,noacc)  = inputObj.DVAarray(noacc).FinalVelo(DAQIndx(i));                   
                    paveoutput.Accl(i,noacc)  = inputObj.DVAarray(noacc).FinalAccl(DAQIndx(i));                   
               end 
               
               % Extract LED on/off values
               for noled = 1:inputObj.NumofSensors(2)
                   paveoutput.LEDstate(i,:) =  inputObj.LEDcamdata.LEDpulse(DAQIndx(i),:); 
               end
               
               % Extract GPS data
               for nogps = 1:inputObj.NumofSensors(3)
                   paveoutput.GPS_latnlog(i,:)      =  gpsdata(gpsIndx(i),1:2);      
                   paveoutput.GPS_vehiclespeed(i,:) =  gpsdata(gpsIndx(i),3:6);      
               end
               
           end                    
            
        end
        
        function caliboutput = sync_KinCamLedAccLVDT_data (inputObj)           
        
        %************************************************************************
        % Stage I: get On/off state
        %************************************************************************
        
        % Variable initialization
        if (exist('ZZ_LEDcentroid.mat','file') == 0)
            error (['LED pixels details are not present.'...
                    'Please check the presence of ZZ_LEDcentroid.mat']);
        else
            load ('ZZ_LEDcentroid.mat');
        end
        
        ledpixcoords = ledpixcoord;
        ledwinsize   = inputObj.ledwindow;
        ledthres     = inputObj.LEDthreshld;
            
        % Get LED Kinect Handle
        onipath         = gettestdatapath (inputObj.testfolder);
        KinectHandles   = func_getkinecthandles([onipath '\' inputObj.ONIname]);  
        
        % Array initilaization
        onoff       = zeros(inputObj.LEDcamdata.nofrms,1);
        CBdptsMtr   = zeros(inputObj.LEDcamdata.nofrms,1);
        
        % Waitbar setup parameters
        h = waitbar(0,'Please wait. This may take few minutes!','Name',['Synhronizing the Calibration'...
            '(Camera, LED and Accelerometer) Dataset'], 'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
        
        
            for i = 1:inputObj.LEDcamdata.nofrms
                
                % Check for Cancel button press
                if getappdata(h,'canceling')
                    break
                end

                % Call figure instance
                if ((i==1) && (strncmp(inputObj.videostate,'on',3)))
                    figure;
                end
                
                % Kinect Load Files
                [RGB,DPT]= func_KinRGBD(KinectHandles);        

                % Convert RGB to grayscale
                gryim = rgb2gray(RGB);               

                % Find corner points
                [DPTavg,Corpts,~] = func_findcorners(gryim, DPT,...
                                                           inputObj.chessgrid_BBox);
                
                % Turn on/off the video
                if (strncmp(inputObj.videostate,'on',3))
                    func_showvideo(Corpts,gryim,RGB,DPT);
                end
                
                % On/off state determination
                [onoffstate, thresval]= func_findonoffstate(gryim, ...
                            ledpixcoords, ledwinsize, ledthres);
                       
                onoff(i,1) = onoffstate;
                caliboutput.FrmLEDthresVal(i,1) = thresval;
                
                % Checker board corner points In meters        
                CBdptsMtr(i,:) = DPTavg/1000;                     
                
                % Update Kinect handles
                mxNiUpdateContext(KinectHandles);      

                % Report current estimate in the waitbar's message field
                waitbar (i/inputObj.LEDcamdata.nofrms,h,  sprintf('Please wait. Current Frame No.: %i',i))
            end
            
            % DELETE the waitbar; don't try to CLOSE it.
            delete(h)       
            
            % Stop the Kinect Process
            mxNiDeleteContext(KinectHandles);
            
        %************************************************************************
        % Stage II: Use On/off state and align the sensor data to frame data
        %************************************************************************
            switch inputObj.alignerType
                case 'camfirst'
                % Frame/epoch aligner [camera starts first] 

                    for i = 1:ceil(length(onoff)*0.5)
                        if (onoff(i)== 1)
                            caliboutput.ledRGBDsrtIdx(1,1) = i;
                            break;
                        end
                    end   


                    % Depth values new range based on LED start
                    CBdptsMtr = CBdptsMtr(caliboutput.ledRGBDsrtIdx : end);    
                    caliboutput.CBdptsDCR =  CBdptsMtr-mean(CBdptsMtr);         % No DC or zero mean ...
                                                                                % depth points after corner poins avergaing    

                    % Synhesize time stamps
                    % Timestamp rearrangement from start to end
                    New_frametime_range = inputObj.LEDcamdata.clrts (caliboutput.ledRGBDsrtIdx : end);
                    New_frametime       = cumsum([0; diff(New_frametime_range)]);


                    % Frame number and its corresponding time 
                    caliboutput.frmno_time = [ (1:length(New_frametime))'  (caliboutput.ledRGBDsrtIdx:length(inputObj.LEDcamdata.clrts))' New_frametime ];

                    % Find the sensors (acc, LVDT, LED or others) data close to frames 
                    Stime    = inputObj.DVAarray(1).timeVec;        % Sensor (acc) time


                    % Array initialize
                    DAQIndx = zeros(length(New_frametime),1);        

                        parfor i = 1:length(New_frametime)            
                            % DAQ index
                            [~,Sensorind] = min(abs(Stime - New_frametime(i)));            
                            DAQIndx(i) = Sensorind;     

                        end

                       % Use indices and make a portable structure 
                       for i = 1:length(New_frametime)               

                           % Extarct accelerometer data
                           for noacc = 1:inputObj.NumofSensors(1)                  
                                caliboutput.Disp(i,noacc)  = inputObj.DVAarray(noacc).FinalDisp(DAQIndx(i));                   
                                caliboutput.Velo(i,noacc)  = inputObj.DVAarray(noacc).FinalVelo(DAQIndx(i));                   
                                caliboutput.Accl(i,noacc)  = inputObj.DVAarray(noacc).FinalAccl(DAQIndx(i));                   
                           end 

                           % Extract LED on/off values
                           for noled = 1:inputObj.NumofSensors(2)
                               caliboutput.LEDstate(i,noled) =  inputObj.LEDcamdata(noled).LEDpulse(DAQIndx(i),:); 
                           end

                           % Extract LVDT data
                           for nolvdt = 1:inputObj.NumofSensors(4)
                               caliboutput.LVDT_data(i,nolvdt)      =  inputObj.LVDTdata(DAQIndx(i),nolvdt);                                    
                           end

                       end      

                case 'ledfirst'

                    disp('Type some code here!');                
            end
        
        end
        
        function caliboutput = sync_KinCamLedAccLIDAR_data (inputObj)
            disp('Include code to synchronize the dataset....!')
        end
        
    end
    
end



%% Class only special functions (No access outside the class)
%-------------------------------------------------------------------------

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

 
% SHow the stream video RGB | Depth | Grayscale 
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

 
% Extract the folderpath of the files 
 function folderpath = gettestdatapath (input_testfolder)

   % Add test datset folder path
    currfolderpath = pwd;
    bkslash = regexp(currfolderpath,'\');
    onefolderup = currfolderpath(1:bkslash(end));
    folderpath = [onefolderup 'Test DataSets\' input_testfolder];
 end
 
 
% Find the on/off state of LED in each frame of LED camera
 function [onoffstate, thresval] = func_findonoffstate(imgray, ledpixcoord, winsize, ledthres)

    % Find the mean grayscale value of LED window
    ledpixval = zeros(winsize^2,1);
    for m = 1:length(ledpixcoord)
        ledpixval (m) = imgray(round(ledpixcoord(m,1)), round(ledpixcoord(m,2)));
    end
    
    thresval = round(mean(ledpixval));

    if (round(mean(ledpixval)) > ledthres)
            onoffstate = 1;
    else
            onoffstate = 0;
    end
           
 end

 
% Find the corners of the calibration grid 
 function [DPTCorptsAVG,finCorpts,Icorpts]  = func_findcorners(Icorpts,DPT,coord)

    Corpts = corner(Icorpts ,'Harris');
    finCorpts = zeros(length(Corpts),2);
    DPTCorpts = zeros(length(Corpts),1);
    
    for i = 1:length(Corpts)
        if ( ((Corpts(i,1) <= coord(3)) && (Corpts(i,1) >= coord(1)))...
             && ((Corpts(i,2) <= coord(4)) && (Corpts(i,2) >= coord(2))))
                      finCorpts(i,:) =   Corpts(i,:);  
                      DPTCorpts(i) = DPT(finCorpts(i,2),finCorpts(i,1));
        end
    end
    finCorpts( ~any(finCorpts,2), : ) = [];  %rows
    DPTCorpts( ~any(DPTCorpts,2), : ) = [];  %rows    
    
    DPTCorptsAVG = mean(DPTCorpts);
 end


% Frame/epoch aligner [camera starts first] 
 function [CBdptsDCR,dpttsaligned,clrtsaligned, ledRGBDsrtIdx] = func_framealigner(CBdptsMtrinput,onoff,dptts,clrts)

    for i = 1:ceil(length(onoff)*0.5)
        if (onoff(i)== 1)
            ledRGBDsrtIdx(1,1) = i;
            break;
        end
    end   
    
    
    % Depth values new range based on LED start
    CBdptsMtr = CBdptsMtrinput(ledRGBDsrtIdx:end);    
    CBdptsDCR =  CBdptsMtr-mean(CBdptsMtr);         % No DC or zero mean
    
    % Depth Timestamp rearrangement
    dpttsnew = dptts(ledRGBDsrtIdx:end); 
    dpttsFV = dpttsnew(1); % First value
    dpttsaligned = dpttsnew - dpttsFV; 

    % Color Timestamp rearrangement
    clrtsnew = clrts(ledRGBDsrtIdx:end); 
    clrtsFV = clrtsnew(1); % First value
    clrtsaligned = clrtsnew - clrtsFV; 
    
 end


% Frame/epoch aligner [LED starts first]
function [smplIdx,ledsrtIdx,correctdptts,correctclrts,FFcorrectdptts,FFcorrectclrts] = ...
         func_epochaligner(myLEDcycle,LEDts,onoff,clrUts,dptts,clrts,t)

    % RGBD/LED nth frame epoch aligner
    %************** CHECK AGAIN FOR DRIFT **************
    flag = 1;
    ledRGBDsrtIdx = zeros(ceil(200/15),1);

    for i = 1:1000
        if (onoff(i)-onoff(i+1)== -1)
            ledRGBDsrtIdx(flag,1) = i+1;
            flag=flag+1;
        end
    end

    % Remove zero rows
    ledRGBDsrtIdx( all(~ledRGBDsrtIdx,2), : ) = [];

    % Select epoch time from the RGB start index % Include the same for depth
    rgbLEDepochstart = clrUts(ledRGBDsrtIdx(myLEDcycle));
    ledsrtIdx = ledRGBDsrtIdx(myLEDcycle);

    % Find closest value in NIDAQ LED timestamps
    [~,ledNIDAQidx] = min(abs(LEDts - rgbLEDepochstart));
    epochdiff = LEDts(ledNIDAQidx)-rgbLEDepochstart;
    if (epochdiff > 0)
        samplsrtTime = chop(((ledNIDAQidx-2)+(1.000-epochdiff)),4);   
    else
        samplsrtTime = chop(((ledNIDAQidx-1)+(-epochdiff)),5); 
    end

    smplIdx = find((t<samplsrtTime+1e-5) & (t>samplsrtTime-1e-5));

    % Correction for timestamps
    cordptimesrt = t(smplIdx)-dptts(ledsrtIdx);
    corrgbtimesrt = t(smplIdx)-clrts(ledsrtIdx);
    correctdptts = dptts(ledsrtIdx:end)+cordptimesrt;  %-0.23;   % change and include the same for depth
    correctclrts = clrts(ledsrtIdx:end)+corrgbtimesrt;


    % RGBD first frame epoch aligner
    % Find closest value to first RGBD frame in NIDAQ LED timestamps
    [~,ledNIDAQFFidx] = min(abs(LEDts - clrUts(1)));   % Include the same for depth
    FFepochdiff = LEDts(ledNIDAQFFidx) - clrUts(1);
    if (FFepochdiff > 0)
        FFsamplsrtTime = chop(((ledNIDAQFFidx-2)+(1.000-FFepochdiff)),4); 
    else
        FFsamplsrtTime = chop(((ledNIDAQFFidx-1)+(-FFepochdiff)),4);
    end
    FFsmplIdx = find((t<FFsamplsrtTime+1e-5) & (t>FFsamplsrtTime-1e-5));

    % Correction for first frame timestamps
    FFcordptimesrt = t(FFsmplIdx)-dptts(1);
    FFcorrgbtimesrt = t(FFsmplIdx)-clrts(1);
    FFcorrectdptts = dptts+FFcordptimesrt;  % change and include the same for depth
    FFcorrectclrts = clrts+FFcorrgbtimesrt;
        
end
 
 
 
 