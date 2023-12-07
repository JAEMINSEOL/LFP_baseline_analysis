%
%

%% Initializing

clear; clc; close all; fclose all;

MotherROOT = 'D:\HPC-LFP project';

InfoROOT = [MotherROOT '\Information Sheet'];
ModulesROOT = [MotherROOT '\Analysis program'];
DatROOT = [MotherROOT '\RawData'];
ProcROOT = [MotherROOT '\Parsed Data'];
SaveROOT.fig = [MotherROOT '\Plots\DBSCAN_200921'];

addpath(genpath(ModulesROOT))
rmpath(genpath([ModulesROOT '\Modules_CH']))
DivPnts = readtable([InfoROOT '\diverging_points.csv']);


% Input : clusterID
clusterCSV_name = [InfoROOT '\ClusterList.csv'];
clusterCSV = fopen(clusterCSV_name, 'r');
%

% Output : save root
saveROOT1 = [ProcROOT '\map files (outbound) epoch_filtered'];
saveROOT2 = [ProcROOT '\map files (inbound)'];
saveROOT3 = [ProcROOT '\map figures'];
%

% %%
% cd(motherROOT);
% outputCSV = fopen('result csv rat561.csv', 'w');
% 
% fprintf(outputCSV, 'clusterID,numOfSpk1D out,onmazeAvgFR1D out,onmazeMaxFR1D out,SpaInfoScore1D out,');
% fprintf(outputCSV, 'numOfSpk_stem1D out,onmazeAvgFR_stem1D out,onmazeMaxFR_stem1D out,SpaInfoScore_stem1D out,');
% fprintf(outputCSV, 'numOfSpk1D in,onmazeAvgFR1D in,onmazeMaxFR1D in,SpaInfoScore1D in,');
% fprintf(outputCSV, 'numOfSpk_stem1D in,onmazeAvgFR_stem1D in,onmazeMaxFR_stem1D in,SpaInfoScore_stem1D in\n');

%% Read clusterID
[inputCSVs] = readcell([InfoROOT '\ClusterList.csv']);
for clRUN= 174:numel(inputCSVs)
      try
% start_cell = 1;
% for iter = 1 : start_cell
%     if iter>0
%     clusterID = fgetl(clusterCSV);
%     end
% end
% if iter>200
    clusterID = inputCSVs{clRUN};
    
    session_type = get_sessionType(clusterID(1:3),clusterID(5:6));
%     
%     if session_type~=2, clusterID = fgetl(clusterCSV); continue; end
    
%     make_maps_function_2b5(clusterID, motherROOT, saveROOT1);
    make_maps_function_2b5_speedFiltered_JM(clusterID, DatROOT,ProcROOT,DivPnts);
%     make_maps_function_2b5_inbound(clusterID, motherROOT, saveROOT2);
    
    % write output csv file
%     findHYPHEN = find(clusterID == '-');
%     thisRID = clusterID(1, 1:findHYPHEN(1) - 1);
%     thisSID = clusterID(1, findHYPHEN(1) + 1:findHYPHEN(2) - 1);
%     check_numOfSpk;
    
    % display
    findHYPHEN = find(clusterID == '-');
    thisRID = clusterID(1, 1:findHYPHEN(1) - 1);
    thisSID = clusterID(1, findHYPHEN(1) + 1:findHYPHEN(2) - 1);
    
%     if get_sessionType(thisRID,thisSID) == 1, check_maps_display; end
    
    
    disp(['cluster ' clusterID ' is processed!']);
    clusterID = fgetl(clusterCSV);
      catch
          disp(['cluster ' clusterID ' is failed!']);
      end
end

%

%% Closing

fclose all;
%