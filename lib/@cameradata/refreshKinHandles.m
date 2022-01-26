%
% Refresh Kinect handles to extract next (t+1) images from the .ONI file
% (optional)
%
%------------------- Refresh Kinect handles -------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/13/2014 @ 1:50 PM
%
% Syntax:       refdata = REFRESHKINHANDLES (obj)
%
% Description:  Refreshes the Kinect handle to the next frame
%               
% Inputs:       object(obj.kinecthandles)
%
% Outputs:      refdata (refdata.RGB,refdata.DPT)
%               Invisible frame updates!
%               
% Note:         No change required!
%
% SEE ALSO:
% GETKINECTRGBDIMAGES, GETKINECTHANDLES, CAMERADATA
%--------------------------------------------------------------
function refdata = refreshKinHandles (obj)

    % Gather color and depth image
    [refdata.RGB,refdata.DPT] = getkinectRGBDimages(obj.kinecthandles);
    
    % Update the Kinect handle
    mxNiUpdateContext(obj.kinecthandles)       
end