classdef Class_DSPFilters
    %CLASS_SENSORDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        FreqCutoff
        FilterType = 'highpass'
        FilterMethod = 'fft'
        Alpha = 0.001;
        FIRorder
        LVDTvoltConstant
        ACCbiasVolt = 2.5
        ACCsensitivity = [] 
        ACCGravity = []
        InputSignal = []
        time = []
        INPFileName = 'ZZZ_Output.lvm'
        testfolder = []
    end
    
    methods
        
        % Constructor Initilaization
        function inputObj = Class_DSPFilters(inpstruct)      
            if nargin >= 1
                inputObj.FreqCutoff         = inpstruct.FreqCutoff;
                inputObj.FilterType         = inpstruct.FilterType;
                inputObj.FilterMethod       = inpstruct.FilterMethod;
                inputObj.Alpha              = inpstruct.Alpha;
                inputObj.FIRorder           = inpstruct.FIRorder;
                inputObj.LVDTvoltConstant   = inpstruct.SensorConst.LVDTVConstant; 
                inputObj.ACCsensitivity     = inpstruct.SensorConst.ACCsensitivity;
                inputObj.ACCbiasVolt        = inpstruct.SensorConst.ACCbiasVolt;
                inputObj.ACCGravity         = inpstruct.SensorConst.ACCGravity;
                inputObj.InputSignal        = inpstruct.InputSignal;
                inputObj.time               = inpstruct.time; 
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

        function AccVelDisp = Acc2VDisp(inputObj)

                % Initialize
                t               = inputObj.time;
                signalIN        = (inputObj.InputSignal/inputObj.ACCsensitivity)*...
                                   inputObj.ACCGravity;
                cutoff          = inputObj.FreqCutoff;
                alpha           = inputObj.Alpha;
                filtertype      = inputObj.FilterType;
                filtermethod    = inputObj.FilterMethod;
                firorder        = inputObj.FIRorder;
                
                % Function acc2disp performs the filtering in frequency domain and then double integration to
                % obtain the displacment from acceleration

                % Input Analyzer
                xdd = signalIN; 
                dt = abs(t(5)-t(4));
                Fs = 1/dt;

                % Double Integration
                % Filter the Acceleration Signal and Set the First k values constant (suppress  frequency content)
                [FinalAccl,~] = ...
                          func_DCclean(xdd, cutoff, alpha, Fs, filtertype,filtermethod,firorder);

                %//%------------------------------------------------------------------------%
                % Perform 1st Integration and Filter the Acceleration Signal
                Xd_int = dt * cumtrapz(FinalAccl);

                % Filter the Velocity Signal and Set the First k values constant (suppress  frequency content)
                [FinalVelo, ~] = ...
                          func_DCclean(Xd_int, cutoff, alpha, Fs, filtertype,filtermethod,firorder);

                %//%------------------------------------------------------------------------%
                % Perform 2st Integration and Filter the Velocity Signal
                X_int = dt * cumtrapz(FinalVelo);

                % Filter the displacement Signal and Set the First k values constant (suppress  frequency content)
                % Displacement unfiltered
                [x_TimeNF, ~] = ...
                          func_DCclean(X_int, cutoff, alpha, Fs, filtertype,filtermethod,firorder);

                %//%------------------------------------------------------------------------%
                % Final Filtering of Retrived Displacement Data and Set the First k values constant (suppress frequency content)

                %Displacement filtered
                [FinalDisp, ~] = ...
                          func_DCclean(x_TimeNF, cutoff, alpha, Fs, filtertype,filtermethod,firorder);
                
                AccVelDisp.timeVec     = t;
                AccVelDisp.OriAccl     =   xdd;                
                AccVelDisp.FinalAccl   =   FinalAccl;
                AccVelDisp.FinalVelo   =   FinalVelo;
                AccVelDisp.FinalDisp   =   FinalDisp;
                      
        end      
       
        function FilteredValues = DCSigFilter(inputObj)
           
                % Initialize
                t               = inputObj.time;
                sig             = inputObj.InputSignal;
                cutoff          = inputObj.FreqCutoff;
                alpha           = inputObj.Alpha;
                passtype        = inputObj.FilterType;
                filtermethod    = inputObj.FilterMethod;
                firorder        = inputObj.FIRorder;
                
                % Sampling Time
                Ts = t(5) - t(4);
                Fs = 1/Ts;
            
                [FilterdSignal, FiltsigFreq]    = func_DCclean(sig, cutoff, alpha, Fs, ...
                                   passtype,filtermethod,firorder);        
            
                FilteredValues.Signal       = FilterdSignal;
                FilteredValues.Frequency    = FiltsigFreq;
        end
    end
    
