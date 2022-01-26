classdef Class_PPHandler
    %CLASS_Postprocess Summary of this class goes here
    % This class include the post-processing properties and methods
    %   Detailed explanation goes here
    
    properties
        GPS_latnlog
        testfolder
        GPSfile
        x
        y
        varargin
        classi_GPS_latnlog = []
        plotclassifier
        GPS_vehiclespeed
        FFTsig = []
        FFT_Fs = []
        pathtype = 'continuous'
        Experiment_Title = []
        Ori_LEDstates = []
        SynKpacK_input = []
        User_Timerange = [0 10]
        User_accleroIDs = 1
        linespec = [1 1]
        LEDcamdata = []
        vid_delay = 4
        videostate = 'on'
        ONIname  = []        
    end
    
    methods
        
        % Constructor Initilaization
        function inputObj = Class_PPHandler(inpstruct)      
            if nargin >= 1
                inputObj.GPS_latnlog       = inpstruct.GPS_latnlog;
                inputObj.testfolder        = inpstruct.testfolder;
                inputObj.GPSfile           = inpstruct.GPSfile;
                inputObj.x                 = inpstruct.x;
                inputObj.y                 = inpstruct.y;
                inputObj.varargin          = inpstruct.varargin;
                inputObj.classi_GPS_latnlog = inpstruct.classi_GPS_latnlog;
                inputObj.plotclassifier    = inpstruct.plotclassifier;
                inputObj.GPS_vehiclespeed  = inpstruct.GPS_vehiclespeed;
                inputObj.FFTsig            = inpstruct.FFtsignal;
                inputObj.FFT_Fs            = inpstruct.FFT_Fs;
                inputObj.pathtype          = inpstruct.pathtype;
                inputObj.Experiment_Title  = inpstruct.ExpName;
                inputObj.Ori_LEDstates     = inpstruct.Ori_LEDstates;
                inputObj.SynKpacK_input    = inpstruct.SynKpacK_input;
                inputObj.User_Timerange    = inpstruct.User_Timerange;
                inputObj.User_accleroIDs   = inpstruct.User_Acclerometers;
                inputObj.linespec          = inpstruct.linespecifiers;
                inputObj.LEDcamdata        = inpstruct.LEDcamdata;
                inputObj.vid_delay         = inpstruct.vid_delay;
                inputObj.videostate        = inpstruct.videostate;
                inputObj.ONIname           = inpstruct.ONIname;
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
                
        function PlotRoadMap = PlotRoadMap(inputObj)
        
        %--------------------------------------------------------------------------
        % GPS data load    
        gpsdat = load (inputObj.GPSfile);
        LatnLong = [ gpsdat(:,2), gpsdat(:,1) ];
        
        % Find the distance of the experiment
        for i = 1:length(LatnLong)-1
            PlotRoadMap.VehiDistArray(i,1) = distdim(distance(gpsdat(i,1), gpsdat(i,2), ...
                                           gpsdat(i+1,1), gpsdat(i+1,2)),...
                                           'deg','kilometers');
        end

        PlotRoadMap.TotalDist_KiloMeters = sum(PlotRoadMap.VehiDistArray);
        PlotRoadMap.TotalDist_Miles = PlotRoadMap.TotalDist_KiloMeters / 1.6;
        
        %--------------------------------------------------------------------------
        % Plot pavement distress classification and route data by Google map
        h = zeros(1,5);
        switch inputObj.pathtype
            case 'continuous'
            latlold = [ LatnLong(1,1), LatnLong(1, 2) ];        
            figure;
            hold on
            for i = 2:length(gpsdat)
                if ((gpsdat(i,5) >= 0) && (gpsdat(i,5) <= 30))
                    latlnew = [LatnLong(i,1), LatnLong(i, 2)];
                    long = [latlold(1); latlnew(1)];
                    lat  = [latlold(2); latlnew(2)];
                    if (inputObj.linespec(1) == 1)
                        h(1) = plot(long, lat , '-o', 'color', ...
                               [233 17 212]/255, 'LineWidth', 1); 
                    elseif (inputObj.linespec(1) == 0)
                        h(1) = plot(long, lat , 'color', ...
                               [233 17 212]/255, 'LineWidth', 2);                        
                    end
                    
                elseif ((gpsdat(i,5) > 30) && (gpsdat(i,5) <= 40))
                    latlnew = [LatnLong(i,1), LatnLong(i, 2)];
                    long = [latlold(1); latlnew(1)];
                    lat  = [latlold(2); latlnew(2)];
                    if (inputObj.linespec(1) == 1)
                        h(2) = plot(long, lat , '-x', 'color', ...
                               [0 153 0]/255, 'LineWidth', 1); 
                    elseif (inputObj.linespec(1) == 0)
                        h(2) = plot(long, lat , 'color', ...
                               [0 153 0]/255, 'LineWidth', 2);                        
                    end                    
                    
                elseif ((gpsdat(i,5) > 40) && (gpsdat(i,5) <= 50))
                    latlnew = [LatnLong(i,1), LatnLong(i, 2)];
                    long = [latlold(1); latlnew(1)];
                    lat  = [latlold(2); latlnew(2)];
                    if (inputObj.linespec(1) == 1)
                        h(3) = plot(long, lat , '-d', 'color', ...
                               [0 0 128]/255, 'LineWidth', 1); 
                    elseif (inputObj.linespec(1) == 0)
                        h(3) = plot(long, lat , 'color', ...
                               [0 0 128]/255, 'LineWidth', 2);                        
                    end                     
                   
                elseif ((gpsdat(i,5) > 50) && (gpsdat(i,5) <= 60))
                    latlnew = [LatnLong(i,1), LatnLong(i, 2)];
                    long = [latlold(1); latlnew(1)];
                    lat  = [latlold(2); latlnew(2)];
                    if (inputObj.linespec(1) == 1)
                        h(4) = plot(long, lat , '-v', 'color', ...
                               [0 255 255]/255, 'LineWidth', 1); 
                    elseif (inputObj.linespec(1) == 0)
                        h(4) = plot(long, lat , 'color', ...
                               [0 255 255]/255, 'LineWidth', 2);                        
                    end  
                   
                else
                    latlnew = [LatnLong(i,1), LatnLong(i, 2)];
                    long = [latlold(1); latlnew(1)];
                    lat  = [latlold(2); latlnew(2)];
                    if (inputObj.linespec(1) == 1)
                        h(5) = plot(long, lat , '-^', 'color', ...
                               [255 51 51]/255, 'LineWidth', 1); 
                    elseif (inputObj.linespec(1) == 0)
                        h(5) = plot(long, lat , 'color', ...
                               [255 51 51]/255, 'LineWidth', 2);                        
                    end  
                    
                end
                latlold = latlnew;
            end
            hold off
            
            case 'discrete'            
            figure;
            hold on
            for i = 1:length(gpsdat)
                if ((gpsdat(i,5) >= 0) && (gpsdat(i,5) <= 30))                  
                    h(1) = plot(LatnLong(i,1), LatnLong(i,2) , 'color', [233 17 212]/255, 'Marker', 'o', 'MarkerSize', 5); 
                elseif ((gpsdat(i,5) > 30) && (gpsdat(i,5) <= 40))                   
                    h(2) = plot(LatnLong(i,1), LatnLong(i,2), 'color', [0 153 0]/255, 'Marker', 'x', 'MarkerSize', 5); 
                elseif ((gpsdat(i,5) > 40) && (gpsdat(i,5) <= 50))                   
                    h(3) = plot(LatnLong(i,1), LatnLong(i,2), 'color', [0 0 128]/255, 'Marker', 'd', 'MarkerSize', 5); 
                elseif ((gpsdat(i,5) > 50) && (gpsdat(i,5) <= 60))                   
                    h(4) = plot(LatnLong(i,1), LatnLong(i,2), 'color', [0 255 255]/255, 'Marker', 'v', 'MarkerSize', 5);
                else                    
                    h(5) = plot(LatnLong(i,1), LatnLong(i,2), 'color', [255 51 51]/255, 'Marker', '^', 'MarkerSize', 5); 
                end                
            end
            hold off             
        end
            funct_plot_google_map('maptype', 'roadmap');
