

if session_type==1, imagePosition = [200 100 1200 750];
elseif session_type==2, imagePosition = [200 100 1200 750]; end
set(groot,'defaultFigurePosition',imagePosition,'defaultFigureColor','white');
fontsize = 10;
   
    %% display condition sheet (STD)
f = figure;

flag_name = {'e','s','d','a','u'};
    ratemap_name_STD={'Overall','Zebra','Bamboo','Pebble','Mountain','Left','Right'};
    ratemap_name_AMB1={'Overall','Zebra,Normal','Zebra,30 Blr','Zebra,50 Blr','Pebbles,Normal','Pebbles,30 Blr','Pebbles,50 Blr','Left','Right'};
    ratemap_name_AMB2={'Overall','Bamboo,Normal','Bamboo,30 Blr','Bamboo,50 Blr','Mountain,50 Blr','Mountain,30 Blr','Mountain,Normal','Left','Right'};
   
    p_alpha = 0.05;

% title
subplot('position',[0.05 0.9 0.2 0.1]);
text(0, 0.65, ['rat' clusterID ' (' RegionIndex_d ')' ],'fontsize',12);
text(0, 0.25, sprintf('# of field: %d',nCluster),'fontsize',11);
%  text(0.4, 0.25, '', 'color', 'k');    
%      text(0.45, 0.25, 'Loc', 'color', 'k');
 text(0.46, 0.25,'IsoDist', 'color', 'k');
 text(0.65, 0.25,'L-Ratio', 'color','k');


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
    
    thisFieldMap{field_iter}.field_flag=array2table(1);
    text(0.4, 0.25-0.2*(field_iter), num2str(field_iter), 'color', ColorSet(field_iter,:));    
     text(0.45, 0.25-0.2*(field_iter), flag_name{table2array(thisFieldMap{field_iter}.field_flag)'==1}, 'color', ColorSet(field_iter,:));
 text(0.5, 0.25-0.2*(field_iter),sprintf('%.1f',Cluster_quality.IsolDist(field_iter)), 'color', ColorSet(field_iter,:));
 text(0.65, 0.25-0.2*(field_iter),sprintf('%.3f',Cluster_quality.Lratio(field_iter)), 'color', ColorSet(field_iter,:));
text(0.8, 0.25-0.2*(field_iter),ValStr, 'color', ColorSet(field_iter,:));
end
axis off;

%% display maps
switch session_type
    case 1 %STD
        
ratemap_number = 7;
for map_iter = 1 : ratemap_number
% map_iter = overallMap_index(session_type);
    onmazeAvgFR1D = nanmean(display_skaggs);
    temp_position = [0.06 0.7 0.18 0.14];
    if map_iter == 2 || map_iter == 3, temp_position = temp_position + [0.24*(map_iter-1) 0.1 0 0];
    elseif map_iter == 4 || map_iter == 5, temp_position = temp_position + [0.24*(map_iter-3) -0.4 0 0];
    elseif map_iter == 6, temp_position = temp_position + [0.24*3 0.1 0 0];
    elseif map_iter == 7, temp_position = temp_position + [0.24*3 -0.4 0 0];
    end
    
    % 1D rate map
    if map_iter <= 5, display_skaggs = skaggsMap1D{map_iter};
    elseif map_iter == 6, display_skaggs = skaggsMap_left1D;
    elseif map_iter == 7, display_skaggs = skaggsMap_right1D;
    end
    
    subplot('position',temp_position);
    hold on; box off;
    plot(display_skaggs, 'color', [.5 .5 .5]);
    plot([1 1]*stem_end_index, [0, max_rates * 1.1],':','color',[1 1 1]*0.2);
    if map_iter == 1, text(stem_end_index+0.5, max_rates*1.1, sprintf('%.2f hz',onmazeAvgFR1D(1)),'fontsize',9); end
    
    if map_iter == 1
        overall_map=[1:5];
        for field_iter = 1 : field_count
            temp_field = skaggsMap1D{overall_map};
            temp_field(temp_field < 0) = 0;
            
            plot(start_index(field_iter) : end_index(field_iter), temp_field(start_index(field_iter) : end_index(field_iter)), 'color', 'k', 'lineWidth', 1.5);
        end
    end
    
    for field_iter = 1 : nCluster
        if map_iter <= 5, field_skaggs = thisFieldMap{field_iter}.skaggsMap1D{map_iter};
        elseif map_iter == 6, field_skaggs = thisFieldMap{field_iter}.skaggsMap_left1D;
        elseif map_iter == 7, field_skaggs = thisFieldMap{field_iter}.skaggsMap_right1D;
        end
        
        field_skaggs(field_skaggs==0) = nan;
        plot(field_skaggs, '-', 'color', ColorSet(field_iter,:), 'linewidth', 1);
        
        % COM
%         if map_iter == 1, plot(thisFieldMap{field_iter}.COM(2),thisFieldMap{field_iter}.COM(4),'.','color',ColorSet(field_iter,:),'markersize',10); end        
    end
    
    set(gca,'XTick',[1 stem_end_index max_position], 'xticklabel', {},'tickdir','out'); %,'XTickLabel',{'startbox','divPnt','foodwell'},'tickdir','out');
    xlim([1 max_position]); ylim([0 max_rates*1.1]);
    if map_iter == 1, ylabel('Firing rates (Hz)'); end

    title(ratemap_name_STD{map_iter});
    
    % position-phase scatter plot
    if map_iter == 1
        display_phase_all = thisPHASE_backup.scene > 0;
        display_phase = thisPHASE.scene > 0;
    elseif sum(map_iter == 2:5)
        display_phase_all = thisPHASE_backup.scene == map_iter-1;
        display_phase = thisPHASE.scene == map_iter-1;
    elseif map_iter == 6
        display_phase_all = thisPHASE_backup.scene == 1 | thisPHASE_backup.scene == 2;
        display_phase = thisPHASE.scene == 1 | thisPHASE.scene == 2;
    elseif map_iter == 7
        display_phase_all = thisPHASE_backup.scene == 3 | thisPHASE_backup.scene == 4;
        display_phase = thisPHASE.scene == 3 | thisPHASE.scene == 4;
    end
    
    if map_iter == 1, temp_position=temp_position+[0 -0.05 0 0.05]; end
    subplot('position',temp_position+[0 -0.26 0 0.1]);    
    hold on;
    plot(thisPHASE_backup.linearized_pos(display_phase_all),thisPHASE_backup.phase(display_phase_all),'.','color',[1 1 1]*0.7,'markersize',3);
    plot([480-max_position*10 480],[0 0],':','color',[1 1 1]*0.2);
    
    for field_iter = 1 : nCluster
        thisField = thisPHASE(thisPHASE.cluster == field_iter & display_phase,:);
        plot(thisField.linearized_pos,thisField.phase,'.','color',ColorSet(field_iter,:),'markersize',4);
        
        if map_iter == 1
            x = linspace(0,max_position*10)';
            y = predict(thisFieldMap{field_iter}.linear_mdl,x);
            plot(x,y,'-','color',ColorSet(field_iter,:));
            CQual{nc-nCluster-1+field_iter,14} = thisFieldMap{field_iter}.linear_mdl.Coefficients.Estimate(2);
            CQual{nc-nCluster-1+field_iter,15} = thisFieldMap{field_iter}.linear_mdl.Rsquared.Ordinary;
            CQual{nc-nCluster-1+field_iter,16} = thisFieldMap{field_iter}.linear_mdl.Coefficients.pValue(2);
        end
        
    end
    
    set(gca,'xdir','rev','xtick',[480-max_position*10 DivPt 480],'xticklabel',{'0','DivPnt','480'});
%     set(gca,'xdir','rev','xtick',[480-max_position*10 diverging_point max_position*10],'xticklabel',{'FdWell','DivPnt','StBox'});
    set(gca,'ytick',-180 : 90 : 540,'tickdir','out','fontsize',8);
    xlim([480-max_position*10 480]); %xlim([480-max_position*10 max_position*10]);
    if ~isempty(thisPHASE),ylim([(floor(min(thisPHASE.phase)/90)-1)*90 (floor(min(thisPHASE.phase)/90)-1)*90+720]);
    else, ylim([-180 540]);
    end
    %     ylim([floor(min(thisField.phase)/90)*90 floor(min(thisField.phase)/90)*90+720]); %ylim([1 1]*floor(precession_range(1)/90)*90+[0 360]);
    if map_iter == 1, xlabel('linearized position','fontsize',9); ylabel('theta phase (degree)','fontsize',9); end
    
end



%% Calculate RDI(약식)
% clear field_skaggs_all
% for map_iter = 1:7
%  for field_iter = 1 : nCluster
%         if map_iter <= 5, field_skaggs = thisFieldMap{field_iter}.skaggsMap1D{map_iter};
%         elseif map_iter == 6, field_skaggs = thisFieldMap{field_iter}.skaggsMap_left1D;
%         elseif map_iter == 7, field_skaggs = thisFieldMap{field_iter}.skaggsMap_right1D;
%         end
% field_skaggs(field_skaggs==0) = nan;
% field_skaggs_all{field_iter,map_iter} = field_skaggs;
% 
%  end
% end
% 
% for field_iter=1:nCluster
% for d_iter=1:3
%     x = field_skaggs_all{field_iter,2*d_iter}; y = field_skaggs_all{field_iter,2*d_iter+1};
%     RDI.d(field_iter,d_iter) = abs(computeCohen_d(x,y,'independent'));
% %     RDI.d(f,d) = abs((nanmean(x)-nanmean(y)))/nanstd(vertcat(x,y));
% x(isnan(x))=[]; y(isnan(y))=[];
%     [h,p] = ttest2(x,y);
%     RDI.p(field_iter,d_iter) = p;
% end
% end

%% RDI bar graph
if nCluster == 1
    RDI.d(2,:) = [nan nan nan]; 
    RDI.d_shuffled(2,:) = [nan nan nan]; 
end

RDI_max = max(abs(RDI.d(:)));
if RDI_max < 1, RDI_max = 1; end

if ~isempty(RDI_max)
    temp_position = [0.06 0.05 0.18 0.25];
    subplot('position',temp_position);
    h(1:3) = bar(RDI.d,'grouped');
    box off; hold on;
    % 95% percentile of shuffled RDI
%     bar(RDI.d_shuffled,'grouped','facealpha',0);
    
    set(gca,'tickdir','out');
    ylim([-RDI_max*1.1 RDI_max*1.1]);
    xlabel('field#'); ylabel('RDI (cohens d)');



    legend(h(1:3),'scene-left','scene-right','side','location','northoutside');
    
    for field_iter = 1 : nCluster
        for d_iter = 1 : 3
            % 2-sample t-test p-value
            if RDI.p(field_iter,d_iter) <= p_alpha
                text(field_iter+0.23*(d_iter-2), RDI.d(field_iter,d_iter)*1.1,'*','fontsize',15,'HorizontalAlignment','center');
            end
        end
    end
            
end
    case 2
             
ratemap_number = 9;
for map_iter = 1 : ratemap_number
% map_iter = overallMap_index(session_type);
    onmazeAvgFR1D = nanmean(display_skaggs);
    temp_position = [0.06 0.7 0.17 0.14];
     if map_iter == 2 || map_iter == 3 || map_iter == 4, temp_position = temp_position + [0.19*(map_iter-1) 0.1 0 0];
    elseif map_iter == 5 || map_iter == 6 || map_iter == 7, temp_position = temp_position + [0.19*(map_iter-4) -0.4 0 0];
    elseif map_iter == 8, temp_position = temp_position + [0.19*4 0.1 0 0];
    elseif map_iter == 9, temp_position = temp_position + [0.19*4 -0.4 0 0];
    end
    
    % 1D rate map
    if map_iter ==1, display_skaggs = skaggsMap1D{10};
    elseif map_iter <= 7, display_skaggs = skaggsMap1D{map_iter+2};
    elseif map_iter == 8, display_skaggs = skaggsMap_left1D;
    elseif map_iter == 9, display_skaggs = skaggsMap_right1D;
    end
    
    subplot('position',temp_position);
    hold on; box off;
    plot(display_skaggs, 'color', [.5 .5 .5]);
    plot([1 1]*stem_end_index, [0, max_rates * 1.1],':','color',[1 1 1]*0.2);
    if map_iter == 1, text(stem_end_index+0.5, max_rates*1.1, sprintf('%.2f hz',onmazeAvgFR1D(1)),'fontsize',9); end
    
    if map_iter == 1
        overall_map=[1:5];
        for field_iter = 1 : field_count
            temp_field = skaggsMap1D{overall_map};
            temp_field(temp_field < 0) = 0;
            
            plot(start_index(field_iter) : end_index(field_iter), temp_field(start_index(field_iter) : end_index(field_iter)), 'color', 'k', 'lineWidth', 1.5);
        end
    end
    
    for field_iter = 1 : nCluster
         if map_iter ==1, field_skaggs = thisFieldMap{field_iter}.skaggsMap1D{10};
         elseif map_iter <= 7, field_skaggs = thisFieldMap{field_iter}.skaggsMap1D{map_iter+2};
        elseif map_iter == 8, field_skaggs = thisFieldMap{field_iter}.skaggsMap_left1D;
        elseif map_iter == 9, field_skaggs = thisFieldMap{field_iter}.skaggsMap_right1D;
        end
        
        field_skaggs(field_skaggs==0) = nan;
        plot(field_skaggs, '-', 'color', ColorSet(field_iter,:), 'linewidth', 1);
        
        % COM
%         if map_iter == 1, plot(thisFieldMap{field_iter}.COM(2),thisFieldMap{field_iter}.COM(4),'.','color',ColorSet(field_iter,:),'markersize',10); end        
    end
    
    set(gca,'XTick',[1 stem_end_index max_position], 'xticklabel', {},'tickdir','out'); %,'XTickLabel',{'startbox','divPnt','foodwell'},'tickdir','out');
    xlim([1 max_position]); ylim([0 max_rates*1.1]);
    if map_iter == 1, ylabel('Firing rates (Hz)'); end
