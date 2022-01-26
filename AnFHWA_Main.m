%//%************************************************************************%
%//%*                              Ph.D                                    *%
%//%*                  Project FHWA Multi Sync Processor				   *%
%//%*                                                                      *%
%//%*             Name: Preetham Aghalaya Manjunatha    		           *%
%//%*             Github link: https://github.com/preethamam               %*
%//%*             Submission Date: 01/26/2022                              *%
%//%************************************************************************%
%//%*             Viterbi School of Engineering,                           *%
%//%*             Sonny Astani Dept. of Civil Engineering,                 *%
%//%*             University of Southern california,                       *%
%//%*             Los Angeles, California.                                 *%
%//%************************************************************************%

%//%************************************************************************%
% NOTE: PLACE A TEST SET DATA INSIDE FOLDER CALLED TEST DATASETS AND CHANGE %
% THE PLACED FOLDER NAME INSIDE FUNCT_SYNKPACK_STRUCT.M FILE                %
%//%************************************************************************%

%//%************************************************************************%
% NOTE: TURN OFF VIDEOSTATE FOR FAST PROCESSING                             %
%//%************************************************************************%

%% Start Commands
% matlabpool open 
tic;
clc; close all; clear classes;
clcwaitbarz = findall(0,'type','figure','tag','TMWWaitbar');
delete(clcwaitbarz);


%% Pre-processing of the Data (Preetham A. M.)
% Synchronization
%--------------------------------------------------------------------------
% Import Structs
% [camINPstruct, sensorINPstruct, dspINPstruct, synchroINPstruct, cvINPstruct, PPINPstruct, ...
%           AccSensiArray, AccGravityArray] = funct_SynKpacK_Struct;


%--------------------------------------------------------------------------
% CamData Class Instances and Pre-requisites
%--------------------------------------------------------------------------

% Create instance
camobj = cameradata ();

% Change the default properties
camobj.newexp      = 0;
camobj.ledshift    = 0;
camobj.videostate  = 'on';
camobj.testfolder  = 'Test_11_14_2013_1112_30mph';
camobj.allONIfiles = {{'ZZZ_node_0.oni'}, {'ZZZ_node_1.oni'},...
                      {'ZZZ_node_2.oni'}, {'ZZZ_node_3.oni'}};
camobj.currONIname = 'ZZZ_node_3.oni';
camobj.ledONIfiles = {{'ZZZ_node_3.oni'}};

% Call the methods

% Text Data Outputs  
kinout     = camobj.kinectTextfilesData;

% Rip all images
% imripout   = camobj.kinectRGBDimages;

% Get LED on/off RGB threshold
% LEDthrs    = camobj.kinectLEDthreshold;




