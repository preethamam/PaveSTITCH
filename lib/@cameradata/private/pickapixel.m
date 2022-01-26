%
% Get LED pixel coordinates by a mouse click
%
%---------------------- Mouse click ---------------------------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/14/2014 @ 6:56 AM
%
% Syntax:       [Xrgb,Yrgb,BUTTON] = PICKAPIXEL (RGB,DPT);
%
% Description:  Gets you the mouse coordinate on an image. Image
%               coordinates
%               
% Inputs:       RGB - Color image 
%               DPT - Depth image
%
% Outputs:      Xrgb    - Column index
%               Yrgb    - Row index
%               BUTTON  - BUTTON is a vector of integers indicating 
%                         which mouse buttons you pressed (1 for left, 
%                         2 for middle, 3 for right), or ASCII numbers 
%                         indicating which keys on the keyboard 
%                         you pressed.
%
% Note:         DONOT change/touch this function!
%
% SEE ALSO:
% GETKINECTHANDLES, GETKINECTRGBDIMAGES, GINPUT, CAMERADATA
%--------------------------------------------------------------------------
 function [Xrgb,Yrgb,BUTTON] = pickapixel (RGB,DPT)

    % Plot RGB image
    subplot(1,2,1),
    imshow(RGB);
    title('RGB Image','fontsize',14)

    % Plot depth image
    subplot(1,2,2),
    imshow(DPT,[0 9000]); 
    colormap('jet');              
    title('Depth Map Image','fontsize',14)

    % Zoom and wait for click
    zoom on;
    waitfor(gcf,'CurrentCharacter',13)
    zoom reset
    zoom off
    
    % Get the pixel coordinates (refer GINPUT for more details)
    [Xrgb,Yrgb,BUTTON] = ginput(1);

 end