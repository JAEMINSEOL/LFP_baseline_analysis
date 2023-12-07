clear; clc; close all;
warning off;
% rng('shuffle');

%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
ModulesROOT = [MotherROOT '\Analysis program'];
DatROOT.raw = ['G:\EPhysRawData\RawData'];
DatROOT.parsed = [MotherROOT '\Parsed Data'];
SaveROOT.mat = [DatROOT.parsed '\Theta phase\mat files (new ref)'];
FigROOT = [MotherROOT '\Plots'];
rasterROOT = [DatROOT.raw '\variables for display'];

SPKmotherROOT = 'D:\SUB-CA1 Ephys\2. SPK Data';
LFPmotherROOT = 'D:\SUB-CA1 Ephys\3. LFP Data';

mapROOT_out = [DatROOT.parsed '\map files (outbound) epoch_filtered'];
boundaryROOT_out = [DatROOT.parsed '\boundary files\mat files (outbound) - epoch_filtered'];
SPKmotherROOT = 'D:\SUB-CA1 Ephys\2. SPK Data';
LFPmotherROOT = 'D:\SUB-CA1 Ephys\3. LFP Data';


SaveROOT.fig_root = [LFPmotherROOT '\4. Phase\Phase field\figures (condition sheet) STD'];
if ~exist(SaveROOT.fig_root,'dir'), mkdir(SaveROOT.fig_root); end

SaveROOT.fig{1} = [SaveROOT.fig_root '\CA1 SF'];
SaveROOT.fig{2} = [SaveROOT.fig_root '\CA1 MF'];
SaveROOT.fig{3} = [SaveROOT.fig_root '\SUB SF'];
SaveROOT.fig{4} = [SaveROOT.fig_root '\SUB MF'];
SaveROOT.fig{5} = [SaveROOT.fig_root '\CA1-SUB'];
SaveROOT.fig{6} = [SaveROOT.fig_root '\CA1 no field'];
SaveROOT.fig{7} = [SaveROOT.fig_root '\SUB no field'];
SaveROOT.fig{8} = [SaveROOT.fig_root '\CA1-SUB no field'];

for dir_iter = 1 : length(SaveROOT.fig)
    if ~exist(SaveROOT.fig{dir_iter},'dir'), mkdir(SaveROOT.fig{dir_iter}); end
end
addpath(genpath(ModulesROOT))
rmpath(genpath([ModulesROOT '\Modules_CH']))
%% set default figure paramters
ratemap_number = 7;
ratemap_name = {'Overall','Zebra','Bamboo','Pebbles','Mountain','Left','Right'};

overallMap_index = [1 10 0 0 0 3];
overall_map = 1;

ColorSet = [1 0 0; 0.1 0.8 0.2; 0 0 1; 0 1 1; 1 0 1; 0 0 0.5; 0.5 1 0; 0 1 0.5; 0 0.5 1; 1 1 0];

p_alpha = 0.05;

%% load clusterID list
[inputCSVs] = readcell([InfoROOT '\ClusterList.csv']);
Recording_region = readtable([InfoROOT '\Recording_region.csv']);
DivPnts = readtable([InfoROOT '\diverging_points.csv']);


%%
% outputCSV = fopen([LFPmotherROOT '\phase modulation strength.csv'],'w');
% fprintf(outputCSV,'clusterID,region,group,NumOfFields,p_rayleigh,z_rayleigh,MRL,MRL_corrected,preferred phase\n');

% outputCSV = fopen([LFPmotherROOT '\cluster quality.csv'],'w');
% fprintf(outputCSV,'clusterID,region,group,NumOfFields,field#,isoldist,L-ratio\n');

% outputCSV = fopen([LFPmotherROOT '\rate vs phase RDI 200103 p.csv'],'w');
% fprintf(outputCSV,'clusterID,region,group,#field rate,#field phase,RDI scene rate,RDI scene rate p,RDI choice rate,RDI choice rate p,RDI scene phase,RDI scene phase p,RDI choice phase,RDI choice phase p\n');

%% shuffling inputCSVs for manual clustering
% load([saveROOT.fig_root '\shuffled_list'],'shuffled_list');

