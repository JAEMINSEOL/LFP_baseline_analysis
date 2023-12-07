function NormalizedLFPScatter_JM(SelectedTTScatter,Color_Array, FigSize)
%%
fig = figure('Position', FigSize); 
YMax = 40;

t=0;
N = fieldnames(SelectedTTScatter);
for i = 1:numel(fieldnames(SelectedTTScatter))
s = GetFieldByIndex(SelectedTTScatter, i);
A=nan(1,4);

if i>1
    if ~strcmp(extractBefore(N{i},'_'),extractBefore(N{i-1},'_'))
        line([t+0.5 t+0.5], [0 YMax],'Color','k','LineWidth',2)
    end
end

for j = 1:5
    
    if size(s,2)>=j
    if max(s(:,j))~=0
        if j~=5
        t=t+1;
        
            scatter(ones(size(s,1),1)*t,s(:,j),20,hex2rgb(Color_Array(j)),'filled')
        else
            scatter(ones(size(s,1),1)*t,s(:,j),20,'r','filled')
        end
    hold on
    A(j)=t;

    end
    end
end
m(i) = nanmedian(A);
line([t+0.5 t+0.5], [0 YMax],'Color','k')

end

row1 = {'','','232','','','','','234','','','','','295','','','','','415','','','','','561','','','','',...
    '','313','','','','425','','','','454','','','','471','','','','487','','','','553','','','','562',''};
XLabelArray = [extractAfter(N,'_')'; row1]; 
tickLabels = strtrim(sprintf('%s\\newline%s\n', XLabelArray{:}));

xticks(m); xticklabels(tickLabels)
  ylim([0.1 40]); 
ylabel('Normalized Power, Baseline = Inbound Power Mean')
set(gca,'TickLength',[0 0])

for j=1:4
L(j) = scatter(nan, nan, 20,hex2rgb(Color_Array(j)),'filled');
end
legend(L, {'SUB', 'CA1','CA3','CA3(DG lesion)'},'Location','northoutside')
saveImage(fig,'NormLFP_Power_Selected TT.jpg','pixels',FigSize)
end
