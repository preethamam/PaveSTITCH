%
% Obtain the LED threshold RGB(grayscale) value
%
%------------------- Refresh Kinect handles -------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/13/2014 @ 1:50 PM
%
% Syntax:       LEDthreshold = kinectLEDthreshold (obj)
%
% Description:  Refreshes the Kinect handle to the next frame
%               
% Inputs:       object(obj.kinecthandles)
%
% Outputs:      refdata (refdata.RGB,refdata.DPT)
%               
% Note:         No change required!
%
%--------------------------------------------------------------
function LEDthreshold = kinectLEDthreshold (obj)
    % Check for minimum thresholding frames
    if (obj.thresfrms < 1000)
        error('Atleast I need 1000 frames to provide you a threshold');
    end

    % Initialize mean array
    LEDmeanvals = zeros(length(obj.thresfrms),1);

    % Get LED Kinect Handle
    onipath    = gettestdatapath (obj.datafolderpath, obj.testfolder);
    oneLEDKinectHandles = getkinecthandles([onipath obj.currONIname]);


    % Waitbar setup parameters
    h = waitbar(0,'Please wait. This may take few seconds!','Name','Approximating LED Threshold',...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
    setappdata(h,'canceling',0)

    for i = 1:obj.thresfrms
        % Check for Cancel button press
        if getappdata(h,'canceling')
            break
        end

        % Kinect Load Files
        [RGB,DPT]= getkinectRGBDimages(oneLEDKinectHandles);       


        if ((i==1) && (obj.ledshift==1))

            % Initialize array and flag
            ledpixcoord = zeros(obj.ledwindow^2,2);
            flag = 1;

            % Pick a pixel callback
            [Xrgb,Yrgb,~] = pickapixel(RGB,DPT);  
            Xrgb = round(Xrgb);
            Yrgb = round(Yrgb);
            Xrgbstart = Xrgb -((obj.ledwindow-1)/2)-1;
            Yrgbstart = Yrgb -((obj.ledwindow-1)/2)-1;

            % Extract coordinates around PickAPixel
            for j = 1:obj.ledwindow
                for k = 1:obj.ledwindow
                    ledpixcoord(flag,:) = [Yrgbstart+j  Xrgbstart+k];
                    flag = flag+1; 
                end                    
            end

            % Save the center and surrounding coordinates
            save ZZ_LEDcentroid.mat Xrgb Yrgb ledpixcoord
        else

            % Load when the same experiment is ran
            load ZZ_LEDcentroid.mat                
        end

        % Grayscale conversion
        imgray = rgb2gray(RGB);

        % Display video callback
        if (strncmp(obj.videostate,'on',3))
            showvideostream([],imgray,RGB,DPT);
        end

        % Find the mean grayscale value of LED window
        ledpixval = zeros(obj.ledwindow^2,1);
        for m = 1:length(ledpixcoord)
            ledpixval (m) = imgray(round(ledpixcoord(m,1)), round(ledpixcoord(m,2)));
        end

        % LED mean values array
        LEDmeanvals(i) = round(mean(ledpixval));

        % Update Kinect handles
        mxNiUpdateContext(oneLEDKinectHandles);

        % Report current estimate in the waitbar's message field
        waitbar (i/obj.thresfrms,h, sprintf('Please wait. Current Frame No.: %i',i))
    end

    % DELETE the waitbar; don't try to CLOSE it.
    delete(h)       

    % LED threshold values
    LEDthreshold = floor(mean(LEDmeanvals(100:end)));

    % Stop the Kinect Process
    mxNiDeleteContext(oneLEDKinectHandles);

end