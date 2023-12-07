  %% Display
        
        f = figure('position',imagePosition,'color','white');
        
        %% first row
        
        % title
        subplot('position',[0.7 0.9 0.25 0.1]);
        text(0,0.5,['rat' clusterID ' (' RegionIndex ')'],'fontsize',12);
        axis off;
        
        % 1D rate map
        subplot('position',[0.386 0.85 0.25 0.12]);
        hold on; box off;
        plot(display_skaggs, ':', 'color', [.5 .5 .5], 'linewidth', 1);
        plot([1 1]*stem_end_index+0.5, [0, max_rates * 1.1],'r:');
        
        if field_count > 0
            for iterB = 1 : field_count
                temp_field = display_skaggs;
                temp_field(temp_field < 0) = 0;
                
                plot(start_index(iterB) : end_index(iterB), temp_field(start_index(iterB) : end_index(iterB)), 'color', 'k', 'lineWidth', 1);
                temp_field_rate = max(temp_field(start_index(iterB) : end_index(iterB)));
                temp_field_index = min(find(temp_field(start_index(iterB) : end_index(iterB)) == temp_field_rate)) + start_index(iterB) - 1;
                
                if ~isnan(temp_field_rate)
                    plot(temp_field_index, temp_field_rate, '.', 'color', 'red');
                    text(temp_field_index, temp_field_rate, [jjnum2str(temp_field_rate,2) ' Hz'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom','fontsize',8);
                end
            end
        end
        
        set(gca,'XTick',[1 stem_end_index length(display_skaggs)],'XTickLabel',{'480','divPnt','0'},'tickdir','out');
        xlim([1 max_position]); ylim([0 max_rates*1.1]);
        ylabel('Firing rates (Hz)');
        
        
        %%

        %% second row
        
        display_phase_all = thisPHASE_backup.scene > 0;
        display_phase = thisPHASE.scene > 0;
        % Cluster Size
        subplot('position',[0.06 0.9 0.3 0.15]); hold on; box off; axis off
        text(-0.05,(nCluster+0.2)*0.2,['Total Spikes = ' num2str(size(thisPHASE_backup,1)/3)])
        text(-0.05,(nCluster-0.9)*0.2,['Cluster /  N  / IsoDist / L-Ratio'],'color','k')
        i=1; j=0; sz=[];
        ncs=nc; ncs2=nc2;
        for field_iter = 1 : nCluster
            if exist('Val')==1
            switch Val(field_iter)
                case 0, ValStr='(X)';
                case 0.5, ValStr='(?)';
                case 1, ValStr='(O)';
            end
            else
                ValStr=[];
            end
            sz(field_iter) = size(thisPHASE(thisPHASE.cluster == field_iter & display_phase,:),1);
                text(0,(nCluster-field_iter-1)*0.2,['Cl ' num2str(i) ' / ' num2str(sz(field_iter)) ' / ' ...
                    sprintf('%.2f',Cluster_quality.IsolDist(field_iter)) ' / ' ...
                    sprintf('%.4f',Cluster_quality.Lratio(field_iter)) ValStr],'color',ColorSet(field_iter,:)*0.7)
                
                CQual(nc,1:12) = {clusterID_new, i, sz(field_iter), RegionIndex_d, ...
                    Cluster_quality.IsolDist(field_iter), Cluster_quality.Lratio(field_iter),...
                    thisFieldMap{field_iter}.phase_size, thisFieldMap{field_iter}.phase_range(1), thisFieldMap{field_iter}.phase_range(2),...
                    thisPHASE_stat{field_iter}.pval,thisPHASE_stat{field_iter}.mean,thisPHASE_stat{field_iter}.median};
                
                i=i+1;
                nc=nc+1;
                nc2=nc2+1;
                if or(Cluster_quality.Lratio(field_iter)<=0.02, Cluster_quality.IsolDist(field_iter)>=14)
                    j=j+1;
                end
        end
        %%
        clNum2 = inputCSVs.ClustNum(clRUN);
        if length(thisFieldMap{1, 1}.skaggsMap1D)<10
            edpnt=1;
        else
            edpnt=10;
        end
%         [s,t]=findpeaks(thisFieldMap{clNum2, 1}.skaggsMap1D{1, edpnt});
[s,t]=max(thisFieldMap{clNum2, 1}.skaggsMap1D{1,edpnt});
        if ~isempty(t)
        inputCSVs.LeftTailRatio(clRUN)=s(1)/min(thisFieldMap{clNum2, 1}.skaggsMap1D{1,edpnt}(1:t(1)));
        else
            inputCSVs.LeftTailRatio(clRUN)=1;
        end
        inputCSVs.MeanFr(clRUN)=thisFieldMap{clNum2, 1}.onmazeAvgFR1D(edpnt);
        inputCSVs.PeakFr(clRUN)=thisFieldMap{clNum2, 1}.onmazeMaxFR1D(edpnt);
        inputCSVs.SpatialInfo(clRUN)=thisFieldMap{clNum2, 1}.SpaInfoScore1D(edpnt);
        rawMat = cell2mat(thisFieldMap{clNum2, 1}.rawMap1D(edpnt));
        occMat = cell2mat(thisFieldMap{clNum2, 1}.occMap1D(edpnt));
        inputCSVs.Sparsity(clRUN) = calcSparsity(occMat, rawMat);
        
        
        
        if ~isempty(sz)
        
            if exist('Val')==1
                switch min(Val)
                    case 0
                    Filt='\Filter-0';
                    CQual(ncs:nc-1,13)={0};
                    case 0.5
                        Filt='\Filter-0.5';
                    CQual(ncs:nc-1,13)={0.5};
                    case 1
                    Filt='\Filter-1';
                    CQual(ncs:nc-1,13)={1};
                    otherwise
                                            Filt='\Filter-0';
                    CQual(ncs:nc-1,13)={0};

                end
            else
                if or(j/nCluster<0.5, nCluster==0)
                    Filt='\Filter-out';
                    CQual(ncs:nc-1,13)={0};
                    nc2=ncs2;
                else
                    Filt='\Filter-in';
                    CQual(ncs:nc-1,13)={1};
                end
            end

        
        %%
        temp_position = [0.08 0.1 0.25 0.7];
        
        % position-phase scatter plot
        subplot('position',temp_position); hold on; box off;
        plot(thisPHASE_backup.linearized_pos(display_phase_all),thisPHASE_backup.phase(display_phase_all),'.','color','k','markersize',3);
        set(gca,'xdir','rev','xtick',[480-max_position*10 DivPt 480],'xticklabel',{'0','DivPnt','480'});
        set(gca,'ytick',-180 : 180 : 180*4,'tickdir','out');
        xlim([480-max_position*10 480]); ylim([-180 180*4]);
        ylabel('theta phase (degree)');
        
        % DBSCAN
        subplot('position',temp_position+[0.31 0 0 0]); hold on; box off;
        plot(thisPHASE_backup.linearized_pos(display_phase_all),thisPHASE_backup.phase(display_phase_all),'.','color',[1 1 1]*0.6,'markersize',3);
        for field_iter = 1 : nCluster
            thisField = thisPHASE(thisPHASE.cluster == field_iter & display_phase,:);
             sz = size(thisPHASE(thisPHASE.cluster == field_iter & display_phase,:),1);
             if 1
            plot(thisField.linearized_pos,thisField.phase,'.','color',ColorSet(field_iter,:),'markersize',4);
             end
        end
        set(gca,'xdir','rev','xtick',[480-max_position*10 DivPt 480],'xticklabel',{'0','DivPnt','480'});
        set(gca,'ytick',-180 : 180 : 180*4,'tickdir','out');
        xlim([480-max_position*10 480]); ylim([-180 180*4]);
        xlabel(['e=' num2str(DBSCAN_parameter.epsilon) ', minPts=' num2str(DBSCAN_parameter.MinPts)]);
        
        % Smoothing
        h2 = subplot('position',temp_position+[0.62 0 0 0]); hold on; box off;
        imagesc(PHASE_matrix.smooth);
        colormap(gca,'jet');
        set(gca,'xtick',[0 size(PHASE_matrix.smooth,2)-DivPt size(PHASE_matrix.smooth,2)],'xticklabel',{'480','DivPnt','0'});
        set(gca,'YDir','normal','ytick',[],'tickdir','out');
        xlim([0 size(PHASE_matrix.smooth,2)]); ylim([0 180*5]);
        originalSize2 = get(gca, 'Position');
        colorbar('Location','northoutside','Position',temp_position+[0.62 +0.705 0 -0.68]);
        set(h2, 'Position', originalSize2);
        %%
%         edpnt=edpnt;
%                 display_skaggs = skaggsMap1D{edpnt};
%         subplot('position',temp_position);
%     hold on; box off;
%     plot(display_skaggs, 'color', [.5 .5 .5]);
%     plot([1 1]*stem_end_index, [0, max_rates * 1.1],':','color',[1 1 1]*0.2);
%     text(stem_end_index+0.5, max_rates*1.1, sprintf('%.2f hz',onmazeAvgFR1D(1)),'fontsize',9);
%     
%     if edpnt == 1
%         overall_map=[1:5];
%         for field_iter = 1 : field_count
%             temp_field = skaggsMap1D{overall_map};
%             temp_field(temp_field < 0) = 0;
%             
%             plot(start_index(field_iter) : end_index(field_iter), temp_field(start_index(field_iter) : end_index(field_iter)), 'color', 'k', 'lineWidth', 1.5);
%         end
%     end
%     
%     for field_iter = 1 : nCluster
%     field_skaggs = thisFieldMap{field_iter}.skaggsMap1D{edpnt};
%     field_skaggs(field_skaggs==0) = nan;
%         plot(field_skaggs, '-', 'color', ColorSet(field_iter,:), 'linewidth', 1);
%     end
%              set(gca,'XTick',[1 stem_end_index max_position], 'xticklabel', {},'tickdir','out'); %,'XTickLabel',{'startbox','divPnt','foodwell'},'tickdir','out');
%     xlim([1 max_position]); ylim([0 max_rates*1.1]);
%      ylabel('Firing rates (Hz)'); 
%     
%     display_phase_all = thisPHASE_backup.scene > 0;
%         display_phase = thisPHASE.scene > 0;
%         
%          if edpnt == 1, temp_position=temp_position+[0 -0.05 0 0.05]; end
%     subplot('position',temp_position+[0 -0.26 0 0.1]);    
%     hold on;
%     plot(thisPHASE_backup.linearized_pos(display_phase_all),thisPHASE_backup.phase(display_phase_all),'.','color',[1 1 1]*0.7,'markersize',3);
%     plot([480-max_position*10 480],[0 0],':','color',[1 1 1]*0.2);
%     
%     for field_iter = 1 : nCluster
%         thisField = thisPHASE(thisPHASE.cluster == field_iter & display_phase,:);
%         plot(thisField.linearized_pos,thisField.phase,'.','color',ColorSet(field_iter,:),'markersize',4);
%         
%         if edpnt == 1
%             x = linspace(0,max_position*10)';
%             y = predict(thisFieldMap{field_iter}.linear_mdl,x);
%             plot(x,y,'-','color',ColorSet(field_iter,:));
%             CQual{nc-nCluster-1+field_iter,14} = thisFieldMap{field_iter}.linear_mdl.Coefficients.Estimate(2);
%             CQual{nc-nCluster-1+field_iter,15} = thisFieldMap{field_iter}.linear_mdl.Rsquared.Ordinary;
%             CQual{nc-nCluster-1+field_iter,16} = thisFieldMap{field_iter}.linear_mdl.Coefficients.pValue(2);
%         end
%         
%     end
%     
%     set(gca,'xdir','rev','xtick',[480-max_position*10 DivPt 480],'xticklabel',{'0','DivPnt','480'});
% %     set(gca,'xdir','rev','xtick',[480-max_position*10 diverging_point max_position*10],'xticklabel',{'FdWell','DivPnt','StBox'});
%     set(gca,'ytick',-180 : 90 : 540,'tickdir','out','fontsize',8);
%     xlim([480-max_position*10 480]); %xlim([480-max_position*10 max_position*10]);
%     if ~isempty(thisPHASE),ylim([(floor(min(thisPHASE.phase)/90)-1)*90 (floor(min(thisPHASE.phase)/90)-1)*90+720]);
%     else, ylim([-180 540]);
%     end
%     %     ylim([floor(min(thisField.phase)/90)*90 floor(min(thisField.phase)/90)*90+720]); %ylim([1 1]*floor(precession_range(1)/90)*90+[0 360]);
%     if edpnt == 1, xlabel('linearized position','fontsize',9); ylabel('theta phase (degree)','fontsize',9); end
%     
        
        %% third row
        % manual clustering
        
        %     cluster_iter = find(ismember(shuffled_list,clusterID));
        %
        %     if ~isempty(cluster_iter)
        %         if cluster_iter < 10, cluster_iter_str = ['00' num2str(cluster_iter)];
        %         elseif cluster_iter < 100, cluster_iter_str = ['0' num2str(cluster_iter)];
        %         else cluster_iter_str = num2str(cluster_iter);
        %         end
        %
        %         temp_position = [0.03 0.02 0.31 0.4];
        %
        %         for rater_iter = 1 : 2
        %             this_image = imread([imageROOT{rater_iter} '\manual clustering (rater' num2str(rater_iter) ').pdf_page_' cluster_iter_str '.png']);
        %             this_image = this_image(240:666,:,:);
        %
        %             subplot('position',temp_position+(rater_iter-1)*[0.32 0 0 0]);
        %             imagesc(this_image); axis off;
        %         end
        %     end

        %%

  for n2 = clRUN:clRUN
%       if and(inputCSVs.phaseSize(n2)<300, inputCSVs.Nspikes(n2)>40)
%         saveas(f,[FigROOT '\DBSCAN\DBSCAN Summary(Sparsity)\Filter-in\' RegionIndex_d  '\' num2str(0.01*(sscanf(num2str(inputCSVs.Sparsity(n2)*100),'%d'))) '_'  cell2mat(inputCSVs.UnitID(n2)) '_' num2str(inputCSVs.ClustNum(n2)) '.jpg']);
%     saveas(f,[FigROOT '\DBSCAN\DBSCAN Summary(SpaInfo)\Filter-in\' RegionIndex_d  '\' num2str(0.01*(sscanf(num2str(inputCSVs.SpatialInfo(n2)*100),'%d'))) '_'  cell2mat(inputCSVs.UnitID(n2)) '_' num2str(inputCSVs.ClustNum(n2)) '.jpg']);
%   saveas(f,[FigROOT '\DBSCAN\DBSCAN Summary(Peak2Mean)\Filter-in\' RegionIndex_d  '\' num2str(0.01*(sscanf(num2str(inputCSVs.PeakFr(n2)/inputCSVs.MeanFr(n2)*100),'%d'))) '_'  cell2mat(inputCSVs.UnitID(n2)) '_' num2str(inputCSVs.ClustNum(n2)) '.jpg']);
%  saveas(f,[FigROOT '\DBSCAN\DBSCAN Summary(LeftTail)\Filter-in\' RegionIndex_d  '\' num2str(0.01*(sscanf(num2str(inputCSVs.LeftTailRatio(n2)*100),'%d'))) '_'  cell2mat(inputCSVs.UnitID(n2)) '_' num2str(inputCSVs.ClustNum(n2)) '.jpg']);
% saveas(f,[FigROOT '\DBSCAN\DBSCAN Summary(Phase Range)\Filter-in\' RegionIndex_d  '\' num2str(0.01*(sscanf(num2str(inputCSVs.phaseSize(n2)*100),'%d'))) '_'  cell2mat(inputCSVs.UnitID(n2)) '_' num2str(inputCSVs.ClustNum(n2)) '.jpg']);
if max(DBSCAN_parameter.epsilon)>=37 || sum((DBSCAN_parameter.MinPts)<10 & (DBSCAN_parameter.MinPts)~=0)>0
% saveas(f,[FigROOT '\DBSCAN\DBSCAN Summary(Epsilon,MinPt)\Filter-out\' RegionIndex_d  '\' cell2mat(inputCSVs.UnitID(n2)) '.jpg']);
filt=0;
else
    filt=1;
%     saveas(f,[FigROOT '\DBSCAN\DBSCAN Summary(Epsilon,MinPt)\Filter-in\' RegionIndex_d  '\' cell2mat(inputCSVs.UnitID(n2)) '.jpg']);
end
ClusterList_Eps.Filter(clRUN) = filt;
ClusterList_Eps.UnitID{clRUN} = clusterID;
ClusterList_Eps.ClusterNum(clRUN) = inputCSVs.ClustNum(clRUN);
ClusterList_Eps.Region{clRUN} = inputCSVs.Region(clRUN);

ClusterList_Eps.Epsilon1(clRUN) = DBSCAN_parameter.epsilon(1);
ClusterList_Eps.MinPts1(clRUN) = DBSCAN_parameter.MinPts(1);
if size(DBSCAN_parameter.epsilon)>1
ClusterList_Eps.Epsilon2(clRUN) = DBSCAN_parameter.epsilon(2);
ClusterList_Eps.MinPts2(clRUN) = DBSCAN_parameter.MinPts(2);
else
  ClusterList_Eps.Epsilon2(clRUN) =0;
  ClusterList_Eps.MinPts2(clRUN) =0;
end

ClusterList_Eps.Nspikes(clRUN) = inputCSVs.Nspikes(clRUN);
ClusterList_Eps.Sparsity(clRUN) = inputCSVs.Sparsity(clRUN);
%       end
  end
        
% saveImage(f,[FigROOT '\DBSCAN\DBSCAN Summary\Summary sheet\' RegionIndex_d Filt '\' clusterID '.jpg'],'pixels',imagePosition);
              close all

        end