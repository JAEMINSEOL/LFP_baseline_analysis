%% display position - speed - spike phase for one trial

% set default figure paramters
imagePosition = [100 100 350 600];
set(groot,'defaultFigurePosition',imagePosition);
t_range = [0 ceil(max(this_t)*10)/10+0.1];

%% display
% f = figure;
f.Color = 'white';

% subplot('position',[0.15 0.08 0.8 0.3]);
% hold on; grid on;
% plot(this_spk_rep.aligned_ts,this_spk_rep.phase,'k.');
% plot(this_spk_rep.aligned_ts(filtered_spk),this_spk_rep.phase(filtered_spk),'.','color',[1 1 1]*0.7);
% xlim(t_range); ylim([-180 180*3]);
% xlabel('time (sec)'); ylabel('Theta phase (degree)');
% set(gca,'xtick',0:0.5:t_range(2),'ytick',-180:180:180*3);
% for epoch_iter = 1 : size(this_stop_epoch,1)
%     patch_x = this_stop_epoch(epoch_iter,:); patch_x = [patch_x fliplr(patch_x)];
%     patch_y = [-180 -180 180*3 180*3];
%     patch(patch_x,patch_y,'k','facealpha',0.1,'facecolor','k','edgealpha',0);
% end

subplot('position',[0.15 0.41 0.8 0.22]);
hold on; box on; grid on;
plot(this_t,this_velocity,'k-');
plot([0 max(this_t)],[threshold threshold],'r:');
xlim(t_range); ylim([0 max(this_velocity)*1.1]);
ylabel('1D velocity (cm/s)');
set(gca,'xtick',0:0.5:t_range(2));
for epoch_iter = 1 : size(this_stop_epoch,1)
    patch_x = this_stop_epoch(epoch_iter,:); patch_x = [patch_x fliplr(patch_x)];
    patch_y = [0 0 max(this_velocity)*1.1 max(this_velocity)*1.1];
    patch(patch_x,patch_y,'k','facealpha',0.1,'facecolor','k','edgealpha',0);
end

subplot('position',[0.15 0.66 0.8 0.25]);
hold on; grid on;
plot(this_t,this_pos,'k.');
xlim(t_range); ylim([min(y_linearized) 500]);
ylabel('linearized position');
set(gca,'xtick',0:0.5:t_range(2));
for epoch_iter = 1 : size(this_stop_epoch,1)
    patch_x = this_stop_epoch(epoch_iter,:); patch_x = [patch_x fliplr(patch_x)];
    patch_y = [0 0 500 500];
    patch(patch_x,patch_y,'k','facealpha',0.1,'facecolor','k','edgealpha',0);
end

subplot('position',[0.15 0.95 0.8 0.05]);
axis off;
text(0,0.3,[clusterID ' trial#' num2str(trial_iter)],'fontsize',12);