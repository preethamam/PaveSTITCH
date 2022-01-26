%
% Obtain Kinect RGBD images and save them in the parent testdata folder
%     
%---------------------- Kinect RGBD Images --------------------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/14/2014 @ 2:33 PM
%
% Syntax:       output = kinectRGBDimages (obj)
%
% Description:  Gets you all the Kinect RGBD images from all the given ONI
%               files (obj.allONIfiles)
%               
% Inputs:       object(obj.allONIfiles, obj.currONIname, obj.datafolderpath, 
%               obj.testfolder)
%
% Outputs:      output (success, if completed)
%               
% Note:         No change required!
%
% SEE ALSO:
% GETTESTDATAPATH, GETKINECTHANDLES, GETKINECTRGBDIMAGES,
% CAMERADATA
%--------------------------------------------------------------------------
function output = kinectRGBDimages (obj)

    % Generate a valid path
    folderpath = gettestdatapath (obj.datafolderpath, obj.testfolder);
    
    % Waitbar setup parameters
    h = waitbar(0,'Please wait. This may take few seconds!','Name','Ripping Images from ONI files!',...
                  'CreateCancelBtn',...
                  'setappdata(gcbf,''canceling'',1)');
    setappdata(h,'canceling',0)        % Waitbar setup parameters

    for i = 1:length(obj.allONIfiles)

        % Cancel button
        if getappdata(h,'canceling')
            break
        end

        % Get LED Kinect Handle
        onipath    = gettestdatapath (obj.datafolderpath, obj.testfolder);
        cell2str = cell2mat(obj.allONIfiles{i});
        KinectHandles = getkinecthandles ([onipath cell2str]);

        for j = 1:obj.kintextoutput.nofrms
            
            % Kinect Load Files
            [RGB,DPT]= getkinectRGBDimages(KinectHandles);
            
            % Create color image
            imwrite(RGB,[folderpath 'C0' num2str(i) '_' 'Fr' '_' ...
                    num2str(j) '_' 'RGB' '.png']);
            
            % Create depth image
            imwrite(DPT,[folderpath 'C0' num2str(i) '_' 'Fr' '_' ...
                    num2str(j) '_' 'DPT' '.png']);                        

            % Report current estimate in the waitbar's message field
            waitbar (j/obj.kintextoutput.nofrms, h, ...
                sprintf('Camera: %i | Frame No.: %i',i, j))
            
            % Update kinect handle for next frame
            mxNiUpdateContext(KinectHandles);
        end  

            % Stop the Kinect Process
            mxNiDeleteContext(KinectHandles);
    end  

    % 
    output = 'success';    
end