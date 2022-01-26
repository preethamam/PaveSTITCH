%
% Obtain Kinect handle to extract images from the .ONI file 
% (optional)
%     
%---------------------- Kinect handles ------------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/13/2014 @ 1:50 PM
%
% Syntax:       kinhandlez = KINECTHANDLES (obj)
%
% Description:  Gets you a Kinect handle (a pointer) to the 
%               current (t) RGBD image
%               
% Inputs:       object(obj.testfolder, obj.currONIname)
%
% Outputs:      kinhandlez (Kinect handle array)
%               
% Note:         No change required!
%
% SEE ALSO:
% GETTESTDATAPATH, GETKINECTHANDLES, CAMERADATA
%--------------------------------------------------------------
function kinhandlez = kinectHandles (obj)

    % ONI file path
    onipath    = gettestdatapath (obj.datafolderpath, obj.testfolder);

    % PC, Mac and Unix compatible
    if (ispc)
        kinhandlez = getkinecthandles([onipath obj.currONIname]);                    
    elseif (ismac || isunix)
        kinhandlez = getkinecthandles([onipath obj.currONIname]);    
    end            
end