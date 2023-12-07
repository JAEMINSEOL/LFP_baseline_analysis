
clear; clc; fclose all;

MotherROOT = ['D:\HPC-LFP project'];
ModulesROOT=[MotherROOT '\Analysis program\Modules_JM'];% analysis path
DataROOT=[MotherROOT '\RawData'];


addpath(genpath(ModulesROOT));% data path


cd(ModulesROOT);
ratList = {'313','425','454','471','487','553','562'};
% ratList = {'425'};

for ssRUN = 1:1
    for ssNUM = 2:2
        for thataLOW = 3:3:6
            thisRID = ratList{ssRUN};
            if ssNUM<10
            thisSID = ['0' num2str(ssNUM)];
            else
               thisSID = num2str(ssNUM); 
            end
            thisSTYPE='STD';
%             if ssNUM<3 thisSTYPE='STD'; else thisSTYPE='AMB'; end
            %% input variables
            noise = [350 500]; %noise Range
            SWR = [150 250]; %SWR range
            theta = [thataLOW 13]; %theta range
            
            
            %load fairSWRList CSVs file
            
            clear inputCSV
            % inputCSV = readtable('FilteredCSCList_Rat454.csv','Delimiter',',','ReadVariableNames',0);
            % inputCSV = table2array(inputCSV);
            for tt=1:24
                inputCSV{tt,1} = [thisSTYPE '\3. LFP Data\rat' thisRID '\rat' thisRID '-' thisSID '\CSC' num2str(tt)];
            end
            
            cRange = theta; %both noise and SWR files are needed for SWR detection
            %
            % disp(['current filtering range is ' num2str(cRange(1)) 'Hz - ' num2str(cRange(2)) 'Hz. Check the range and press enter.']);
            % pause;
            
            %% set variables
            global Fs;
            
            Fs = 2000;  % sampling frequency
            Fn = Fs/2;  % Nyquist frequency
            
            % define loadCSC variable
            CSCfileTag = 'RateReduced';
            exportMODE = 1;
            %1: save as new ncs file. 0 (or anything else): only extract EEG data.
            behExtraction = 0;
            %1: behavior epoch only, 0: whole session including pre- and post-sleep
            %2: post-sleep only.
            
            %error reporter
            errorCscs = strings(0, 1);
            errorIdx = 0;
            
            for cscRUN = 1 : 24 %size(inputCSV,1)
                
                % for cIdx = 1:24
                %
                %     cscID = sprintf('%d-%02d-%d', cRat,cDay, cIdx);
                %     inputCSV{cIdx, 1} = cscID;
                %     inputCSV{cIdx, 2} = 'CA1';
                % end
                
                
                cscID = inputCSV{cscRUN,1};
                CSCdata = loadCSC4_JM(cscID, DataROOT, CSCfileTag, exportMODE, behExtraction);
                
                disp([cscID ' is processing']);
                if CSCdata.error ~= 0 %some error exist
                    disp([cscID ' is not valid session or file']);
                    clear CSCdata;
                    
                    %save to the error reporter
                    errorIdx = errorIdx + 1;
                    errorCscs(errorIdx, 1) = cscID;
                    
                    continue;
                end
                
                
                EEG.raw = CSCdata.eeg(:);
                
                %% theta band filtering
                
                if isequal(cRange, theta)
                    
                    n=3;
                    Wn=theta;
                    ftype='bandpass';
                    [b,a]= butter(n, Wn/Fn, ftype);
                    EEG.filtered = filtfilt(b,a,EEG.raw);
                    
                else
                    
                    %% SWR band filtering ( + noise)
                    Wp = [cRange(1)-5 cRange(2)+5];   % passband edge frequencies
                    Ws = [cRange(1)-20 cRange(2)+20];   % stopband edge frequencies
                    Rp = 3;         % passband ripple of no more than Rp dB, When Rp is chosen as 3 dB, the Wn in BUTTER is equal to Wp in buttord.
                    Rs = 15;        % stopband attenuation of at least Rs dB
                    ftype = 'bandpass';
                    
                    % frequency normalization
                    Wp = Wp/Fn;
                    Ws = Ws/Fn;
                    
                    [n,Wn] = buttord(Wp,Ws,Rp,Rs);  % n: order of filter, Wn: cutoff frequency
                    [z,p,k] = butter(n,Wn,ftype);
                    [sos,g] = zp2sos(z,p,k);
                    
                    EEG.filtered = filtfilt(sos,g,EEG.raw);
                end
                
                %% export filtered data to ncs file
                if exportMODE
                    % reshape
                    colN = floor(numel(EEG.filtered)/512);
                    CSCdata.eeg = reshape(EEG.filtered, 512, colN);
                    findHYPHEN = find(cscID == '\');
                    cscDir = cscID(1, 1:findHYPHEN(4) - 1);
                    
                    % export
                    sessionROOT = [DataROOT '\' cscDir];
                    if ~exist(sessionROOT, 'dir'), mkdir(sessionROOT); end
                    Switch = 'butterSwitch_export';
                    filename_tail = [CSCfileTag '_' num2str(cRange(1)+1) '-' num2str(cRange(2)-1) 'filtered'];
                    export_Mat2NlxCSC(CSCdata, CSCdata, sessionROOT, filename_tail, Switch)
                end
                
                %% ----
                disp([cscID ' filtering done']);
                
                clear CSCdata EEG PSD Power Timestamps_expand
                
                
            end
        end
    end
end

% save([root '\' 'errorReporter.mat'], 'errorCscs');