if session_type_old==2
    title(ratemap_name_AMB1{map_iter});
else
    title(ratemap_name_AMB2{map_iter});
end
    % position-phase scatter plot
    if map_iter == 1
        display_phase_all = thisPHASE_backup.scene > 0;
        display_phase = thisPHASE.scene > 0;
    elseif sum(map_iter == 2:4)
        display_phase_all = thisPHASE_backup.scene == map_iter-1;
        display_phase = thisPHASE.scene == map_iter-1;
    elseif sum(map_iter == 5:7)
        display_phase_all = thisPHASE_backup.scene == 11-map_iter;
        display_phase = thisPHASE.scene == 11-map_iter;
    elseif map_iter == 8
        display_phase_all = thisPHASE_backup.scene <= 3 ;
        display_phase = thisPHASE.scene <= 3 ;
    elseif map_iter == 9
        display_phase_all = thisPHASE_backup.scene >= 4 ;
        display_phase = thisPHASE.scene >= 4 ;
    end
    
    if map_iter == 1, temp_position=temp_position+[0 -0.05 0 0.05]; end
    subplot('position',temp_position+[0 -0.26 0 0.1]);    
    hold on;
    plot(thisPHASE_backup.linearized_pos(display_phase_all),thisPHASE_backup.phase(display_phase_all),'.','color',[1 1 1]*0.7,'markersize',3);
    plot([480-max_position*10 480],[0 0],':','color',[1 1 1]*0.2);
    
    for field_iter = 1 : nCluster
        thisField = thisPHASE(thisPHASE.cluster == field_iter & display_phase,:);
        plot(thisField.linearized_pos,thisField.phase,'.','color',ColorSet(field_iter,:),'markersize',4);
        
        if map_iter == 1
            x = linspace(0,max_position*10)';
            y = predict(thisFieldMap{field_iter}.linear_mdl,x);
            plot(x,y,'-','color',ColorSet(field_iter,:));
            CQual{nc-nCluster-1+field_iter,14} = thisFieldMap{field_iter}.linear_mdl.Coefficients.Estimate(2);
            CQual{nc-nCluster-1+field_iter,15} = thisFieldMap{field_iter}.linear_mdl.Rsquared.Ordinary;
            CQual{nc-nCluster-1+field_iter,16} = thisFieldMap{field_iter}.linear_mdl.Coefficients.pValue(2);
        end
    end
    
    set(gca,'xdir','rev','xtick',[480-max_position*10 DivPt 480],'xticklabel',{'0','DivPnt','480'});
