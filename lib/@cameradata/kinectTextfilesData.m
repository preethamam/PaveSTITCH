%
% Obtain all the Kinect related text files data
%
%--------------------- Kinect text data -----------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/13/2014 @ 1:30 PM
%
% Syntax:       kintextData = KINECTTEXTFILESDATA (obj)
%
% Description:  Gets you all the text data in experimental 
%               data folder
%               
% Inputs:       object(obj.camTSfile, obj.camUnixTSfile, 
%               obj.ledUnixTSfile and obj.daqoutfile)
%
% Outputs:      kintextData (kintextData.clrts, kintextData.dptts, 
%               kintextData.clrUts, kintextData.dptUts,
%               kintextData.LEDts, kintextData.nofrms, 
%               kintextData.LEDpulse)
%               
% Note:         No change required!
%
% SEE ALSO:
% GETTESTDATAPATH, CAMERADATA
%--------------------------------------------------------------
function kintextData = kinectTextfilesData (obj)

    % Generate a valid path
    folderpath = gettestdatapath (obj.datafolderpath, obj.testfolder);

    % Camera Timestamps
    LDclrts = load([folderpath obj.camTSfile]);

    if (size(LDclrts, 2) > 1)
        flag = 1;
        for i = 1 : 2 : size(LDclrts, 2)
            kintextData.clrts(:, flag) = LDclrts(:,i)*1e-6;
            kintextData.dptts(:, flag) = LDclrts(:,i+1)*1e-6;
            flag = flag + 1;
        end
    else
        kintextData.clrts(:, 1) = LDclrts(:,1)*1e-6;
        kintextData.dptts(:, 1) = LDclrts(:,1)*1e-6;
    end

    % Software/Epoch Timestamps
    LDuxts = load([folderpath obj.camUnixTSfile]);
    if (size(LDuxts, 2) > 1)
      kintextData.dptUts = zeros(length(LDuxts)/4,1);
      kintextData.clrUts = zeros(length(LDuxts)/4,1);
      
        flag1 = 1;
        for i=1:4:length(LDuxts)
            kintextData.dptUts(flag1) = (LDuxts(i)+LDuxts(i+1))/2;
            kintextData.clrUts(flag1) = (LDuxts(i+2)+LDuxts(i+3))/2;
            flag1=flag1+1;
        end
        
    else
      kintextData.dptUts = LDuxts(:,1);
      kintextData.clrUts = LDuxts(:,1);                
    end

    % Software/Epoch Timestamps
    kintextData.LEDts = load([folderpath obj.ledUnixTSfile]);

    % Number of Frames
    kintextData.nofrms = length(kintextData.clrts);   

    % NIDAQ Data
    NIdaq = load([folderpath obj.daqoutfile]);

    % NIDAQ Pulse
    pulseraw = NIdaq(:,size(NIdaq,2));
    kintextData.LEDpulse = zeros(length(pulseraw),1);
    pulseMean = mean(pulseraw);
    for i=1:length(pulseraw)
        if (pulseraw(i) >= pulseMean)
            kintextData.LEDpulse(i,:) = 1;
        else
            kintextData.LEDpulse(i,:) = 0;
        end        
    end  
    
    obj.kintextoutput = kintextData;
end