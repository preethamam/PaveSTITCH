%//%************************************************************************%
%//%*                              Ph.D                                    *%
%//%*                   Project FHWA Sync Processor					       *%
%//%*                                                                      *%
%//%*             Name: Preetham Aghalaya Manjunatha    		           *%
%//%*             USC ID Number: 7356627445		                           *%
%//%*             USC Email: aghalaya@usc.edu                              *%
%//%*             Submission Date: --/--/2012                              *%
%//%************************************************************************%
%//%*             Viterbi School of Engineering,                           *%
%//%*             Sonny Astani Dept. of Civil Engineering,                 *%
%//%*             University of Southern california,                       *%
%//%*             Los Angeles, California.                                 *%
%//%************************************************************************%

%//%************************************************************************%
% NOTE: PLEASE READ THE COMMENTS TO KNOW THE GLOBAL VARIABLES AND ITS       %
% SIGNIFICANCE                                                              %
%//%************************************************************************%

%//%************************************************************************%
% NOTE: TURN OFF VIDEOSTATE FOR FAST PROCESSING                             %
%//%************************************************************************%

function [camINPstruct, sensorINPstruct, dspINPstruct, synchroINPstruct, cvINPstruct, PPINPstruct,...
          AccSensiArray, AccGravityArray] = funct_SynKpacK_Struct 

%% Camera Inputs Structure
%************************************************************************%
camINPstruct.nocams         = 4;                                        % Number of cameras
camINPstruct.newexp         = 1;                                        % Is it new experiment? [No-0 | Yes-1]
camINPstruct.LEDshift       = 1;                                        % Has LED shifted in Image [No-0 | Yes-1]. Asks to select LED centroid through mouse click. 
                                                                        % When RGB image apperas (ledt side), press enter key. Next, the crosshair appears,
                                                                        % use zoom in/out button to adjust the pixel of interest and left click to extract the centriod location
                                                                                                                                                   
camINPstruct.ledwindow      = 3;                                        % LED window size to extract bounding box pixels [Eg. nxn, here n = 5]
camINPstruct.thresfrms      = 2000;                                     % Thresholding frames goes upto to n frames to find the LED threshold
camINPstruct.videostate     = 'off';                                    % Turn video [on | off] (Recommended: off)
camINPstruct.camTSname      = 'ZZZ_camtimestamps.txt';                  % FileName of Kinect timestamps 
camINPstruct.camUnixTSname  = 'ZZZ_camunixtimestamps.txt';              % FileName of Kinect Unix timestamps 
camINPstruct.LEDUnixTSname  = 'ZZZ_LEDunixtimestamps.txt';              % FileName of LED blink Unix timestamps 
camINPstruct.ONInames       = ['ZZZ_node_0.oni'; 'ZZZ_node_1.oni';...   % ONI FileNames Array
                               'ZZZ_node_2.oni'; 'ZZZ_node_3.oni']; 
camINPstruct.ONIname        = 'ZZZ_node_3.oni';                         % ONI FileName to process
camINPstruct.NIoutput       = 'ZZZ_DAQOutput.lvm';                      % DAQ output FileName
camINPstruct.testfolder     = 'Test-11-13-2013-1636-Hwy-110';           % Test-01-31-2014                   % Test folder name
camINPstruct.handles        = [];                                       % Option to pass Kinect handles [Extra]


%% Sensor Input Structure
%************************************************************************%
sensorINPstruct.TimearrIDX         = 1;                                % Discrete time array of DAQ
sensorINPstruct.noacc              = 6;                                % Number of accelerometers
sensorINPstruct.LVDTvoltConstant   = 0;                                % LVDT constant for voltage to displacement conversion
sensorINPstruct.ACCsensitivity     = [];                               % Accelerometer sensitivity initialize
sensorINPstruct.ACCbiasVolt        = 2.5;                              % Accelerometer bias voltage
sensorINPstruct.ACCGravity         = [];                               % Accelerometer gravity range
sensorINPstruct.accAxis            = 1;                                % Number accelerometer axes
sensorINPstruct.AccIDX             = 2:1:7;                            % Column index of channel data in LVM file                            
sensorINPstruct.LedIDX             = 8;                                % Column index of LED channel
sensorINPstruct.AcousticIDX        = [];                               % Column index of acoustic sensor channel
sensorINPstruct.LvdtIDX            = [];                               % Column index of LVDT channel
sensorINPstruct.INPFileName        = 'ZZZ_DAQOutput.lvm';              % DAQ output FileName
sensorINPstruct.testfolder         = camINPstruct.testfolder;          % Test folder name

