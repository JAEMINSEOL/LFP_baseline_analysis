% Initial_LFP

clear all; clc; fclose all;

ROOT.Mother = 'D:\JS LFP analysis';
ROOT.Raw.Mother = 'F:\EPhysRawData\RawData';

ROOT.Raw.Map = [ROOT.Raw.Mother '\map files (outbound) epoch_filtered_smoothed'];
ROOT.Raw.Var = [ROOT.Raw.Mother '\variables for display'];
ROOT.Program = [ROOT.Mother '\Analysis Program'];
ROOT.Modules = ['D:\Modules'];
ROOT.Info = [ROOT.Mother '\Information Sheet'];
ROOT.Save = [ROOT.Mother '\Processed Data'];
addpath(genpath(ROOT.Program))
addpath(genpath(ROOT.Modules))
%% set initial parameters
% cell criterions
Params.crit.frlow=1;
Params.crit.fr=10;
Params.crit.width=300;
Params.crit.si=0.5;

% define frequency
Params.Fs = 2000;  % sampling frequency
Params.Fn = Params.Fs/2;  % Nyquist frequency
Params.F0 = 60/Params.Fn; % notch frequency

% define loadCSC variable
Params.CSCfileTag = 'RateReduced';
Params.exportMODE = 1;
Params.behExtraction = 0;

% switch
Params.noiseFilteringSwitch = 1;
Params.saveSwitch = 1;
Params.exportSwitch = 1;

% define data duration
Params.freqN = 2048;
Params.freqLimit = 450;
Params.freqBin = ceil(Params.freqLimit/Params.Fs * Params.freqN);

Params.noise = [350 450]; %noise Range
Params.ripple = [150 250]; %SWR range
Params.theta = [4 12];
Params.gamma = [70 115];
Params.low = 20;


cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
cellfindn = @(string)(@(cell_contents)(strncmp(string,cell_contents,11)));
cellfindn2 = @(string)(@(cell_contents)(strncmp(string,cell_contents,3)));

