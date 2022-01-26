% 
% Get Kinect handles for the given ONI file
%
%---------------------- Kinect handles ------------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/13/2014 @ 3:22 PM
%
% Syntax:       KinectHandles = GETKINECTHANDLES (onifilename);
%
% Description:  Gets you the Kinect handle for a given ONI
%               filename.
%               
% Inputs:       onifilename
%
% Outputs:      KinectHandles
%
% Note:         DONOT change/touch this function!
%
% SEE ALSO:
% GETKINECTRGBDIMAGES, CAMERADATA
%--------------------------------------------------------------
function KinectHandles = getkinecthandles (onifilename)

    % Add read files XML file
    SAMPLE_XML_PATH = 'config\SamplesConfig.xml';

    % Start the Kinect Process
    KinectHandles = mxNiCreateContext(SAMPLE_XML_PATH, onifilename);

end