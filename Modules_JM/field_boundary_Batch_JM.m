%
% 2015-Jul-14

% % Initializing

clear; clc; close all; fclose all;

% Roots defining

MotherROOT = 'D:\HPC-LFP project';

InfoROOT = [MotherROOT '\Information Sheet'];
ModulesROOT = [MotherROOT '\Analysis program'];
DatROOT = [MotherROOT '\RawData'];
ProcROOT = [MotherROOT '\Parsed Data'];
PlotROOT = [MotherROOT '\Plots'];

addpath(genpath(ModulesROOT))
rmpath(genpath([ModulesROOT '\Modules_CH']))
DivPnts = readtable([InfoROOT '\diverging_points.csv']);


mapROOT = [ProcROOT '\map files (outbound) epoch_filtered'];
% new_map_root = [motherROOT '\2. Place field, correlation, RMI\2.6. Baseline cutting\2.6.1. Baseline cutting map\mat files'];

saveROOT = [ProcROOT '\boundary files'];

saveROOT_mat = [saveROOT '\mat files (outbound) - epoch_filtered'];
saveROOT_fig  = [PlotROOT '\figures (outbound) - epoch_filtered'];
if ~exist(saveROOT_mat,'dir'), mkdir(saveROOT_mat); end
if ~exist(saveROOT_fig,'dir'), mkdir(saveROOT_fig); end
%

% CSV files defining
% clusterCSV_name = [motherROOT '\temp_all.csv'];
% clusterCSV = fopen(clusterCSV_name, 'r');

% outputCSV_name = [save_root '\fields_boundary.csv'];
% if exist(outputCSV_name)
%     outputCSV = fopen(outputCSV_name, 'a');
% else
%     outputCSV = fopen(outputCSV_name, 'w');
%     header = 'clusterID,# of fields,Field start(1),Field end,Field size,Field peak rates,Field peak index,Field center\n';
%     fprintf(outputCSV, header);
% end
%

% %


% % Read clusterID
% 
% start_cell = 1;
% for iter = 1 : start_cell
%     clusterID = fgetl(clusterCSV);
% end

% while ischar(clusterID)
    [inputCSVs] = readcell([InfoROOT '\ClusterList.csv']);
for clRUN= 914:numel(inputCSVs)
    try
        clusterID = inputCSVs{clRUN};
    session_type = get_sessionType(clusterID(1:3),clusterID(5:6));
    
%     if session_type~=2, clusterID = fgetl(clusterCSV); continue; end
    
    [field_count, start_index, end_index, field_size, h] = field_boundary_function_2f2(ProcROOT, mapROOT, clusterID);
    %     [field_count_norm, start_index_norm, end_index_norm, field_size_norm, h] = field_boundary_function_2f2(motherROOT, mapROOT, clusterID);
    
    if h ~= 0
%         saveImage(h, [saveROOT_fig '\rat' clusterID '.jpg'], 'pixels', [50 50 1200 1500]);
    end
    
     save([saveROOT_mat '\rat' clusterID '.mat'], 'field_count', 'start_index', 'end_index', 'field_size');
%     save([saveROOT_mat '\rat' clusterID '.mat'], 'field_count_norm', 'start_index_norm', 'end_index_norm', 'field_size_norm','-append');

    
%     clear field_count start_index end_index field_size h;
    clear field_count_norm start_index_norm end_index_norm field_size_norm h;
    
    disp(['cluster ' clusterID ' is done.']);
%     clusterID = fgetl(clusterCSV);
    catch
       disp(['cluster ' clusterID ' is failed.']); 
    end
end
% % 


% % Closing
% fclose(clusterCSV);
% fclose(outputCSV);
% %