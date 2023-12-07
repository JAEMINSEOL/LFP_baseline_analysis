function Selected = DrawNorLFPScatter_JM(PMean, thisRID, thisSID,TTNum,IdxVoid,Color_Array,DrawPlot)
if DrawPlot~=0
    f = figure('Position',[700 400 900 600]);
end

for k=1:size(PMean,3)
    if isempty(find(TTNum(:,3)==k))
        if DrawPlot~=0
            scatter(ones(1,size(PMean,1))*k,PMean(:,1,k)/mean(PMean(:,end,k)),25,'k','filled')
        end
    else
        regionIndex = TTNum(find(TTNum(:,3)==k),2);
        switch regionIndex
            case 1
                DrawScatter(ones(1,size(PMean,1))*k,PMean(:,1,k)/mean(PMean(:,end,k)),Color_Array(1),DrawPlot)
                Selected(:,1)= PMean(:,1,k)/mean(PMean(:,end,k));
            case 2
                DrawScatter(ones(1,size(PMean,1))*k,PMean(:,1,k)/mean(PMean(:,end,k)),Color_Array(2),DrawPlot)
                Selected(:,2)= PMean(:,1,k)/mean(PMean(:,end,k));
            case 3
                DrawScatter(ones(1,size(PMean,1))*k,PMean(:,1,k)/mean(PMean(:,end,k)),Color_Array(3),DrawPlot)
                Selected(:,3)= PMean(:,1,k)/mean(PMean(:,end,k));
            case 4
                DrawScatter(ones(1,size(PMean,1))*k,PMean(:,1,k)/mean(PMean(:,end,k)),Color_Array(4),DrawPlot)
                Selected(:,4)= PMean(:,1,k)/mean(PMean(:,end,k));
            otherwise
                DrawScatter(ones(1,size(PMean,1))*k,PMean(:,1,k)/mean(PMean(:,end,k)),'b',DrawPlot)
                %                 Selected(:,5)= PMean(:,1,i)/mean(PMean(:,end,i));
        end
        if ~isempty(IdxVoid)
            DrawScatter(ones(1,size(IdxVoid,1))*k,PMean(IdxVoid,1,k)/mean(PMean(:,end,k)),'r',DrawPlot)
            Selected(1:size(IdxVoid,1),5)= PMean(IdxVoid,1,k)/mean(PMean(:,end,k));
        end
        
    end
    if DrawPlot~=0
    hold on
    end
end

crit = mean(Selected,'all')+5*nanstd(Selected,0,'all');
% Selected(Selected>crit)=0;

if DrawPlot~=0
    
    xlim([1 24])
    xticks([1:1:24])
    xlabel('Tetrode No.')
    ylim([0.1 20])
    ylabel('Normalized Power, Baseline = Inbound Power Mean')
    title([thisRID '-' thisSID ' Normalized Power of Each Trials']);
    saveImage(f,[thisRID '_' thisSID '_LFPNormPowerScatter.jpg'] ,'pixels',[700 400 900 600]);
end

    function DrawScatter(x,y,color,index)
        if index~=0
            scatter(x,y,25,color,'filled')
        end
    end
end