AccSensiArray      = ones(1,sensorINPstruct.noacc);                    % Accelerometer Sensitivity
AccGravityArray    = 9.81*ones(1,sensorINPstruct.noacc);               % Accelerometer Gravity (Donot multiply by gravity range of accelerometer (i.e. 2 or 10g))


%% Signal Processing Input Structure
%************************************************************************%
dspINPstruct.FreqCutoff                  = 0.5;                                 % Cutoff frequency [a | a b] a =  min and b = max
dspINPstruct.FilterType                  = 'highpass';                          % Filter type [highpass | lowpass | bandpass] 
dspINPstruct.FilterMethod                = 'fft';                               % Filter tool [fft | fir]
dspINPstruct.Alpha                       = 0.0001;                              % FFT minimization constant (alpha)
dspINPstruct.FIRorder                    = 900;                                 % FIR filter polynomial order
dspINPstruct.InputSignal                 = [];                                  % Input signal 
dspINPstruct.time                        = [];                                  % Time array 
dspINPstruct.INPFileName                 = 'ZZZ_DAQOutput.lvm';                 % DAQ output FileName
dspINPstruct.testfolder                  = camINPstruct.testfolder;             % Test folder name
dspINPstruct.SensorConst.LVDTVConstant   = sensorINPstruct.LVDTvoltConstant;    % LVDT voltage slope constant
dspINPstruct.SensorConst.ACCsensitivity  = sensorINPstruct.ACCsensitivity;      % Copy of the sensor   
dspINPstruct.SensorConst.ACCbiasVolt     = sensorINPstruct.ACCbiasVolt;         % constants
dspINPstruct.SensorConst.ACCGravity      = sensorINPstruct.ACCGravity;          % Gravity range of acclerometers


%% Synchronization Input Structure
%************************************************************************%
synchroINPstruct.LEDthreshld               = [];                                       % LED threshold initialise
synchroINPstruct.DVAarray                  = [];                                       % Disp., vel., and acc. array
synchroINPstruct.ledwindow                 = camINPstruct.ledwindow;                   % LED window size to extract bounding box pixels [Eg. nxn, here n = 5]
synchroINPstruct.videostate                = camINPstruct.videostate;                  % Turn video [on | off]
synchroINPstruct.ONInames                  = camINPstruct.ONInames;                    % ONI FileNames Array                                              
synchroINPstruct.ONIname                   = camINPstruct.ONIname;                     % ONI FileName to process
synchroINPstruct.GPSfile                   = 'ZZZ_GPSoutput.txt';                      % FileName of Kinect Unix timestamps 
synchroINPstruct.testfolder                = camINPstruct.testfolder;                  % Test folder name
synchroINPstruct.handles                   = [];                                       % Option to pass Kinect handles [Extra]
synchroINPstruct.alignerType               = 'camfirst';                               % Type of aligner [Camera first - camfirst | LED first - ledfirst]
synchroINPstruct.LEDcamdata                = [];                                       % Synthesized LED camera data
synchroINPstruct.chessgrid_BBox            = [225 235 400 360];                        % Chess grid bounding box
synchroINPstruct.NumofSensors              = [6 1 1 1];                                  % Number of sensors  [Acc | LED | GPS | LVDT]   
synchroINPstruct.sensordata                = sensorINPstruct;



