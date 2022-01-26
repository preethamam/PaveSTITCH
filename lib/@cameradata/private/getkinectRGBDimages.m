% 
% Get RGBD data from a given ONI file
%
%------------------------- Kinect RGBD data ------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/14/2014 @ 6:42 AM
%
% Syntax:       [I,D] = GETKINECTRGBDIMAGES (KinectHandles);
%
% Description:  Gets you the Kinect RGBD images for a given ONI
%               filename.
%               
% Inputs:       KinectHandles (array)
%
% Outputs:      I - RGB image
%               D - Depth image
%
% Note:         DONOT change/touch this function!
%    
% SEE ALSO:
% GETKINECTHANDLES, CAMERADATA
%--------------------------------------------------------------
 function [I,D] = getkinectRGBDimages (KinectHandles)

    % Start the Kinect Process
    
    % Get RGB image
    I = mxNiPhoto(KinectHandles);
    I = permute(I,[3 2 1]);
    
    % Get depth image
    D = mxNiDepth(KinectHandles);
    D = permute(D,[2 1]);

 end