for clRUN = 225:225
    try
        clusterID = inputCSVs{clRUN};
        
        findHYPEN = strfind(clusterID,'-');
        thisRID = clusterID(1:findHYPEN(1)-1);
        thisSID = clusterID(findHYPEN(1)+1:findHYPEN(2)-1);
        thisTTID = clusterID(findHYPEN(2)+1:findHYPEN(3)-1);
        thisCLID = clusterID(findHYPEN(3)+1:end);
        sessionID = [thisRID '-' thisSID];
        
        %     if strcmp(clusterID(1:3),'295'), continue; end
        disp([clusterID ' start']);
        
        row = find(ismember(Recording_region.SessionID,sessionID));
        col = Recording_region.(['TT' num2str(thisTTID)]);
        RegionIndex = cell2mat(col(row));
        
        session_type = get_sessionType(clusterID(1:3),clusterID(5:6));
        if session_type==3, session_type=2; end

        %% 1D rate map
        
        %      load([mapROOT_out '\rat' clusterID '.mat'],'skaggsMap1D','stem_end_index','skaggsMap_right1D','skaggsMap_left1D','onmazeAvgFR1D','rawMap1D');
        %     load([boundaryROOT_out '\rat' clusterID '.mat'],'field_count','field_size','start_index','end_index');
        %
        %     display_skaggs = cat(2,skaggsMap1D{:},skaggsMap_left1D,skaggsMap_right1D);
        %     max_position = size(display_skaggs,1);
        %     max_rates = max(display_skaggs(:));
        
        
        %% FR-based field classification

    
% end
        
        
        
        %%
        get_thisFieldMap_JM;
%  save([SaveROOT.mat '\rat' clusterID '.mat'],'thisPHASE_backup','thisPHASE','thisFieldMap','nCluster','RDI','Cluster_quality','thisPHASE_stat','-append');
         %%
