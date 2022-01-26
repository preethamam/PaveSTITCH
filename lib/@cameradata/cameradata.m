classdef cameradata < handle
%--------------------------------------------------------------------------
% Class:        CAMERADATA
%               
% Constructor:  obj = CAMERADATA();
%               
% Properties:   nocams          % Number of cameras
%               newexp          % Is this a new experiment?
%               ledshift        % Has LED position is shifted in field of view (FoV)?
%               videostate      % Displays the current frames
%               ledwindow       % LED window size for average pixel intensity
%               thresfrms       % First n frames to create a threshold intensity (10-30% of the total frames are recommended)
%               camTSfile       % Camera timestamps
%               camUnixTSfile   % Camera Unix (computer) timestamps
%               ledUnixTSfile   % LED Unix (computer) timestamps
%               allONIfiles     % All ONI filenames of the experiment (multiple files)
%               daqoutfile      % Data acqusition output file
%               currONIname     % Current ONI file name (single file)
%               testfolder      % Folder where the experimental data(.ONI, .TXT and others) is stored
%               kinecthandles   % Takes Kinect handle array input (optional)
%               ledONIfiles     % LED ONI files of the experiment (single/multiple files)
%               datafolderpath  % Absolute folder path to the main data
%                                 repository. Must be one level above to each datasets folder.
%                                 If this input is empty, then it is assumed Test Datasets folder is in the
%                                 same level of of the Main program folder.
%
%               
% Getters:      The following properties getters are supported:
%               
%               value = get.nocams(obj);
%               value = get.newexp(obj);
%               value = get.ledshift(obj);
%               value = get.videostate(obj);
%               value = get.ledwindow(obj);
%               value = get.thresfrms(obj);
%               value = get.camTSfile(obj);
%               value = get.camUnixTSfile(obj);
%               value = get.ledUnixTSfile(obj);
%               value = get.allONIfiles(obj);
%               value = get.daqoutfile(obj);
%               value = get.currONIname(obj);
%               value = get.testfolder(obj);
%               value = get.ledUnixTSfile(obj);
%               value = get.kinecthandles(obj);
%               value = get.ledONIfiles(obj);
%
% Setters:      The following properties getters are supported:
%               
%               obj = set.nocams(obj,value);
%               obj = set.newexp(obj,value);
%               obj = set.ledshift(obj,value);
%               obj = set.videostate(obj,value);
%               obj = set.ledwindow(obj,value);
%               obj = set.thresfrms(obj,value);
%               obj = set.camTSfile(obj,value);
%               obj = set.camUnixTSfile(obj,value);
%               obj = set.ledUnixTSfile(obj,value);
%               obj = set.allONIfiles(obj,value);
%               obj = set.daqoutfile(obj,value);
%               obj = set.currONIname(obj,value);
%               obj = set.testfolder(obj,value);
%               obj = set.ledUnixTSfile(obj,value);
%               obj = set.kinecthandles(obj,value);
%               obj = set.ledONIfiles(obj,value);
% 
% Methods:      The following methods are supported:
%
%               
% Description:  This class extracts all the data sets from the camera 
%               (RGBD images) and its textfiles (timestamps and others).
%               
% Author:       Preetham Aghalaya Manjunatha
%               aghalaya@usc.edu
%               
% Date:         May 13, 2014
%--------------------------------------------------------------------------
    
    properties (GetAccess = public, SetAccess = public, Hidden = false)
        nocams          % Number of cameras
        newexp          % Is this a new experiment?
        ledshift        % Has LED position is shifted in field of view (FoV)?
        videostate      % Displays the current frames
        ledwindow       % LED window size for average pixel intensity
        thresfrms       % First n frames to create a threshold intensity
        camTSfile       % Camera timestamps
        camUnixTSfile   % Camera Unix (computer) timestamps
        ledUnixTSfile   % LED Unix (computer) timestamps
        allONIfiles     % All ONI filenames of the experiment (multiple files)
        daqoutfile      % Data acqusition output file
        currONIname     % Current ONI file name (single file) 
        testfolder      % Folder where the experimental data 
                        % (.ONI, .TXT and others) is stored
        kinecthandles   % Takes Kinect handle array input (optional)
        ledONIfiles     % LED .ONI filenames of the experiment 
                        % (single/multiple files)
        datafolderpath  % Absolute folder path to the main data repository. 
                        % Must be one level above to each datasets folder. If 
                        % this input is empty, then it is assumed Test Datasets 
                        % folder is in the same level of of the Main program 
                        % folder.
    end
    
    properties (Access = protected)
        kintextoutput   % Stores the putput of the method KINECTTEXTFILESDATA  
    end
    
    methods
        %
        % Constructor
        %
        function obj = cameradata(varargin)
            %----------------------- Constructor --------------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 5:08 PM
            %
            % Syntax:       obj = CameraData();
            %
            % Description:  Creates an empty camera data constructor
            %               
            % Inputs:       () blank
            %
            % Outputs:      Null object
            %               
            % Note:         This is a default constructor
            %
            %--------------------------------------------------------------
            
            % Switch case populates the constructor
               switch nargin
                    case 0  % Support calling with 0 arguments

                        obj.nocams          = 1;
                        obj.newexp          = 1;
                        obj.ledshift        = 1;
                        obj.videostate      = 'on';
                        obj.ledwindow       = 5;
                        obj.thresfrms       = 1000;
                        obj.camTSfile       = 'ZZZ_camtimestamps.txt';
                        obj.camUnixTSfile   = 'ZZZ_camunixtimestamps.txt';
                        obj.ledUnixTSfile   = 'ZZZ_LEDunixtimestamps.txt';
                        obj.allONIfiles     = {};
                        obj.daqoutfile      = 'ZZZ_DAQOutput.lvm';
                        obj.currONIname     = [];
                        obj.testfolder      = [];
                        obj.kinecthandles   = [];
                        obj.ledONIfiles     = {};
                        obj.datafolderpath  = [];
                        obj.kintextoutput   = [];

                    case 1

                    otherwise
                        error('Invalid inputs to the class constructor! Please check your inputs.')
               end
        end 
        
    %------------------------------------------------------------------%
    %                       Getters and Setters                        % 
    %------------------------------------------------------------------%  

        %
        % Getter/setter - number of cameras (nocams)
        %                
        function value = get.nocams(obj)
            %----------------------- Getter (nocams)-----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 5:16 PM
            %
            % Syntax:       value = get.nocams(obj);
            %
            % Description:  Gets the current nocams option from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current nocams (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.nocams;
        end
        
        function set.nocams(obj,value)
            %----------------------- Setter (nocams)-----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 5:16 PM
            %
            % Syntax:       obj = set.nocams(obj,value);
            %
            % Description:  Sets the nocams input to the constructor
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.nocams)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ~(value > 0)
              error('Number of cameras (nocams) value must be positive')
           else
              obj.nocams = value;
           end
        end    

        
        %
        % Getter/setter - New experiment? (newexp)
        %            
        function value = get.newexp(obj)
            %----------------------- Getter (newexp)-----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 5:35 PM
            %
            % Syntax:       value = get.newexp(obj);
            %
            % Description:  Gets the current newexp option from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current newexp (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.newexp;
        end
        
        function set.newexp(obj,value)
            %----------------------- Setter (newexp)-----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 5:35 PM
            %
            % Syntax:       obj = set.newexp(obj,value);
            %
            % Description:  Sets the Is this a new experiment flag input to
            %               the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.newexp)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ( (value == 0) | (value == 1) | (strcmp(value,'no')) | (strcmp(value,'yes')) )
               obj.newexp = value;
           else
               error('New experiment (newexp) value must be either 0(no) or 1(yes)')          
           end
        end    
                
        
        %
        % Getter/setter - Is LED shifted? (ledshift)
        %                
        function value = get.ledshift(obj)
            %--------------------- Getter (ledshift) ----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 6:09 PM
            %
            % Syntax:       value = get.ledshift(obj);
            %
            % Description:  Gets the current ledshift option from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current ledshift (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.ledshift;
        end
        
        function set.ledshift(obj,value)
            %--------------------- Setter (ledshift) ----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 6:09 PM
            %
            % Syntax:       obj = set.ledshift(obj,value);
            %
            % Description:  Sets a LED shifted flag input to the
            %               constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.ledshift)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ( (value == 0) | (value == 1) | (strcmp(value,'no')) | (strcmp(value,'yes')) )
               obj.ledshift = value;
           else
               error('LED shift (ledshift) value must be either 0(no) or 1(yes)')          
           end
        end
        
        
        %
        % Getter/setter - Show images/video (videostate)
        %                
        function value = get.videostate(obj)
            %-------------------- Getter (videostate) ---------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 6:28 PM
            %
            % Syntax:       value = get.videostate(obj);
            %
            % Description:  Gets the current videostate option from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current videostate (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.videostate;
        end
        
        function set.videostate(obj,value)
            %-------------------- Setter (videostate) ---------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 6:29 PM
            %
            % Syntax:       obj = set.videostate(obj,value);
            %
            % Description:  Sets show images/video input to the
            %               constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.ledshift)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ( (value == 0) | (value == 1) | (strcmp(value,'off')) | (strcmp(value,'on')) )
               obj.videostate = value;
           else
               error('Show images/video (videostate) value must be either 0(off) or 1(on)')          
           end
        end    
        
        
        %
        % Getter/setter - Assign LED window box size (ledwindow)
        %                
        function value = get.ledwindow(obj)
            %-------------------- Getter (ledwindow) ----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 6:58 PM
            %
            % Syntax:       value = get.ledwindow(obj);
            %
            % Description:  Gets the current ledwindow value from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current ledwindow (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.ledwindow;
        end
        
        function set.ledwindow(obj,value)
            %-------------------- Setter (ledwindow) ----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 7:00 PM
            %
            % Syntax:       obj = set.ledwindow(obj,value);
            %
            % Description:  Sets ledwindow size input (nxn) to the
            %               constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.ledwindow)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ~( value > 0 )
               error('LED window size (ledwindow) value must be positive')                
           else
               obj.ledwindow = value;       
           end
        end    

        
        %
        % Getter/setter - Assign thresholding frames size (thresfrms)
        %                
        function value = get.thresfrms(obj)
            %-------------------- Getter (thresfrms) ----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 7:12 PM
            %
            % Syntax:       value = get.thresfrms(obj);
            %
            % Description:  Gets the current thresfrms value from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current thresfrms (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.thresfrms;
        end
        
        function set.thresfrms(obj,value)
            %-------------------- Setter (ledwindow) ----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 7:12 PM
            %
            % Syntax:       obj = set.thresfrms(obj,value);
            %
            % Description:  Sets thresfrms size to the constructor.
            %               Recommended 10-30% of the total
            %               frames.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.thresfrms)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ~( value > 0 )
               error('Thresholding frames size (thresfrms) value must be positive. Recommended 10-30% of the total frames.')                
           else
               obj.thresfrms = value;       
           end
        end    
        
        
        %
        % Getter/setter - Include camera timestamp filename (camTSfile)
        %                
        function value = get.camTSfile(obj)
            %-------------------- Getter (camTSfile) ----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 7:12 PM
            %
            % Syntax:       value = get.camTSfile(obj);
            %
            % Description:  Gets the current camTSfile string from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current camTSfile (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.camTSfile;
        end
        
        function set.camTSfile(obj,value)
            %-------------------- Setter (camTSfile) ----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 7:12 PM
            %
            % Syntax:       obj = set.camTSfile(obj,value);
            %
            % Description:  Sets camTSfile string to the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.camTSfile)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ~( ischar(value) )
               error('Camera timestamps filename (camTSfile) must be a string! Please check your filename.')                
           else
               obj.camTSfile = value;
           end
        end    
        
        
        %
        % Getter/setter - Include camera Unix (computer) timestamp filename 
        %                 (camUnixTSfile)
        %                
        function value = get.camUnixTSfile(obj)
            %------------------ Getter (camUnixTSfile) --------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 7:51 PM
            %
            % Syntax:       value = get.camUnixTSfile(obj);
            %
            % Description:  Gets the current camUnixTSfile string from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current camUnixTSfile (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.camUnixTSfile;
        end
        
        function set.camUnixTSfile(obj,value)
            %------------------ Setter (camUnixTSfile) --------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 7:12 PM
            %
            % Syntax:       obj = set.camUnixTSfile(obj,value);
            %
            % Description:  Sets camUnixTSfile string to the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.camUnixTSfile)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ~( ischar(value) )
               error('Camera Unix (computer) timestamps filename (camUnixTSfile) must be a string! Please check your filename.')                
           else
               obj.camUnixTSfile = value;
           end
        end    
        
        
        %
        % Getter/setter - Include LED Unix (computer) timestamp filename 
        %                 (ledUnixTSfile)
        %                
        function value = get.ledUnixTSfile(obj)
            %------------------ Getter (ledUnixTSfile) --------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 8:07 PM
            %
            % Syntax:       value = get.ledUnixTSfile(obj);
            %
            % Description:  Gets the current ledUnixTSfile string from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current ledUnixTSfile (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.ledUnixTSfile;
        end
        
        function set.ledUnixTSfile(obj,value)
            %------------------ Setter (ledUnixTSfile) --------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 7:12 PM
            %
            % Syntax:       obj = set.ledUnixTSfile(obj,value);
            %
            % Description:  Sets ledUnixTSfile string to the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.ledUnixTSfile)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ~( ischar(value) )
               error('LED Unix (computer) timestamps filename (ledUnixTSfile) must be a string! Please check your filename.')                
           else
               obj.ledUnixTSfile = value;
           end
        end    
        
        
        %
        % Getter/setter - Include Kinect ONI filenames (allONIfiles)
        %                
        function value = get.allONIfiles(obj)
            %------------------- Getter (allONIfiles) ---------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 8:07 PM
            %
            % Syntax:       value = get.allONIfiles(obj);
            %
            % Description:  Gets the current allONIfiles string from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current allONIfiles (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.allONIfiles;
        end
        
        function set.allONIfiles(obj,value)
            %------------------- Setter (allONIfiles) ---------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 7:12 PM
            %
            % Syntax:       obj = set.allONIfiles(obj,value);
            %
            % Description:  Sets allONIfiles string to the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.allONIfiles)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ~( iscell(value) )
               error('Kinect all ONI filenames (allONIfiles) must be a cell (string)! Please check your filenames.')                
           else
               obj.allONIfiles = value;
           end
        end   
        
        
        %
        % Getter/setter - Include DAQ output filename (daqoutfile)
        %                
        function value = get.daqoutfile(obj)
            %-------------------- Getter (daqoutfile) ---------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/12/2014 @ 12:45 PM
            %
            % Syntax:       value = get.daqoutfile(obj);
            %
            % Description:  Gets the current daqoutfile string from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current daqoutfile (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.daqoutfile;
        end
        
        function set.daqoutfile(obj,value)
            %------------------- Setter (daqoutfile) ----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 12:45 PM
            %
            % Syntax:       obj = set.daqoutfile(obj,value);
            %
            % Description:  Sets daqoutfile string to the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.daqoutfile)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ~( ischar(value) )
               error('DAQ filename (daqoutfile) must be a string! Please check your filename.')              
           else
               obj.daqoutfile = value;
           end
        end   
        
        
        %
        % Getter/setter - Include current ONI filename (currONIname) for
        %                 single usage
        %                
        function value = get.currONIname(obj)
            %-------------------- Getter (currONIname) --------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/12/2014 @ 01:45 PM
            %
            % Syntax:       value = get.currONIname(obj);
            %
            % Description:  Gets the current currONIname string from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current currONIname (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.currONIname;
        end
        
        function set.currONIname(obj,value)
            %-------------------- Setter (currONIname) --------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 12:45 PM
            %
            % Syntax:       obj = set.currONIname(obj,value);
            %
            % Description:  Sets currONIname string to the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.currONIname)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ( ischar(value) | (isempty(value)) )
               obj.currONIname = value;                           
           else
               error('Single ONI fi1lename (currONIname) must be a string! Please check your filename.')  
           end
        end   
        
                
        %
        % Getter/setter - Include current experimental data folder name
        %                 (testfolder) 
        %                
        function value = get.testfolder(obj)
            %-------------------- Getter (testfolder) ---------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/12/2014 @ 01:45 PM
            %
            % Syntax:       value = get.testfolder(obj);
            %
            % Description:  Gets the current testfolder string from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current testfolder (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.testfolder;
        end
        
        function set.testfolder(obj,value)
            %------------------- Setter (testfolder) ----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 12:45 PM
            %
            % Syntax:       obj = set.testfolder(obj,value);
            %
            % Description:  Sets testfolder string to the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.testfolder)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ( ischar(value) | isempty(value) ) %#ok<*OR2>
               obj.testfolder = value;             
           else
               error('Test folder name (testfolder) must be a string! Please check your filename.')               
           end
        end   
        
        
        %
        % Getter/setter - Include Kinect handle array
        %                 (kinecthandles) 
        %                
        function value = get.kinecthandles(obj)
            %-------------------- Getter (kinecthandles) ------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/12/2014 @ 01:45 PM
            %
            % Syntax:       value = get.kinecthandles(obj);
            %
            % Description:  Gets the kinecthandles from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current kinecthandles (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.kinecthandles;
        end
        
        function set.kinecthandles(obj,value)
            %------------------ Setter (kinecthandles) --------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 12:45 PM
            %
            % Syntax:       obj = set.kinecthandles(obj,value);
            %
            % Description:  Sets kinecthandles string to the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.kinecthandles)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if (ischar(value))
               error('Kinect handles (kinecthandles) cannot be a string! Please check your handle datatype.')                   
           else
               obj.kinecthandles = value;
                         
           end
        end
        
        
        %
        % Getter/setter - Include LED Kinect ONI filenames (ledONIfiles)
        %                
        function value = get.ledONIfiles(obj)
            %------------------- Getter (ledONIfiles)----------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/13/2014 @ 4:07 PM
            %
            % Syntax:       value = get.ledONIfiles(obj);
            %
            % Description:  Gets the current ledONIfiles string from the
            %               constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current ledONIfiles (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.ledONIfiles;
        end
        
        function set.ledONIfiles(obj,value)
            %------------------- Setter (ledONIfiles) ---------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 7:12 PM
            %
            % Syntax:       obj = set.ledONIfiles(obj,value);
            %
            % Description:  Sets ledONIfiles string to the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.ledONIfiles)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ~( iscell(value) )
               error('LED Kinect ONI filenames (ledONIfiles) must be a cell (string)! Please check your filenames.')           
           else
               obj.ledONIfiles = value;
           end
        end    
        
        
        %
        % Getter/setter - Include main experimental datasets folder path
        %                 (datafolderpath). If empty, then same level of Main 
        %                 program or can be at different level.
        %                
        function value = get.datafolderpath(obj)
            %------------------- Getter (datafolderpath) ------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/14/2014 @ 06:06 AM
            %
            % Syntax:       value = get.datafolderpath(obj);
            %
            % Description:  Gets the main datafolderpath 
            %               string from the constructor.
            %               
            % Inputs:       object(obj)
            %
            % Outputs:      Current datafolderpath (value)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
            value = obj.datafolderpath;
        end
        
        function set.datafolderpath(obj,value)
            %----------------- Setter (datafolderpath) --------------------
            % Author:       Paghalaya
            %
            % Date 
            % and time:     05/11/2014 @ 12:45 PM
            %
            % Syntax:       obj = set.datafolderpath(obj,value);
            %
            % Description:  Sets datafolderpath string to the constructor.
            %               
            % Inputs:       object(obj), overwritten value (value)
            %
            % Outputs:      New/overwritten object (obj.testfolder)
            %               
            % Note:         DONOT change/touch this function!
            %
            %--------------------------------------------------------------
           if ( ischar(value) | (isempty(value))) 
               obj.datafolderpath = value;             
           else
               error('Main Test Datasets folder path (datafolderpath) must be a string! Please check your filename.')               
           end
        end   
    end
    
    
    %------------------------------------------------------------------%
    %                          Public methods                          %
    %------------------------------------------------------------------%
    methods (Access = public)
                
        %
        % Add the experimental data folder path
        %              
        output = testDatapath (obj);
        
        
        %
        % Obtain all the Kinect related text files data
        % 
        kintextDataout = kinectTextfilesData (obj);

        
        %
        % Obtain Kinect handle to extract images from the .ONI file
        % (optional)
        %
        kinhandlez = kinectHandles (obj);
        
        
        %
        % Refresh Kinect handles to extract next (t+1) images from the .ONI file
        % (optional)
        % 
        refdata = refreshKinHandles (obj);

        
        %
        % Obtain the LED threshold RGB(grayscale) value
        %
        LEDthreshold = kinectLEDthreshold (obj);
        
        
        %
        % Obtain Kinect RGBD images and save them in the parent testdata folder
        %     
        output = kinectRGBDimages (obj);        

        
        %
        % SoftKinectic data sets (incomplete)
        %
        sktextData = softkineticTextfilesdata (obj);
        
        
        %
        % Asus data sets (incomplete)
        %
        asustextdata = asusTextfilesdata (obj);
    end       
    
    %------------------------------------------------------------------%
    %                        Protected methods                         %
    %------------------------------------------------------------------%
    methods (Access = protected)
        
    end
    
    %------------------------------------------------------------------%
    %                         Private methods                          %
    %------------------------------------------------------------------%
    methods (Access = private)
  
    end
    
    %------------------------------------------------------------------%
    %                         Static methods                           %
    %------------------------------------------------------------------%
    methods (Access = private, Static = true)
        
    end
end