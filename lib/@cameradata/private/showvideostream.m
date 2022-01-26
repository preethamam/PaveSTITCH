%  
% Displays the stream video RGB | Depth | Grayscale
%
%---------------------- Show video ------------------------
% Author:       Paghalaya
%
% Date 
% and time:     05/14/2014 @ 7:54 AM
%
% Syntax:       [] = SHOWVIDEOSTREAM (Corpts,Icorpts,RGB,DPT); or
%                    SHOWVIDEOSTREAM (Corpts,Icorpts,RGB,DPT);
%
% Description:  Streams the color and depth videos (Kinect)
%               
% Inputs:       RGBCorpts    - Corner points (applicable for grid RGB image 
%                              during calibration) overlayed on depth images
%               Imgraycorpts - Grayscale image display. Also includes the
%                              corner points (applicable for grid RGB image 
%                              during calibration) overlayed on grayscale 
%                              images.
%               RGB          - Color image
%               DPT          - Depth image
%
% Outputs:      Video stream only (no variables)
%
% Note:         DONOT change/touch this function!
%
% SEE ALSO:
% PICKAPIXEL, CAMERADATA
%--------------------------------------------------------------
 function showvideostream (RGBCorpts,Imgraycorpts,RGB,DPT)
 
    % Plot the color image
    subplot(2,2,1), 
    imshow(RGB);
    title('RGB Image','fontsize',14)

    % Plot the depth image
    subplot(2,2,2), 
    imshow(DPT,[0 9000]);
    colormap jet
    colorbar;

    % Check for RGBCorpts array, if not empty then overlay corner points
    % on the depth image
    if (isempty(RGBCorpts) == 0)
        hold on
        plot(RGBCorpts(:,1), RGBCorpts(:,2), 'r*');
        hold off
    end
    title('Depth Map Image','fontsize',14)


    % Check for Imgraycorpts array, if not empty then overlay corner points
    % on the grayscale image
    if (isempty(Imgraycorpts) == 0)
        subplot(2,2,3:4),
        imshow(Imgraycorpts);
        if (isempty(RGBCorpts) == 0)
            hold on
            plot(RGBCorpts(:,1), RGBCorpts(:,2), 'r*');
            hold off
        end
        title('Grayscale / Corner Detection','fontsize',14)
    end

    % Refresh the draw images handle to stream video
    drawnow;
 end