%         thisPHASE = getDBSCAN(clusterID,SaveROOT,0);
        save([SaveROOT.mat '\rat' clusterID '.mat'],'thisPHASE_backup','thisPHASE','thisFieldMap','nCluster','Cluster_quality','RDI','thisPHASE_stat','-append');

        if isempty(thisPHASE), continue; end
        
        load([SaveROOT.mat '\rat' clusterID '.mat'],'thisPHASE_backup','thisPHASE','thisFieldMap','nCluster','RDI','RDI_rate','Cluster_quality','thisPHASE_stat','stdMap_rate','RDI_revised','RDI_rate_revised');
        
        group = 'NaN';
        if nCluster == 1, group = 'SF'; elseif nCluster > 1, group = 'MF'; end
        
        %% display
        
        % %     getRDI_revised;
        %
        % %     display_rateVSphaseSheet_STD;
        %
        % %     display_fieldProfileSheet;
        %
        % %     display_conditionSheet_STD;
        %
        % %     thisPHASE.phase = thisPHASE.phase + 360;
        %
        % %     display_manualSheet_STD_forDisplay;
        %
        % % display_figure4;
        
        %% save figure as eps format
        %
        % saveROOT.fig = 'D:\SUB-CA1 Ephys\Manuscript (PC)\Figure4';
        %
        % set(gcf,'renderer','Painters');
        % saveas(f,[saveROOT.fig '\rat' clusterID],'epsc');
        %
        % saveImage(f,[saveROOT.fig '\rat' clusterID '.jpg'],'pixels',imagePosition);
        
        %% save figure as jpg format
        
        %     if strcmp(region,'CA1') && nCluster == 1, dir_iter = 1;
        %     elseif strcmp(region,'CA1') && nCluster > 1, dir_iter = 2;
        %     elseif (strcmp(region,'Subiculum') || strcmp(region,'Fiber (SUB)')) && nCluster == 1, dir_iter = 3;
        %     elseif (strcmp(region,'Subiculum') || strcmp(region,'Fiber (SUB)')) && nCluster > 1, dir_iter = 4;
        %     elseif strcmp(region,'CA1-SUB'), dir_iter = 5;
        %     elseif strcmp(region,'CA1') && nCluster == 0, dir_iter = 6;
        %     elseif (strcmp(region,'Subiculum') || strcmp(region,'Fiber (SUB)')) && nCluster == 0, dir_iter = 7;
        %     elseif strcmp(region,'CA1-SUB') && nCluster == 0, dir_iter = 8;
        %     end
        %
        %     saveImage(f,[saveROOT.fig{dir_iter} '\rat' clusterID '.jpg'],'pixels',imagePosition);
        
        %%
        %     display_manualSheet_STD;
        %     saveImage(f,[saveROOT.fig{2} '\' num2str(clRUN) '.jpg'],'pixels',imagePosition);
        
        %% display quality sheet (to find low quality clustering)
        %
        %     flag = 0;
        %     for field_iter = 1 : nCluster
%         if (Cluster_quality.IsolDist(field_iter) < 10) || (Cluster_quality.Lratio(field_iter) > 0.03)
            %             flag = flag + 1;
            %         end
            %     end
            %
            %     if flag >= nCluster/2
            %         display_phaseSheet_STD;
            %
            %         thisPHASE_stat.MRL_corrected = thisPHASE_stat.MRL*max(p.Values);
            %         save([saveROOT.mat '\rat' clusterID '.mat'],'thisPHASE_stat','-append');
            %
            %         saveImage(f,[saveROOT.fig{2} '\rat' clusterID '.jpg'],'pixels',imagePosition);
            %     end
            
            %% filtering units with overlapped fields
            %
            % if nCluster > 1
            %     flag = 0;
            %     temp_fieldRange = thisFieldMap{1}.field_range;
            %     for field_iter = 2 : nCluster
            %         if temp_fieldRange(2) - thisFieldMap{field_iter}.field_range(1) +1 > (thisFieldMap{field_iter-1}.field_size / 2)/2
            %             flag = 1;
            %         elseif temp_fieldRange(2) - thisFieldMap{field_iter}.field_range(1) +1 > (thisFieldMap{field_iter}.field_size / 2)/2
            %             flag = 1;
            %         end
            %         temp_fieldRange = thisFieldMap{field_iter}.field_range;
            %     end
            %
            %     if flag == 1
            %         display_phaseSheet_STD;
            %         saveImage(f,[saveROOT.fig{3} '\rat' clusterID '.jpg'],'pixels',imagePosition);
            %     end
            % end
            
            %% display with phase rose plot (to find phase-locked units)
            
            %     flag = 1;
            %     if flag
            %         display_phaseSheet_STD;
            %         fprintf(outputCSV,sprintf('%s,%s,%s,%d,%f,%f,%f,%f,%f\n',clusterID,region,group,nCluster,thisPHASE_stat.pval,thisPHASE_stat.z,thisPHASE_stat.MRL,thisPHASE_stat.MRL*max(p.Values),thisPHASE_stat.mean));
            %         %             saveImage(f,[saveROOT.fig{1} '\rat' clusterID '.jpg'],'pixels',[2600 300 300 800]);
            %         close(f);
            %     end
            
            %%
            %         display_qualitySheet_STD;
            %         min_quality = min(Cluster_quality.IsolDist);
            %         saveImage(f,[saveROOT.fig{dir_iter} '\' sprintf('%.0f',min_quality*1000) '_rat' clusterID '.jpg'],'pixels',[2600 300 300 500]);
            
            %% write output csv file
            
            %             for field_iter = 1 : nCluster
            %                 fprintf(outputCSV,sprintf('%s,%s,%s,%d,%d,%f,%f\n',clusterID,region,group,nCluster,field_iter,Cluster_quality.IsolDist(field_iter),Cluster_quality.Lratio(field_iter)));
            %             end
            
            %
            %     if field_count == 0 && nCluster == 1, Ncategory = 'n0-1';
            %     elseif field_count == 1 && nCluster == 1, Ncategory = 'n1-1';
            %     elseif field_count == 1 && nCluster == 2, Ncategory = 'n1-2';
            %     elseif field_count == 1 && nCluster > 2, Ncategory = 'n1-3';
            %     elseif field_count == 2 && nCluster == 2, Ncategory = 'n2-2';
            %     elseif field_count == 2 && nCluster > 2, Ncategory = 'n2-3';
            %     elseif field_count == 1 && nCluster == 0, Ncategory = 'n1-0';
            %     elseif field_count == 2 && nCluster == 1, Ncategory = 'n2-1';
            %     else, Ncategory = 'nan';
            %     end
            %
            %     fprintf(outputCSV,sprintf('%s,%s,%s,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f\n', clusterID, region, group, field_count, nCluster, ...
            %         max(max(RDI_rate.d(:,1:2))), min(min(RDI_rate.p(:,1:2))), max(RDI_rate_revised.d(:,3)), min(RDI_rate_revised.p(:,3)), ...
            %         max(max(RDI.d(:,1:2))), min(min(RDI.p(:,1:2))), max(RDI_revised.d(:,3)), min(RDI_revised.p(:,3))));
            %
            
            %%
            
            disp([clusterID ' done']);
            clear thisPHASE_backup thisPHASE thisFieldMap nCluster RDI
            catch
                disp([clusterID ' fieldprofiling failed'])
        end
end

close all; fclose all;