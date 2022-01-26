classdef Class_SensorData
    %CLASS_DSPFILTERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TimearrIDX      = 1        
        AccIDX          = 2:1:7
        LedIDX          = 8
        AcousticIDX     = []
        LvdtIDX         = []
        INPFileName     = 'ZZZ_Output.lvm'
        testfolder
    end
    
    methods
    
        % Constructor Initilaization    
        function inputObj = Class_SensorData(inpstruct)      
            if nargin >= 1
                inputObj.TimearrIDX         = inpstruct.TimearrIDX;
                inputObj.AccIDX             = inpstruct.AccIDX;
                inputObj.LedIDX             = inpstruct.LedIDX;
                inputObj.AcousticIDX        = inpstruct.AcousticIDX;
                inputObj.LvdtIDX            = inpstruct.LvdtIDX; 
                inputObj.INPFileName        = inpstruct.INPFileName;
                inputObj.testfolder         = inpstruct.testfolder;
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
        
        % NIDAQ Extract Time Data    
        function time = getTimeArray (inputObj) 
            NIdaq = load(inputObj.INPFileName);
            time = NIdaq(:,inputObj.TimearrIDX);
        end

        % NIDAQ Extract Acceleration Data
        function Accmat = getAccArray (inputObj)        
            NIdaq = load(inputObj.INPFileName);
            if (isempty(inputObj.AccIDX))
                Accmat = zeros(size(NIdaq,1),1);
                warning('Zeros are Extracted for Acceleration Matrix...!')
            else            
                Accmat = NIdaq(:,inputObj.AccIDX);
            end

        end

        % NIDAQ Extract Pulse Data
        function LEDpulse = getLedArray (inputObj)
            NIdaq = load(inputObj.INPFileName);

            if (isempty(inputObj.LedIDX))
                LEDpulse = zeros(size(NIdaq,1),1);
                warning('Zeros are Extracted for LED Array...!')
            else            
                pulseraw    = NIdaq(:,inputObj.LedIDX);
                pulsemean   = mean(pulseraw);
                LEDpulse    = zeros(length(pulseraw),1);

                for i=1:length(pulseraw)
                    if(pulseraw(i) >= pulsemean)
                        LEDpulse(i,:) = 1;
                    else
                        LEDpulse(i,:) = 0;
                    end        
                end
            end
        end

        % NIDAQ Extract Acoustic Data
        function Acoumat = getAcousticArray (inputObj)
            NIdaq = load(inputObj.INPFileName);
            if (isempty(inputObj.AcousticIDX))
                Acoumat = zeros(size(NIdaq,1),1);
                warning('Zeros are Extracted for Acoustic Array...!')
            else
                Acoumat = NIdaq(:,inputObj.AcousticIDX);
            end
        end

        % NIDAQ Extract LVDT Data
        function Lvdtmat = getLvdtArray (inputObj)
            NIdaq = load(inputObj.INPFileName);
            if (isempty(inputObj.LvdtIDX))
                Lvdtmat = zeros(size(NIdaq,1),1);
                warning('Zeros are Extracted for LVDT Array...!')
            else
                Lvdtmat = NIdaq(:,inputObj.LvdtIDX);
            end
        end

   end

end