%     set(gca,'xdir','rev','xtick',[480-max_position*10 diverging_point max_position*10],'xticklabel',{'FdWell','DivPnt','StBox'});
    set(gca,'ytick',-180 : 90 : 540,'tickdir','out','fontsize',8);
    xlim([480-max_position*10 480]); %xlim([480-max_position*10 max_position*10]);
    if ~isempty(thisPHASE),ylim([(floor(min(thisPHASE.phase)/90)-1)*90 (floor(min(thisPHASE.phase)/90)-1)*90+720]);
    else, ylim([-180 540]);
    end
    %     ylim([floor(min(thisField.phase)/90)*90 floor(min(thisField.phase)/90)*90+720]); %ylim([1 1]*floor(precession_range(1)/90)*90+[0 360]);
    if map_iter == 1, xlabel('linearized position','fontsize',9); ylabel('theta phase (degree)','fontsize',9); end
    
end
%% record cluster quality
% temp_position = [0.06 0.23 0.18 0.1];
% subplot('position',temp_position);
% axis off;
% 
% txt_x = 0; txt_y = 0.6;
% 
% for field_iter = 1 : nCluster    
%     text(txt_x+(field_iter-1)*0.2,txt_y,sprintf('%.1f',Cluster_quality.IsolDist(field_iter)), 'color', ColorSet(field_iter,:));
%     text(txt_x+(field_iter-1)*0.2,txt_y-0.4,sprintf('%.3f',Cluster_quality.Lratio(field_iter)), 'color', ColorSet(field_iter,:));
% end
%% FR line graph
if nCluster == 1
    RDI.m(2,:) = [nan nan nan nan nan nan]; 
    RDI.sd(2,:) = [nan nan nan nan nan nan]; 