%% Computer vision Input Structure
%************************************************************************%
cvINPstruct.nocams               = camINPstruct.nocams;
cvINPstruct.totalframes          = [];
cvINPstruct.reqdframes           = [];
cvINPstruct.ONInames             = camINPstruct.ONInames;
cvINPstruct.testfolder           = camINPstruct.testfolder;
cvINPstruct.camorder             = [1 2 3 4];
cvINPstruct.IMwidth              = 640;
cvINPstruct.IMheight             = 480;
cvINPstruct.inputImage           = [];
cvINPstruct.inputDImage          = [];
cvINPstruct.SynKpacK_input       = [];
cvINPstruct.Dispval              = [];
cvINPstruct.initialDistance      = 0.7;
cvINPstruct.videostate           = 'off';
cvINPstruct.Hconv                = fspecial('gaussian', [3 3], 3);
cvINPstruct.opts.rho_r           = 2.5;
cvINPstruct.opts.beta            = [1.5 1 1];
cvINPstruct.opts.print           = false;
cvINPstruct.opts.alpha           = 0.5;
cvINPstruct.opts.method          = 'l2';
cvINPstruct.mu                   = 50;
cvINPstruct.FrameRange           = [1 100];
cvINPstruct.Frame_sorttype       = 'speed';
cvINPstruct.blurindices          = [];
cvINPstruct.nominal_blurvalue    = 0.25;
cvINPstruct.ROIselType           = 'oneframe';
cvINPstruct.ROIwindow            = 100;

%% Post-processing Input Structure
%************************************************************************%
% CLASS UNIQUE ID (CUID)
% Positive integer values

% MARKERS
% '+' --> Plus sign
% 'o' --> Circle
% '*' --> Asterisk
% '.' --> Point
% 'x' --> Cross
% 'square' or 's' --> Square
% 'diamond' or 'd' --> Diamond
% '^' --> Upward-pointing triangle
% 'v' --> Downward-pointing triangle
% '>' --> Right-pointing triangle
% '<' --> Left-pointing triangle
% 'pentagram' or 'p'  --> Five-pointed star (pentagram)
% 'hexagram' or 'h''' --> Six-pointed star (hexagram)

% MARKER SIZE
% A positive integer 1-10

% COLOR FORMAT 
% [R G B] array [max - 255 | min - 0]

% CLASS TITLE
% Include a class title (string)

% CLASSIFIER PLOTTING TEMPLATE (as a cell array)
% [CUID | MARKER | MAKKERSIZE | COLOR FORMAT | CLASS TITLE]
PPINPstruct.plotclassifier                 = {{1 '*' 10 [255 0 0] 'Large Distress'};...
                                              {2 'p' 10 [0 255 0] 'Medium Distress'};...
                                              {3 'h' 10 [0 0 255] 'Small Distress'}};
PPINPstruct.linespecifiers                 = [0 0];       % [Turn on/off speed markers | Turn on/off distress markers]
PPINPstruct.testfolder                     = camINPstruct.testfolder;                          % Test folder name
PPINPstruct.GPSfile                        = 'ZZZ_GPSoutput.txt';
PPINPstruct.GPS_latnlog                    = [];                                               % GPS latitude and logitude array
PPINPstruct.classi_GPS_latnlog             = [];                                               % Categorized GPS latitude and logitude array [Latitude Longitude CUID]
PPINPstruct.x                              = [];                                               % X array for log plot
PPINPstruct.y                              = [];                                               % Y array for log plot
PPINPstruct.varargin                       = [];                 % Type of log plot [loglog-> log, log | logx -> log, linear | logy -> linear, log | linear -> linear, linear]
PPINPstruct.GPS_latnlog                    = [];                 % GPS latitude and longitude
PPINPstruct.GPS_vehiclespeed               = [];                 % Vehicle speed matrix
PPINPstruct.FFtsignal                      = [];                 % Signal to get FFT plot
PPINPstruct.FFT_Fs                         = 0;                  % Sampling frequency to get FFT plot
PPINPstruct.pathtype                       = 'continuous';       % How to join GPS latitude and longitude data [discrete | continuous]
PPINPstruct.ExpName                        = camINPstruct.testfolder;  % Experiment title
PPINPstruct.Ori_LEDstates                  = [];                % Original LED state and its time
PPINPstruct.SynKpacK_input                 = [];                % Synchronized data as post-processor input
PPINPstruct.User_Timerange                 = [275 285];         % Time range in seconds [min max]
PPINPstruct.User_Acclerometers             = [1 2 3 4 5 6];     % Accelerometers ID for post-processing [min max]
PPINPstruct.LEDcamdata                     = [];                        % LED camera input
PPINPstruct.vid_delay                      = 0;                         % Video delay (seconds)
PPINPstruct.videostate                     = 'on';                      % Video state [on/off]
PPINPstruct.ONIname                        = camINPstruct.ONIname;      % ONI file name
end