%{
%--------------------------------------------------------------------------
% SensorData Class Instances and Pre-requisites
%--------------------------------------------------------------------------
% Constructor and methods
% Object = Class_SensorData(input struct)    
% output = addtestdatapath (inputObj)
% time = getTimeArray (inputObj) 
% Accmat = getAccArray (inputObj)  
% LEDpulse = getLedArray (inputObj)
% Acoumat = getAcousticArray (inputObj)
% Lvdtmat = getLvdtArray (inputObj)

% Text Data Outputs
z_sensortxtinpOBJ = Class_SensorData (sensorINPstruct);

time         = z_sensortxtinpOBJ.getTimeArray;  % Time Array
accmatrix    = z_sensortxtinpOBJ.getAccArray;   % Accelerometer Matrix
ledarray     = z_sensortxtinpOBJ.getLedArray;   % LED Array
lvdtarray    = z_sensortxtinpOBJ.getLvdtArray;  % LVDT Array

%--------------------------------------------------------------------------
% DSPFilters Class Instances and Pre-requisites
%--------------------------------------------------------------------------
% Constructor and methods
% Object = Class_DSPFilters(input struct)
% output = addtestdatapath (inputObj)
% AccVelDisp = Acc2VDisp(inputObj)
% FilteredValues = DCSigFilter(inputObj)

for i = 1:sensorINPstruct.noacc
    
    % Loop and initialize for each Accelerometer 
    dspINPstruct.SensorConst.ACCsensitivity      = AccSensiArray (i);
    dspINPstruct.SensorConst.ACCGravity          = AccGravityArray (i);
    dspINPstruct.InputSignal                     = accmatrix (:,i);
    dspINPstruct.time                            = time; 

    z_dspfiltOBJ = Class_DSPFilters (dspINPstruct);
        
    % Final Displacment, velocity and Acceleration of all Accelerometers
    FinalDVA_Array(i)  = z_dspfiltOBJ.Acc2VDisp;      

end

%--------------------------------------------------------------------------
% Filtering the LVDT data
dspINPstruct.FreqCutoff                  = 0.5;                                 % Cutoff frequency [a | a b] a =  min and b = max
dspINPstruct.FilterType                  = 'highpass';                          % Filter type [highpass | lowpass | bandpass] 
dspINPstruct.FilterMethod                = 'fft';                               % Filter tool [fft | fir]
dspINPstruct.Alpha                       = 0.0001;                              % FFT minimization constant (alpha)
dspINPstruct.FIRorder                    = 900;                                 % FIR filter polynomial order
dspINPstruct.InputSignal                 = lvdtarray;                           % Input signal 
dspINPstruct.time                        = time;                                % Time array 

z_LVDTfiltOBJ = Class_DSPFilters (dspINPstruct);
        
% Final Displacement, velocity and Acceleration of all Accelerometers
FiltLVDT  = z_LVDTfiltOBJ.DCSigFilter;

%--------------------------------------------------------------------------
% Synchro Class Instances
%--------------------------------------------------------------------------
% Constructor and methods
% Object = Class_Synchro(input struct) 
% output = addtestdatapath (inputObj)
% paveoutput  = sync_Kinect_pavement_data  (inputObj)
% caliboutput = sync_KinCamLedAccLVDT_data (inputObj)
% caliboutput = sync_KinCamLedAccLIDAR_data (inputObj)


% Initialize Synchro Inputs
synchroINPstruct.LEDcamdata         = kinout;
synchroINPstruct.LEDthreshld        = LEDthrs;                        
synchroINPstruct.DVAarray           = FinalDVA_Array;
synchroINPstruct.lvdtarray          = FiltLVDT.Signal;

% Synchro Instance and its Output
z_syncOBJ = Class_Synchro (synchroINPstruct);

% Processed pavement output data
SynKpacKpaveoutput  = z_syncOBJ.sync_Kinect_pavement_data;


%% Pre-processing of the Data
% Image enchancement, Noise quantification, Alignment and Stitching
%--------------------------------------------------------------------------
% Initialize CV Inputs
cvINPstruct.totalframes          = kinout.nofrms;
cvINPstruct.reqdframes           = kinout.nofrms;
cvINPstruct.videostate           = 'off';
cvINPstruct.nocams               = 4;
cvINPstruct.SynKpacK_input       = SynKpacKpaveoutput;
cvINPstruct.initialDistance      = 0.67;
cvINPstruct.FrameRange           = [0 500];


% CV Instance and its Output
z_cvOBJ = Class_CompVision (cvINPstruct);




%% Pre-processing of the Data (Mohammad R. J.)
% Pavement distress classification and quatification
%--------------------------------------------------------------------------




%% Main Analysis Loop
% Run from frame 1 to n to align the images classify and 
% quantify pavement distress 
%--------------------------------------------------------------------------
%
flag = 1;
for frameinc = 1 : (kinout.nofrms-SynKpacKpaveoutput.ledRGBDsrtIdx)
    
% Random class extractor    
RV = rand(1,1);

    if ( (RV < 0.2000) && (RV > 0.1995))
        PPINPstruct.classi_GPS_latnlog (flag,:)  = [SynKpacKpaveoutput.GPS_latnlog(frameinc,:) 1];
        flag = flag + 1;
    elseif ( (RV < 0.1000) && (RV > 0.0995))
        PPINPstruct.classi_GPS_latnlog (flag,:)  = [SynKpacKpaveoutput.GPS_latnlog(frameinc,:) 2];
        flag = flag + 1;
    elseif ( (RV < 0.9000) && (RV > 0.8995))
        PPINPstruct.classi_GPS_latnlog (flag,:)  = [SynKpacKpaveoutput.GPS_latnlog(frameinc,:) 3];
        flag = flag + 1;
    end    
end
%

%% Post-processing of the Data
% Plot/graph/tables
%--------------------------------------------------------------------------
%
% Constructor and methods
% Object = Class_PPHandler(input struct)
% output = addtestdatapath (inputObj)
% output = PlotRoadMap(inputObj)
% output = logPlots (inputObj)
% output = FFTPlota (inputObj)
% output = FullSpan_PavementSynchroPlots (inputObj)
% output = UserSpan_PavementSynchroPlots (inputObj)
% video_show  = show_pavement_distress  (inputObj)

%--------------------------------------------------------------------------
% Pavement input parameters
PPINPstruct.GPS_latnlog                    = SynKpacKpaveoutput.GPS_latnlog;
PPINPstruct.GPS_vehiclespeed               = SynKpacKpaveoutput.GPS_vehiclespeed;
PPINPstruct.FFtsignal                      = [];
PPINPstruct.FFT_Fs                         = 0;
PPINPstruct.Ori_LEDstates                  = [time ledarray];
PPINPstruct.SynKpacK_input                 = SynKpacKpaveoutput;

z_postproOBJ = Class_PPHandler (PPINPstruct);   

% Show pavement related plots
% roadmapOut = PlotRoadMap (z_postproOBJ);
% FullSpan_PavementSynchroPlots (z_postproOBJ);
% UserSpan_PavementSynchroPlots (z_postproOBJ);

%--------------------------------------------------------------------------
% Video input parameters
PPINPstruct.LEDcamdata                     = kinout;
PPINPstruct.vid_delay                      = 0;   % Video delay (seconds)
PPINPstruct.videostate                     = 'on';
PPINPstruct.ONIname                        = 'ZZZ_node_1.oni';
PPINPstruct.User_Timerange                 = [275 285];

% Show pavement distress video 
z_show_distressVIDOBJ = Class_PPHandler (PPINPstruct);
show_pavement_distress (z_show_distressVIDOBJ);

%}

%% End Commands
clcwaitbarz = findall(0,'type','figure','tag','TMWWaitbar');
delete(clcwaitbarz);
Runtime = toc;
% matlabpool close