end


RDI.m2(:,1) = nanmean(RDI.m(:,1:5:6),2);
RDI.m2(:,2) = nanmean(RDI.m(:,2:3:5),2);
RDI.m2(:,3) = nanmean(RDI.m(:,3:4),2);

RDI.sd2(:,1) = nanmean(RDI.sd(:,1:5:6),2);
RDI.sd2(:,2) = nanmean(RDI.sd(:,2:3:5),2);
RDI.sd2(:,3) = nanmean(RDI.sd(:,3:4),2);

RDI_max = max(RDI.m2(:)+RDI.sd2(:));
if RDI_max < 1, RDI_max = 1; end

if ~isempty(RDI_max)
    for nc2=1:nCluster
        temp_position = [0.06 0.05 0.16 0.10];
        subplot('position',temp_position);
        
        
        errorbar(RDI.m2(nc2,1:3),RDI.sd2(nc2,1:3),'k','LineWidth',0.5);
        hold on
        plot(RDI.m2(nc2,1:3),'Color',ColorSet(nc2,:),'Marker','o','LineWidth',1.5,'MarkerSize',5,'MarkerFaceColor',ColorSet(nc2,:));
    end
    hold off;
    % 95% percentile of shuffled RDI
%     bar(RDI.d_shuffled,'grouped','facealpha',0);
    
    set(gca,'tickdir','out');
    ylim([0 RDI_max*1.1]); xlim([0.5 3.5])
    xlabel('AMB'); ylabel('firing rate');
    xticks([1 2 3])
    xticklabels({'Normal','30% Blur','50% Blur'})
