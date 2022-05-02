Initial_LFP;
warning off

ROOT.Fig = [ROOT.Save '\Plots\PSD'];
SessionList = readtable([ROOT.Info '\SessionList.xlsx'],'ReadRowNames',false);
Recording_region = readtable([ROOT.Info '\Recording_region.csv'],'ReadRowNames',true);
Experimenter = {'JS'};
Regions = {'CA1', 'CA3', 'DG','V2L'};
Clrs = {'b','r','g','y'};
sz=40;

PowerTable_Theta = readtable([ROOT.Save '\Tables\PowerTable_theta.xlsx']);
PowerTable_Gamma = readtable([ROOT.Save '\Tables\PowerTable_gamma.xlsx']);
figure;
hold on
for sid=1:size(SessionList,1)

    if ismember(SessionList.experimenter(sid),Experimenter) & strcmp(SessionList.type(sid),'fog')

            thisRID = jmnum2str(SessionList.rat(sid),3);
            thisSID = jmnum2str(SessionList.session(sid),2);
            ID = [jmnum2str(SessionList.rat(sid),3) '-' jmnum2str(SessionList.session(sid),2)];   
            id = find(strcmp(ID,PowerTable_Theta.ID));
            
            for tt=1:24
                if strncmp(Recording_region.(['TT' num2str(tt)])(ID),'CA3',3)&&length(Recording_region.(['TT' num2str(tt)]){ID})<6
                    reg='CA3'; else, reg = Recording_region.(['TT' num2str(tt)]){ID}; end
                if ismember(reg,Regions)
                    c=Clrs{find(strcmp(reg,Regions))};
                    scatter(PowerTable_Theta.(['TT' num2str(tt)])(id),PowerTable_Gamma.(['TT' num2str(tt)])(id),...
                        sz,c,'filled','MarkerFaceAlpha',0.7,'MarkerEdgeColor','k')
                end
            end
    end
end

xlim([0 50])
ylim([0 25])
xlabel('Theta Power (Db/Hz)')
ylabel('Gamma Power (Db/Hz)')
                    
                    
            