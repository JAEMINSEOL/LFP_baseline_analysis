 clear; clc; close all;

%%
cd(['G:\CA3_recording\CA3_DG\clusterSummary_linearize\linearized_result_mat'])
List=dir;
load(ans)
 i=1;
%% Write New Sheet
ClusterSummary_Master.ClusterID(clRUN) = inputCSVs.UnitID(clRUN);
ClusterSummary_Master.Session(clRUN) = SessionList(session_type);
if ismember(thisRID,LesionList), str='(DG Lesion)'; else, str=[]; end
ClusterSummary_Master.Region(clRUN) = [cell2mat(inputCSVs.Region(clRUN)) str];

ClusterSummary_Master.RefPeriod(clRUN)
ClusterSummary_Master.SpikeWidth(clRUN)

ClusterSummary_Master.NSpikes(clRUN)
ClusterSummary_Master.MeanFR(clRUN)

ClusterSummary_Master.NSpikes_Outbound(clRUN)
ClusterSummary_Master.MeanFR_Outbound(clRUN)
ClusterSummary_Master.SpaInfo_Outbound(clRUN)
end