%     legend(h(1:3),'scene-left','scene-right','side','location','southoutside');

temp_position = [0.06 0.18 0.16 0.14];
    subplot('position',temp_position);
b=bar(RDI.d(:,4),'grouped','FaceColor','flat');    
for k = 1:size(abs(RDI.d(:,4)),1)
    b.CData(k,:) = ColorSet(k,:);
end
set(gca,'tickdir','out');
if min(RDI.d(:,4))<0
    ylim([-max(abs(RDI.d(:,4)))*1.1 max(abs(RDI.d(:,4)))*1.1]);
else
    ylim([0 max(abs(RDI.d(:,4)))*1.1]);
end
    ylabel('RDI (cohens d)');
    xticks([1])
    xticklabels({'L-R'})

%     for field_iter = 1 : nCluster
%         for d_iter = 1 : 3
%             % 2-sample t-test p-value
%             if RDI.p(field_iter,d_iter) <= p_alpha
%                 text(field_iter+0.23*(d_iter-2), RDI.d(field_iter,d_iter)*1.1,'*','fontsize',15,'HorizontalAlignment','center');
%             end
%         end
%     end

%             
end
end


%%

saveImage(f,[FigROOT '\DBSCAN\DBSCAN Summary\Condition sheet\' RegionIndex_d Filt '\' clusterID '.jpg'],'pixels',imagePosition);