end


%% Class only special functions (No access outside the class)
%-------------------------------------------------------------------------

% DC Cleaner
function [sigflt, sigfrq] = ...
          func_DCclean(sig, cutoff, alpha, fs, passtype,filtermethod,firorder)

% This function FUNC_DCCLEAN removes the low frequency content (for the
% given cutoff value) and the DC offset

x = length(sig); 
k = cutoff*(x/fs);
n = round(k);


switch filtermethod
    case 'fft'
        SIG_fft = fft(sig, x);
        switch passtype 
            case 'lowpass'
                SIG_fft(1) = complex(alpha*abs(SIG_fft(n(1))),0);
                SIG_fft(x) = complex(alpha*abs(SIG_fft(n(1))),0);
                if (length(n)>1)
                   error('Too many cutoff frequencies') 
                end
                for i=n:round((x/2)-1)
                    SIG_fft(i) = alpha*SIG_fft(n);
                    SIG_fft(x-i) = conj(SIG_fft(i));
                end

            case 'highpass'
                SIG_fft(1) = complex(alpha*abs(SIG_fft(n(1))),0);
                if (length(n)>1)
                   error('Too many cutoff frequencies') 
                end
                for i=2:n-1
                    SIG_fft(i) = alpha*SIG_fft(n);
                    SIG_fft(x-(i-2)) = conj(SIG_fft(i));
                end

            otherwise
                if (length(n)>2)
                   error('Too many cutoff frequencies') 
                elseif (length(n)<2)
                   error('Too few cutoff frequencies') 
                end

                SIG_fft(1) = complex(alpha*abs(SIG_fft(n(1))),0);
                SIG_fft(x) = complex(alpha*abs(SIG_fft(n(1))),0);
                for i = n(2):round((x/2)-1)
                    SIG_fft(i) = alpha*SIG_fft(n(2));
                    SIG_fft(x-i) = conj(SIG_fft(i));
                end

                for i = n(1):-1:2
                    SIG_fft(i) = alpha*SIG_fft(n(1));
                    SIG_fft(x-i) = conj(SIG_fft(i));
                end        
        
        end 
        sigfrq = SIG_fft;
        sigflt = real(ifft(SIG_fft));
           
    case 'fir'
        
        switch passtype
            case 'lowpass'
                if (length(cutoff)>1)
                   error('Too many cutoff frequencies') 
                end
                h=fdesign.lowpass('N,Fc',firorder,cutoff,fs);
                d=design(h); %Lowpass FIR filter
                sigflt=filtfilt(d.Numerator,1,sig); %zero-phase filtering 
                sigfrq = abs(fft(sigflt,x));
                
            case 'highpass'
                if (length(cutoff)>1)
                   error('Too many cutoff frequencies') 
                end
                h=fdesign.highpass('N,Fc',firorder,cutoff,fs);
                d=design(h); %Highpass FIR filter
                sigflt=filtfilt(d.Numerator,1,sig); %zero-phase filtering 
                sigfrq = abs(fft(sigflt,x));              
                
            otherwise 
                if (length(cutoff)>2)
                   error('Too many cutoff frequencies') 
                elseif (length(cutoff)<2)
                   error('Too few cutoff frequencies') 
                end
                h=fdesign.bandpass('N,Fc1,Fc2',firorder,cutoff(1),cutoff(2),fs);
                d=design(h); %Bandpass FIR filter
                sigflt=filtfilt(d.Numerator,1,sig); %zero-phase filtering 
                sigfrq = abs(fft(sigflt,x));     
                
        end      
end


   
end