%             annotation('textbox', [.1 0.6 0.1 0.1], 'BackgroundColor', [1 1 1], ...
%                        'String', ['Track Length: ' num2str(PlotRoadMap.TotalDist_Miles)...
%                        ' miles']);
       
            starting = line(LatnLong(1, 1), LatnLong(1, 2), 'Marker', 'o', ...
            'Color', [104 104 11]/255, 'MarkerFaceColor', [104 104 11]/255, 'MarkerSize', 10);

            ending = line(LatnLong(end, 1), LatnLong(end, 2), 'Marker', 's', ...
            'Color', [102 0 0]/255, 'MarkerFaceColor', [102 0 0]/255, 'MarkerSize', 10);
        
            if (inputObj.linespec(2) == 1)
                % Loop to plot the classification data
                unqarray = zeros(size(inputObj.classi_GPS_latnlog,1),2);
                for i = 1 : size(inputObj.classi_GPS_latnlog,1)
                 lhandler = line(inputObj.classi_GPS_latnlog(i, 2), inputObj.classi_GPS_latnlog(i, 1),   ...
                            'Marker', inputObj.plotclassifier{inputObj.classi_GPS_latnlog(i, 3)}{2}, ...
                            'Color', inputObj.plotclassifier{inputObj.classi_GPS_latnlog(i, 3)}{4}/255, ...
                            'MarkerFaceColor', inputObj.plotclassifier{inputObj.classi_GPS_latnlog(i, 3)}{4}/255,...
                            'MarkerSize', inputObj.plotclassifier{inputObj.classi_GPS_latnlog(i, 3)}{3});
                 unqarray(i,:) = [lhandler inputObj.classi_GPS_latnlog(i, 3)]; 
                end          

                [c1,ia1,ic1] = unique(unqarray(:,2));
                lhand = unqarray(:,1);
                hvals = lhand(ia1);  % Unique handle values

                % Cell array concatenation for legend names
                legend_string_cell = cell (7+length(c1), 1);

                % Speed legend string
                legend_string_cell{1} = '00-30 MPH';
                legend_string_cell{2} = '30-40 MPH';
                legend_string_cell{3} = '40-50 MPH';
                legend_string_cell{4} = '50-60 MPH';
                legend_string_cell{5} = ' > 60 MPH';

                % Start/end point legend string
                legend_string_cell{6} = 'Start Point';
                legend_string_cell{7} = 'End Point';
                for i = 8 : (7+length(c1))
                    legend_string_cell{i} = inputObj.plotclassifier{i-7,1}{5};                
                end 

                % Legend and title
                legend([h starting ending hvals'], legend_string_cell)
            
            elseif (inputObj.linespec(2) == 0)
                
                % Speed legend string
                legend_string_cell{1} = '00-30 MPH';
                legend_string_cell{2} = '30-40 MPH';
                legend_string_cell{3} = '40-50 MPH';
                legend_string_cell{4} = '50-60 MPH';
                legend_string_cell{5} = ' > 60 MPH';

                % Start/end point legend string
                legend_string_cell{6} = 'Start Point';
                legend_string_cell{7} = 'End Point';
                
                % Legend and title
                legend([h starting ending], legend_string_cell)                
                
            end
            title([inputObj.Experiment_Title ' [Track Length: ' ...
                   num2str(PlotRoadMap.TotalDist_Miles) ' miles]']);

            xlim([min(LatnLong(:,2)), max(LatnLong(:,2))]);
            axis equal off   
        end
        
        function output = logPlots (inputObj)
            figure;
            grid on;
            output = funct_logfit(inputObj.x,inputObj.y,inputObj.varargin);
            
        end
        
        function output = FFTPlots (inputObj)
            output = func_plotFFT(inputObj.FFT_Fs,inputObj.FFTsig);
            
        end
        
        function output = FullSpan_PavementSynchroPlots (inputObj)            
            %--------------------------------------------------------------------------
            % SynKpacK Effective Path GPS plotting            
            gpsdat = load (inputObj.GPSfile);
            LatnLong = [ inputObj.GPS_latnlog(:,2), inputObj.GPS_latnlog(:,1) ];            
            
            switch inputObj.pathtype
                case 'continuous'
                latlold = [ LatnLong(1,1), LatnLong(1, 2) ];        
                figure;
                hold on
                for i = 2:length(LatnLong)
                        latlnew = [LatnLong(i,1), LatnLong(i, 2)];
                        long = [latlold(1); latlnew(1)];
                        lat  = [latlold(2); latlnew(2)];
                        if (inputObj.linespec(1) == 1)
                            h(1) = plot(long, lat , '-o', 'color', ...
                                   [255 0 255]/255, 'LineWidth', 1); 
                        elseif (inputObj.linespec(1) == 0)
                            h(1) = plot(long, lat , 'color', ...
                                    [255 0 255]/255, 'LineWidth', 2);                        
                        end
                    
                        latlold = latlnew;
                end
                hold off

                case 'discrete'            
                figure;
                hold on
                for i = 1:length(LatnLong)                    
                    h(1) = plot(LatnLong(i,1), LatnLong(i,2) ,...
                           'color', [255 0 255]/255, 'Marker', 'o', 'MarkerSize', 5);                         
                end
                hold off             
            end
            
            % Plot Google maps
            output = funct_plot_google_map('maptype', 'roadmap');
            
            starting = line(LatnLong(1, 1), LatnLong(1, 2), 'Marker', 'o', ...
            'Color', [104 104 11]/255, 'MarkerFaceColor', [104 104 11]/255, 'MarkerSize', 10);
        
            % Start/end point legend string
            legend_string_cell{1} = ['SynKpacK Effective Path' ...
                                    ' [' num2str(0) ' - ' num2str(max(inputObj.SynKpacK_input.frmno_time(:,3)))  ' sec.]' ];
            legend_string_cell{2} = 'Start Point';
            legend_string_cell{3} = 'End Point';     

            ending = line(LatnLong(end, 1), LatnLong(end, 2), 'Marker', 's', ...
            'Color', [102 0 0]/255, 'MarkerFaceColor', [102 0 0]/255, 'MarkerSize', 10);
        
            legend([h starting ending ], legend_string_cell)
            title([inputObj.Experiment_Title ' - ' 'SynKpacK']);

            xlim([min(LatnLong(:,2)), max(LatnLong(:,2))]); 
            axis equal off
            %}
            
            %--------------------------------------------------------------------------
            % Plots of acceleration, velocity and displacement time histories            
            % Number of accelerometers
            noacc = length (inputObj.User_accleroIDs);
                        
            % Arrange acceleration, velocity and displacement time
            % histories for SUBPLOT function accordingly
            AVDtank = zeros(length(inputObj.SynKpacK_input.frmno_time(:,3)), noacc*3);
            
            for i = 1:noacc
                
                AVDtank(:, 3*i-2:3*i) = [ inputObj.SynKpacK_input.Accl(:,i), ...
                                inputObj.SynKpacK_input.Velo(:,i), ...
                                inputObj.SynKpacK_input.Disp(:,i)];
                
            end

            figure
            for k = 1:noacc*3                
                if (noacc == 1)
                  sp(k) = subplot(3, noacc, k);                  
                  plot(inputObj.SynKpacK_input.frmno_time(:,3), ...
                       AVDtank(:,k));
                  grid on;
                   
                  if (k==1)
                       title ('Acceleration (m/s^2)', 'interpreter','tex')
                  elseif (k==2)
                       title ('Velocity (m/s)','interpreter','tex')
                  elseif (k==3)
                       title ('Displacement (m)')
                  end
                   
                   xlabel('Time (sec)')
                   ylabel('Unit')
                else
                  sp(k) = subplot(noacc, 3, k);                  
                  plot(inputObj.SynKpacK_input.frmno_time(:,3), ...
                       AVDtank(:,k));
                   grid on;
                   
                   if (k==1)
                       title ('Acceleration (m/s^2)', 'interpreter','tex')
                   elseif (k==2)
                       title ('Velocity (m/s)','interpreter','tex')
                   elseif (k==3)
                       title ('Displacement (m)')
                   end
                   
                    xlabel('Time (sec)')
                    ylabel('Unit')
                end
            end
            
            % Plot Xtras
            if (noacc == 1)
                
                % Xmin and max
                Xmax = max(inputObj.SynKpacK_input.frmno_time(:,3));

                % Ymin and max
                Ymin = min(min(AVDtank));
                Ymax = max(max(AVDtank));
                
                % Axes linker and its limit
                linkaxes(sp,'x')

                set(sp,'XLim',[0 Xmax])
                
                if (0)
                    supth = suptitle ('Time Histories of Inertial Sensors');
                    set(supth,'FontSize',8,'FontWeight','normal')
                end                
            else
                % Xmin and max
                Xmax = max(inputObj.SynKpacK_input.frmno_time(:,3));

                % Ymin and max
                Ymin = min(min(AVDtank));
                Ymax = max(max(AVDtank));


                % Axes linker and its limit
                linkaxes(sp,'x')

                set(sp,'XLim',[0 Xmax])
                set(sp(1:3:noacc*3),'YLim',[min(min(inputObj.SynKpacK_input.Accl))...
                                            max(max(inputObj.SynKpacK_input.Accl))])
                set(sp(2:3:noacc*3),'YLim',[min(min(inputObj.SynKpacK_input.Velo))...
                                            max(max(inputObj.SynKpacK_input.Velo))])
                set(sp(3:3:noacc*3),'YLim',[min(min(inputObj.SynKpacK_input.Disp))...
                                            max(max(inputObj.SynKpacK_input.Disp))])
                if (0)
                    supth = suptitle ('Time Histories of Inertial Sensors');
                    set(supth,'FontSize',8,'FontWeight','normal')
                end

                %--------------------------------------------------------------------------
                % Plot of LED time histories
                figure;
                hold on
                led(1) = plot(inputObj.Ori_LEDstates(:,1), inputObj.Ori_LEDstates(:,2),...
                      'b--','LineWidth',2);                             
                led(2) = stem(inputObj.SynKpacK_input.frmno_time(:,3),...
                             inputObj.SynKpacK_input.LEDstate,'r');
                hold off
                set(led(2), 'Marker', '.');
                xlabel('Time (seconds)')
                ylabel('Onoff State')
                legend ([led(1) led(2)], 'Continuous LED State', 'Camera Captured LED Event')
                title('LED Pulse vs. Camera capture Timing')
                axis tight
                
                %--------------------------------------------------------------------------
                % Plot of Latitude vs. Longitude
                figure;
                plot(inputObj.GPS_latnlog(:,2), inputObj.GPS_latnlog(:,1), '-.r', 'LineWidth', 2)
                grid on
                xlabel ('Logitude')
                ylabel ('Latitude')
                title ('Phase Plot of Logitude vs. Latitude')
                
                
            end
            
            
            
        end
        
        function output = UserSpan_PavementSynchroPlots (inputObj)
           
            %--------------------------------------------------------------------------
            % GPS data load
            gpsdat = load (inputObj.GPSfile);
            LatnLong = [ inputObj.GPS_latnlog(:,2), inputObj.GPS_latnlog(:,1) ];            
            
            %--------------------------------------------------------------------------
            % User defined start time index
            if (inputObj.User_Timerange(1) < min(inputObj.SynKpacK_input.frmno_time(:,3)))
               error ('Please Check...! Time Range Minimum Value is Out-of-bound') 
            end
            
            [~,startind] = min(abs(inputObj.SynKpacK_input.frmno_time(:,3) ...
                                - inputObj.User_Timerange(1)));            

            % User defined end time index
            if (inputObj.User_Timerange(2) > max(inputObj.SynKpacK_input.frmno_time(:,3)))
               error ('Please Check...! Time Range Maximum Value is Out-of-bound') 
            end
            
            [~, endind]   = min(abs(inputObj.SynKpacK_input.frmno_time(:,3) ...
                                - inputObj.User_Timerange(2)));             

            %--------------------------------------------------------------------------
            switch inputObj.pathtype
                case 'continuous'
                latlold = [ LatnLong(1,1), LatnLong(1, 2) ];        
                figure;
                hold on  
                
                for i = 2:length(LatnLong)               
                    if ((i >= startind) && (i <= endind))
                        latlnew = [LatnLong(i,1), LatnLong(i, 2)];
                        long = [latlold(1); latlnew(1)];
                        lat  = [latlold(2); latlnew(2)];
                        if (inputObj.linespec(1) == 1)
                            h(2) = plot(long, lat , '-d', 'color', ...
                                   [0 0 128]/255, 'LineWidth', 1); 
                        elseif (inputObj.linespec(1) == 0)
                            h(2) = plot(long, lat , 'color', ...
                                    [0 0 128]/255, 'LineWidth', 2);                        
                        end
                        
                    else                      
                        latlnew = [LatnLong(i,1), LatnLong(i, 2)];
                        long = [latlold(1); latlnew(1)];
                        lat  = [latlold(2); latlnew(2)];
                        if (inputObj.linespec(1) == 1)
                            h(1) = plot(long, lat , '-o', 'color', ...
                                   [255 0 255]/255, 'LineWidth', 1); 
                        elseif (inputObj.linespec(1) == 0)
                            h(1) = plot(long, lat , 'color', ...
                                   [255 0 255]/255, 'LineWidth', 2);                        
                        end                        
                    end                    
                    latlold = latlnew;

                end
                hold off

                case 'discrete'            
                figure;
                hold on
                for i = 1:length(LatnLong)                    
                    if ((i >= startind) && (i <= endind))
                        h(2) = plot(LatnLong(i,1), LatnLong(i,2) , 'color', [0 0 128]/255,...
                                'Marker', 'd', 'MarkerSize', 5); 
                    else
                        h(1) = plot(LatnLong(i,1), LatnLong(i,2), 'color', [255 0 255]/255, ...
                                'Marker', 'o', 'MarkerSize', 5); 
                    end                                           
                end
                hold off             
            end
            
            % Plot Google maps
            output = funct_plot_google_map('maptype', 'roadmap');
            
            starting = line(LatnLong(1, 1), LatnLong(1, 2), 'Marker', 'o', ...
            'Color', [104 104 11]/255, 'MarkerFaceColor', [104 104 11]/255, 'MarkerSize', 10);
        
            % Start/end point legend string
            legend_string_cell{1} = ['SynKpacK Effective Path' ...
                                    ' [' num2str(0) ' - ' num2str(max(inputObj.SynKpacK_input.frmno_time(:,3)))  ' sec.]' ];
            legend_string_cell{2} = ['User Defined Time Range' ...
                                    ' [' num2str(inputObj.User_Timerange(1)) ' - ' num2str(inputObj.User_Timerange(2))  ' sec.]' ];
            legend_string_cell{3} = 'Start Point';
            legend_string_cell{4} = 'End Point';     

            ending = line(LatnLong(end, 1), LatnLong(end, 2), 'Marker', 's', ...
            'Color', [102 0 0]/255, 'MarkerFaceColor', [102 0 0]/255, 'MarkerSize', 10);
        
            legend([h starting ending ], legend_string_cell)
            title([inputObj.Experiment_Title ' - ' 'SynKpacK']);

            xlim([min(LatnLong(:,2)), max(LatnLong(:,2))]);
            axis equal off   
            
            %--------------------------------------------------------------------------
            % Plots of acceleration, velocity and displacement time histories            
            % Number of accelerometers
            noacc = length (inputObj.User_accleroIDs);
                        
            % Arrange acceleration, velocity and displacement time
            % histories for SUBPLOT function accordingly
            AVDtank = zeros(length(inputObj.SynKpacK_input.frmno_time(:,3)), noacc*3);
            
            for i = 1:noacc
                
                AVDtank(:, 3*i-2:3*i) = [ inputObj.SynKpacK_input.Accl(:,i), ...
                                inputObj.SynKpacK_input.Velo(:,i), ...
                                inputObj.SynKpacK_input.Disp(:,i)];
                
            end

            figure
            for k = 1:noacc*3                
                if (noacc == 1)
                  sp(k) = subplot(3, noacc, k);                  
                  plot(inputObj.SynKpacK_input.frmno_time(:,3), ...
                       AVDtank(:,k));  
                  grid on;
                  
                  if (k==1)
                       title ('Acceleration (m/s^2)', 'interpreter','tex')
                  elseif (k==2)
                       title ('Velocity (m/s)','interpreter','tex')
                  elseif (k==3)
                       title ('Displacement (m)')
                  end
                   
                   xlabel('Time (sec)')
                   ylabel('Unit')
                else
                  sp(k) = subplot(noacc, 3, k);
                  
                  plot(inputObj.SynKpacK_input.frmno_time(:,3), ...
                       AVDtank(:,k));
                  grid on; 
                  
                   if (k==1)
                       title ('Acceleration (m/s^2)', 'interpreter','tex')
                   elseif (k==2)
                       title ('Velocity (m/s)','interpreter','tex')
                   elseif (k==3)
                       title ('Displacement (m)')
                   end
                   
                    xlabel('Time (sec)')
                    ylabel('Unit')
                end
            end
            
            % Plot Xtras
            if (noacc == 1)
                
                % Xmin and max
                Xmax = max(inputObj.SynKpacK_input.frmno_time(:,3));

                % Ymin and max
                Ymin = min(min(AVDtank));
                Ymax = max(max(AVDtank));
                
                % Axes linker and its limit
                linkaxes(sp,'x')

                set(sp,'XLim', inputObj.User_Timerange )
                zoom('on')
                
                if (0)
                    supth = suptitle ('Time Histories of Inertial Sensors');
                    set(supth,'FontSize',8,'FontWeight','normal')
                end                           
            else
                % Xmin and max
                Xmax = max(inputObj.SynKpacK_input.frmno_time(:,3));

                % Ymin and max
                Ymin = min(min(AVDtank));
                Ymax = max(max(AVDtank));


                % Axes linker and its limit
                linkaxes(sp,'x')

                set(sp,'XLim', inputObj.User_Timerange )
                zoom('on')

                set(sp(1:3:noacc*3),'YLim',[min(min(inputObj.SynKpacK_input.Accl))...
                                            max(max(inputObj.SynKpacK_input.Accl))])
                set(sp(2:3:noacc*3),'YLim',[min(min(inputObj.SynKpacK_input.Velo))...
                                            max(max(inputObj.SynKpacK_input.Velo))])
                set(sp(3:3:noacc*3),'YLim',[min(min(inputObj.SynKpacK_input.Disp))...
                                            max(max(inputObj.SynKpacK_input.Disp))])
                if (0)
                    supth = suptitle ('Time Histories of Inertial Sensors');
                    set(supth,'FontSize',8,'FontWeight','normal')
                end

                %--------------------------------------------------------------------------
                % Plot of LED time histories
                figure;
                hold on
                led(1) = plot(inputObj.Ori_LEDstates(:,1), inputObj.Ori_LEDstates(:,2),...
                      'b--','LineWidth',2);                             
                led(2) = stem(inputObj.SynKpacK_input.frmno_time(:,3),...
                             inputObj.SynKpacK_input.LEDstate,'r');
                hold off
                set(led(2), 'Marker', '.');
                xlabel('Time (seconds)')
                ylabel('Onoff State')
                legend ([led(1) led(2)], 'Continuous LED State', 'Camera Captured LED Event')
                title('LED Pulse vs. Camera capture Timing')
                
                % Axes linker and its limit
                xlim(inputObj.User_Timerange)
                zoom('on')
                          
                %--------------------------------------------------------------------------
                % Plot of Latitude vs. Longitude
                % Find user defined latitude and longitude range
                latitude_range  = inputObj.GPS_latnlog(:,1);
                longitude_range = inputObj.GPS_latnlog(:,2);
                
                figure;                
                plot(longitude_range(startind:endind), latitude_range(startind:endind),...
                     '-.r', 'LineWidth', 2)
                grid on
                xlabel ('Logitude')
                ylabel ('Latitude')
                title ('Phase Plot of Logitude vs. Latitude [User-Defined Time Range]')
                
                % Axes linker and its limit
                xlim([min(longitude_range(startind:endind))...
                      max(longitude_range(startind:endind))])
                zoom('on')

            end
            
        end
        
        function video_show  = show_pavement_distress  (inputObj)           
        
        % Obtain video frame numbers that to be displayed    
        
            % User defined start time index
            if (inputObj.User_Timerange(1) < min(inputObj.SynKpacK_input.frmno_time(:,3)))
               error ('Please Check...! Time Range Minimum Value is Out-of-bound') 
            end
            
            [~,startind] = min(abs(inputObj.SynKpacK_input.frmno_time(:,3) ...
                                - inputObj.User_Timerange(1)));            

            % User defined end time index
            if (inputObj.User_Timerange(2) > max(inputObj.SynKpacK_input.frmno_time(:,3)))
               error ('Please Check...! Time Range Maximum Value is Out-of-bound') 
            end
            
            [~, endind]   = min(abs(inputObj.SynKpacK_input.frmno_time(:,3) ...
                                - inputObj.User_Timerange(2)));
        
        startframe = inputObj.SynKpacK_input.frmno_time(startind, 2);

        endframe = inputObj.SynKpacK_input.frmno_time(endind, 2);
        
        % Get LED Kinect Handle
        onipath       = gettestdatapath (inputObj.testfolder);
        KinectHandles = func_getkinecthandles([onipath '\' inputObj.ONIname]);  

            for i = 1:inputObj.LEDcamdata.nofrms
                
                % Call figure instance
                if ((i==1) && (strncmp(inputObj.videostate,'on',3)))
                    figure;
                end
                
                % Turn on/off the video
                if (strncmp(inputObj.videostate,'on',3) && ...
                           (i>= startframe && i<= endframe))
                    % Kinect Load Files
                    [RGB,DPT]= func_KinRGBD(KinectHandles);     

                    % Convert RGB to grayscale
                    gryim = rgb2gray(RGB);  

                    % show video
                    func_showvideo([],gryim,RGB,DPT, i);
                    
                    % pause frame of human visualization
                    pause(inputObj.vid_delay);
                    
                elseif (i > endframe)                   
                    break;
                end
                
                % Update video frame
                mxNiUpdateContext(KinectHandles); 
                
                % Diplay frames
                clc
                disp(i)
            end
            
            % Stop the Kinect Process
            mxNiDeleteContext(KinectHandles);
            
            % Ran successfully
            video_show = 'Video Display Success';           
        end
        
    end
    
end



%% Class only special functions (No access outside the class)
%-------------------------------------------------------------------------
function func_framealignmentplot (DAQTYPE,t,onoff,dLVDT,accplot,correctclrts, sigflt, LEDpulse,...
         ledRGBDsrtIdx)

switch DAQTYPE

case 1
        figure;

        %Plot from time = 0
        sp(1) = subplot(2,1,1);
        hold on
        plot1 = plot(t,dLVDT,'r-.');
        plot2 = plot(t,accplot,'g--');
        plot3 = plot(correctclrts, sigflt,'b');
        suptitle('Comparision of the Distance Measurement from Various Sensors')
        grid on;
        ylabel('Displacement (meters)')
        title ('Measurement from DAQ Trigger (LED Based)')
        hold off

        % LED Pulse vs. RGB LED capture
        sp(2) = subplot(2,1,2);
        hold on
        if (length(t)<length(LEDpulse))
            plot(t,LEDpulse(1:length(t)),'b--','LineWidth',2)
        else
            plot(t(1:length(LEDpulse)),LEDpulse,'b--','LineWidth',2)
        end

        hstem = stem(correctclrts, onoff(ledRGBDsrtIdx:end),'r');
        set(hstem, 'Marker', '.');
        xlabel('Time (seconds)')
        ylabel('Onoff State')
        title('LED Pulse vs. RGB LED capture Timing')
        hold off

        % Plot Xtras
        linkaxes(sp,'x')
        xlim(sp(1),[0 max(t)])
        lp=legend([plot1,plot2,plot3],{'LVDT','Accelerometer','Depth Sensor'});
        p = get(lp,'Position');
        p(1) = 0.72;
        p(2) = 0.85;
        set(lp,'Position',p);
        %}
case 2

        % plot()
        figure;
        % Plot from time = x
        sp(1) = subplot(3,1,1);
        hold on
        plot(t(smplIdx:end),dLVDT(smplIdx:end),'r-.')
        plot(t(smplIdx:end),accplot(smplIdx:end),'g--')
        plot(correctdptts, sigflt(ledsrtIdx:end),'b')
        grid on;
        ylabel('Displacement (meters)')
        title ('Measurement from RGBD Camera Trigger (LED Based)')
        hold off

        %Plot from time = 0
        sp(2) = subplot(3,1,2);
        hold on
        plot1 = plot(t,dLVDT,'r-.');
        plot2 = plot(t,accplot,'g--');
        plot3 = plot(correctdptts, sigflt(ledsrtIdx:end),'b');
        suptitle('Comparision of the Distance Measurement from Various Sensors')
        grid on;
        ylabel('Displacement (meters)')
        title ('Measurement from DAQ Trigger (LED Based)')
        hold off

        % LED Pulse vs. RGB LED capture
        sp(3) = subplot(3,1,3);
        hold on
        if (length(t)<length(LEDpulse))
            plot(t,LEDpulse(1:length(t)),'b--','LineWidth',2)
        else
            plot(t(1:length(LEDpulse)),LEDpulse,'b--','LineWidth',2)
        end
        hstem = stem(FFcorrectclrts,onoff,'r');
        set(hstem, 'Marker', '.');
        xlabel('Time (seconds)')
        ylabel('Onoff State')
        title('LED Pulse vs. RGB LED capture Timing')
        hold off

        % Plot Xtras
        linkaxes(sp,'x')
        xlim(sp(1),[0 max(t)])
        lp=legend([plot1,plot2,plot3],{'LVDT','Accelerometer','Depth Sensor'});
        p = get(lp,'Position');
        p(1) = 0.72;
        p(2) = 0.85;
        set(lp,'Position',p);
        %}
end


end


function [slope, intercept,R2, S, extra] = funct_logfit(x,y,varargin)
%% function [slope, intercept, R2, S] = funct_logfit(x,y,varargin)
% This function plots the data with a power law, logarithmic, exponential
% or linear fit.
%
%   logfit(X,Y,graphType),  where X is a vector and Y is a vector or a
%               matrix will plot the data with the axis scaling determined
%               by graphType as follows: graphType-> xscale, yscale
%                  loglog-> log, log
%                    logx -> log, linear
%                    logy -> linear, log
%                  linear -> linear, linear
%               A line is then fit to the scaled data in a least squares
%               sense.
%               See the 'notes' section below for help choosing a method.
% 
%   logfit(X,Y), will search through all the possible axis scalings and
%               finish with the one that incurs the least error (with error
%               measured as least squares on the linear-linear data.)
% 
%   [slope, intercept, R2, S] = logfit(X,Y,graphType), returns the following:
%                slope: The slope of the line in the log-scale units.
%            intercept: The intercept of the line in the log-scale units.
%                   R2: The mean square error between the 'y' data and the
%                       approximation in linear units.
%                    S: This is returned by 'polyfit' and it allows you to
%                       be much fancier with your error estimates in the
%                       following way: (see polyfit for more information)
%                    >> S contains fields R, df, and normr, for the
%                    >> triangular factor from a QR decomposition of the
%                    >> Vandermonde matrix of x, the degrees of freedom,
%                    >> and the norm of the residuals, respectively. If the
%                    >> data y are random, an estimate of the covariance
%                    >> matrix of p is (Rinv*Rinv')*normr^2/df, where Rinv
%                    >> is the inverse of R. If the errors in the data y
%                    >> are independent normal with constant variance,
%                    >> polyval produces error bounds that contain at least
%                    >> 50% of the predictions.
% 
%   [graphType, slope, intercept, R2, S] = logfit(X,Y), if you choose
%                       not to pass a 'graphType' variable, then it will go
%                       ahead and select the one with the least square
%                       error. The firt parameter returned will be the
%                       graphType, with the following parameters in the
%                       usual order.
%               
%   logfit(X,Y,'PropertyName',PropertyValue), or
%   logfit(X,Y,graphType,'PropertyName',PropertyValue)
% 
%               see parameter options below
%__________________________________________________________________________ 
% USER PARAMETERS:
% 
% For skipping part of the data set:
%       'skip': skip 'n' rows from the beginning of the data set when
%               calculating the linear fit. Must be integer. Pass a negative
%               number to skip rows from the end instead of from the
%               beginning. All points will be plotted. 'num2skip'
%  'skipBegin': skip 'n' rows from the beginning when calculating the
%               linear fit similar to skip n. 'beginSkip'
%    'skipEnd': skip 'n' rows from the end, similar to skip -n 'endSkip'
% 
%__________________________________________________________________________ 
% For plotting in different styles
%   'fontsize': The fontsize of the axis, for axis tick labels and legend.
%               'font','fsize'
% 'markersize': The size of the marker for the points, 
% 'markertype': The type of marker for the points, such as 'o--' or '.r'
%               'markerstyle','markertype','marker'
% 
%  'linewidth': The width of the dashed line for the approximation
% 
%       'ftir': The approximation is plotted for a range around the
%               endpoints of the data set. By default it is 1/20 of the
%               range of the points. You may change this default by using
%               this parameter.
%               'fraction_to_increase_range','fractiontoincreaserange'
%__________________________________________________________________________ 
% Note the following sytax may also be used to specify 'graphtype'
%         'loglog','log','powerlaw'
%         'logx','logarithmic'
%         'logy','exponential','exp'
%         'linear','lin'
%__________________________________________________________________________ 
% Notes:
% The notes here will explain what the output means in terms of fitting
% functions depending on which method you use,
% 
% [slope, intercept] = logfit(x,y,'loglog');
%            yApprox = (10^intercept)*x.^(slope);
% 
% [slope, intercept] = logfit(x,y,'logy');
%            yApprox = (10^intercept)*(10^slope).^x;
% 
% [slope, intercept] = logfit(x,y,'logx');
%            yApprox = (intercept)+(slope)*log10(x);
% 
% [slope, intercept] = logfit(x,y,'linear');
%            yApprox = (intercept)+(slope)*x;
% 
%__________________________________________________________________________ 
% Examples:
% A power law, power 'a'
% a=2;
% x=(1:20)+rand(1,20); y=x.^a;
% power = logfit(x,y);
% % 
% A exponential relationship
% a=3; x=(1:30)+10*rand(1,30); y=a.^x+100*rand(1,30);
% [graphType a] = logfit(x,y)
% base = 10^(a)
% 
% 
% Thanks to Aptima inc. for  for giving me a reason to write this function.
% Thanks to Avi and Eli for help with designing and testing logfit.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jonathan Lansey November 2010,                     All rights reserved. %
%                   questions to Lansey at gmail.com                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The 'extra' is here in case 'graphtype' is not passed and needs to be
% returned.
extra=[];

%% Check user inputed graphType, and standardize its value
k=1;
if isempty(varargin)
    [slope, intercept,R2, S, extra] = findBestFit(x,y);
    return;
    
else % interpret all these possible user parameters here, so we can be more specific later.
    switch lower(varargin{1}); % make all lowercase in case someone put in something different.
        case {'logy','exponential','exp'}
            graphType = 'logy';
        case {'logx','logarithmic'}
            graphType = 'logx';
        case {'loglog','log','powerlaw'}
            graphType = 'loglog';
        case {'linear','lin'}
            graphType = 'linear';
        otherwise            
            [slope, intercept,R2, S, extra] = findBestFit(x,y,varargin{:});
            return;
    end
    k=k+1; % will usually look at varargin{2} later because of this
end

%% Set dynamic marker type defaults
% for example, 'o' or '.' as well as size

yIsMatrixFlag = size(y,1)>1 && size(y,2)>1; % There is more than one data point per x value
markerSize=5;
markerType = '.k';

if ~yIsMatrixFlag % check how many points there are
    if length(y)<80 % relatively few points
        markerType = 'ok';
        markerSize=5;
    %   the following will overwrite markersize
        if length(y)<30 % this number '30' is completely arbitrary
            markerSize=7; % this '12' is also rather arbitrary
        end
%   else % there are many points, keep above defaults
%         lineWidth=1;
%         markerSize=5;
    end
end

% markerLineWidth is always 2.

%% Set static some defaults
% before interpreting user parameters.
fSize=15;
num2skip=0; skipBegin = 0; skipEnd=0;
ftir=20; %  = fraction_To_Increase_Range, for increasing where the green line is plotted
lineColor = [.3 .7 .3]; % color of the line
lineWidth=2;  % width of the approximate line

%% Interpret extra user parameters

while k <= length(varargin) && ischar(varargin{k})
    switch (lower(varargin{k}))
%       skipping points from beginning or end        
        case {'skip','num2skip'}
            num2skip = varargin{k+1};
            k = k + 1;
        case {'skipbegin','beginskip'}
            skipBegin = varargin{k+1};
            k = k + 1;
        case {'skipend','endskip'}
            skipEnd = varargin{k+1};
            k = k + 1;

%       Adjust font size
        case {'fontsize','font','fsize'}
            fSize = varargin{k+1};
            k = k+1;

%       Approx, line plotting
        case {'ftir','fraction_to_increase_range','fractiontoincreaserange'}
            ftir = varargin{k+1};
            k = k+1;
            
%       Plotting style parameters        
        case {'markersize'}
            markerSize = varargin{k+1}; %forceMarkerSizeFlag=1;
            k = k + 1;
        case {'markertype','markerstyle','marker'}
            markerType = varargin{k+1}; %forceMarkerTypeFlag=1;
            k = k+1;
        case {'linecolor','color'}
            lineColor = varargin{k+1};
            k = k+1;
        case 'linewidth'
            lineWidth = varargin{k+1};
            k = k+1;
        otherwise
            warning(['user entered parameter ''' varargin{k} ''' not recognized']);
    end
    k = k + 1;
end

%% Checks for user mistakes in input

% data size and skip related errors/warnings
    % Check they skipped an integer number of rows.
    if round(skipBegin)~=skipBegin || round(skipEnd)~=skipEnd || round(num2skip)~=num2skip 
        error('you can only skip an integer number of data rows');
    end
    if (skipEnd~=0 || skipBegin~=0) && num2skip~=0
        warning('you have entered ambigious parameter settings, ''skipBegin'' and ''skipEnd'' will take priority');
        num2skip=0;
    end

    if num2skip>0
        skipBegin=num2skip;
    elseif num2skip<0
        skipEnd=-num2skip;
    % else
    %     num2skip==0; % so do nothing
    end

    % Check that the user has not skipped all of his/her data
    if length(x)<1+skipEnd+skipBegin
        error('you don''t have enough points to compute a linear fit');
    end
    if length(x)<3+skipEnd+skipBegin
        warning('your data are meaningless, please go collect more points');
    end
    
% Data formatting errors and warnings    
    % Check that 'x' is a vector
    if size(x,1)>1 && size(x,2)>1 % something is wrong
        error('Your x values must be a vector, it cannot be a matrix');
    end

    if yIsMatrixFlag % There is more than one data point per x value
        if size(y,1)~=length(x)
            error('the length of ''x'' must equal the number of rows in y');
        end
    else % y and x must be vectors by now
        if length(x)~=length(y)
            error('the length of ''x'' must equal the length of y');
        end
    end
    
    if ~isnumeric(markerSize)
        error('marker size must be numeric');
    end

% Helpful warning
    if markerSize<=1
        warning(['Your grandma will probably not be able to read your plot, '...
                 'the markersize is just too small!']);
    end



%% Prepare y data by making it a properly oriented vector
% skip rows as requested and create standard vectors (sometimes from matrices)

x=x(:);
x2fit=x(skipBegin+1:end-skipEnd);

if yIsMatrixFlag % There is more than one data point per x value
% note the '+1' so it can be used as an index value
% This is the ones that will be used for fitting, rather than for plotting.
    y2fit = y(skipBegin+1:end-skipEnd,:);
    
    [x2fit,y2fit]= linearify(x2fit,y2fit);
    [x,y]        = linearify(x,y);

else % no need to linearify further
    y=y(:);
    y2fit=y(skipBegin+1:end-skipEnd);
%     Note that 'x' is already forced to be a standard vector above
end

%% Check here for data that is zero or negative on a log scaled axis.
% This is a problem because log(z<=0) is not a real number
% This cell will remove it with a warning and helpful suggestion.
% 
% This warning can suggest you choose a different plot, or perhaps add 1 if
% your data are large enough.
% 
% Note that this is done in order, so if by removing the 'y==0' values, you
% also delete the 'x==0' values, then the 'x' warning won't show up. I
% don't think this is of any concern though.
% 
switch graphType
    case {'logy','loglog'}
        yMask=(y<=0);
        if sum(yMask)>0
            yNegMask=(y<0);
            if sum(yNegMask)>0 % there are proper negative values
                warning(['values with y<=0 were removed.'...
                         'Are you sure that ''logy'' is smart to take? '...
                         'some ''y'' values were negative in your data.']);
            
            else % just some zero values
                if sum(y<10)/length(y) < (1/2) % if less than half your data is below than 10.
                    warning(['values with y==0 were removed. '...
                             'you may wish to add +1 to your data to make these points visible.']);
                else % The numbers are pretty small, you don't want to add one.
                    warning(['values with y==0 were removed. '...
                             'Nothing you can really do about it sorry.']);
                end
                
            end
            
            y=y(~yMask); y2Mask=(y2fit<=0); y2fit=y2fit(~y2Mask);
            x=x(~yMask);                    x2fit=x2fit(~y2Mask);
%             warning('values with y<=0 were removed. It may make suggest you add 1 to your data.')
        end
end

switch graphType
    case {'logx','loglog'}
        xMask=(x<=0);
        if sum(xMask)>0
            
            xNegMask=(x<0);
            if sum(xNegMask)>0 % there are proper negative values
                warning(['values with x<=0 were removed.'...
                         'Are you sure that ''logx'' is smart to take? '...
                         'some ''x'' values were negative in your data.']);
            
            else % just some zero values
                if sum(x<10)/length(x) < (1/2) % if less than half your data is below than 10.
                    warning(['values with x==0 were removed. '...
                             'you may wish to add +1 to your data to make these points visible.']);
                else % The numbers are pretty small, you don't want to add one.
                    warning(['values with x==0 were removed. '...
                             'Nothing you can really do about it sorry.']);
                end
                
            end
            
            x=x(~xMask); x2Mask=(x2fit<=0); x2fit=x2fit(~x2Mask);
            y=y(~xMask);                    y2fit=y2fit(~x2Mask);
        end
end

%% FUNCTION GUTS BELOW
%% set and scale the data values for linear fitting
switch graphType
    case 'logy'
        logY=log10(y2fit);
        logX=x2fit;
    case 'logx'
        logX=log10(x2fit);
        logY=y2fit;
    case 'loglog'
        logX=log10(x2fit); logY=log10(y2fit);
    case 'linear'
        logX=x2fit; logY=y2fit;
end

%% Set the range that the approximate line will be displayed for

if isempty(x2fit) || isempty(y2fit)
    warning(['cannot fit any of your points on this ' graphType ' scale']);
    slope=NaN; intercept=NaN; R2= NaN;
    S=inf; % so that this is not used.
    return;
end


range=[min(x2fit) max(x2fit)];
% make this compatible with skipping some points.... don't know how yet....
switch graphType
    case {'logx','loglog'}
        logRange=log10(range);
        totRange=diff(logRange)+10*eps; % in case its all zeros...
        logRange = [logRange(1)-totRange/ftir, logRange(2)+totRange/ftir];
        ex = linspace(logRange(1),logRange(2),100); % note this is in log10 space

    otherwise % logy, linear
        totRange=diff(range);
        range= [range(1)-totRange/ftir, range(2)+totRange/ftir];        
        ex=linspace(range(1),range(2),100);
end

%% Do the linear fitting and evaluating
[p, S] = polyfit(logX,logY,1);
yy = polyval(p,ex);
estY=polyval(p,logX); % the estimate of the 'y' value for each point.

%% rescale the approximation results for plotting
switch lower(graphType)
    case 'logy'
        yy=10.^yy;
        estY=10.^estY; logY=10.^logY;% need to do this for error estimation
    case 'logx'
        ex=10.^ex;
    case 'loglog'
        yy=10.^yy;
        ex=10.^ex;
        estY=10.^estY; logY=10.^logY;% need to do this for error estimation
    case 'linear'
%         'do nothing';
    otherwise
%         'There is no otherwise at this point';
end

%% Calculate R2
% Note that this is done after the data re-scaling is finished.
R2 = mean((logY-estY).^2);

%% Ready the axis for plotting
% create or grab an axis before setting the scales
a=gca;
set(a,'fontsize',fSize);
holdState=ishold;

%% Plot the data
% This one is just to get the legend right
plot(x,y,markerType,'markersize',markerSize,'linewidth',2);

%% Plot the approximate line
hold('on'); % in case hold off was on before
plot(ex,yy,'--','linewidth',lineWidth,'color',lineColor);

%% Plot the points
% This time again just so it appears on top of the other line.
plot(x,y,markerType,'markersize',markerSize,'linewidth',2);

%% Set the axis and to scale correctly
switch graphType
    case 'logy'
        set(a,'yscale','log');
     case 'logx'
        set(a,'xscale','log');
    case 'loglog'
        set(a,'xscale','log','yscale','log');
    case 'linear'
        set(a,'xscale','linear','yscale','linear');
end

%% Finish up some graph niceties
% fix the graph limits.
% no idea why this is always needed
axis('tight');

legend('data',[graphType ' fit'],'location','best'); legend('boxoff');

% reset hold state
if ~holdState
    hold('off');
end

%% set output data
% before returning
slope=p(1);
intercept = p(2);

end % function logfit over


function [x,y] = linearify(x,y)
%% linearify
% This function will take a vector x, and matrix y and arrange them so that
% y is a vector where each number in the i'th row of y has the value of the
% i'th number in 'x'
% This only works when the number of rows in y equals the number of
% elements in x. The new 'x' vector will be have length(y(:)) elements

x=x(:); % just in case its not already a vector pointing this way.
x=repmat(x,size(y,2),1);
y=y(:);
% if length(y)~=length(x)
%     warning(['Look what you doin son, the length of ''x'' must equal the '...
%            'number of rows in y to make this function useful'           ]);
% end    
end


function [graphType, slope, intercept,R2, S] = findBestFit(x,y,varargin)
%% this checks to see which type of plot has the smallest error
% Then it will return and plot the results from the one with the least
% error. Note that 'graphType' is returned first, making all the following
% outputs shifted.

% List of graph types to check
testList={'loglog','logx','logy','linear'};
R=zeros(4,1);

warning('off'); hold('off'); % just so you don't have it repeating the warnings a million times
for ii=1:4
    [a,b,R(ii),c]=logfit(x,y,testList{ii},varargin{:});
end
warning('on')

%% check for winning graphtype
% the one with the minimum error wins.

graphType=testList(R==min(R));
switch length(graphType)
    case 1
%         no warning, nothing
    case 2
        warning([graphType{1} ' and ' graphType{2} ' had equal error, so ' graphType{1} ' was chosen)']);
    case 3
        warning([graphType{1} ', ' graphType{2} ' and ' graphType{3} ' had equal errors, so ' graphType{1} ' was chosen)']);
    otherwise
%         wow this will probably never happen
        warning(['all graph types had equal error, ' graphType{1} ' was chosen']);
end
graphType=graphType{1};

%% run it a last time to get results
[slope, intercept,R2, S]=logfit(x,y,graphType,varargin{:});

end


function func_plotFFT(Fs,sig)

dF = Fs/length(sig);
sigfft = abs(fft((sig),length(sig)));

figure; 
plot(0:dF:Fs-dF,abs(sigfft))
grid on;
xlabel('Frequency (Hz)')
ylabel ('Magnitude')
title('FFT of the Signal')

end


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
 
 
% SHow the stream video RGB | Depth | Grayscale
 function [] = func_showvideo(Corpts,Icorpts,RGB,DPT, frameno)

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

suptitle (['Current Frame Number: ' num2str(frameno)])
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
