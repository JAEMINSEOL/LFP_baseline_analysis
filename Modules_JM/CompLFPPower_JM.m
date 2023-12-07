function TTBox = CompLFPPower_JM(SelectedTT,RATLIST)
id_Region(:,1) = (SelectedTT(:,4)==1); id_Region(:,2) = (SelectedTT(:,4)==2); id_Region(:,3) = (SelectedTT(:,4)==3); id_Region(:,4) = (SelectedTT(:,4)==4); 
id_Session(:,1) = (SelectedTT(:,3)==1); id_Session(:,2) = (SelectedTT(:,3)==2);
for i = 1:size(RATLIST,2)
id_Rat(:,i) = (SelectedTT(:,1)==str2double(RATLIST(i)));
end

TTBox.Region = NaN(size(SelectedTT,1),4);
TTBox.Region(1:sum(id_Region(:,1)),1)= SelectedTT(id_Region(:,1),9);
TTBox.Region(1:sum(id_Region(:,2)),2)= SelectedTT(id_Region(:,2),9);
TTBox.Region(1:sum(id_Region(:,3)),3)= SelectedTT(id_Region(:,3),9);
TTBox.Region(1:sum(id_Region(:,4)),4)= SelectedTT(id_Region(:,4),9);


% [h,p]  = ttest2(TTBox(:,1),TTBox(:,2),'Vartype','unequal');
% text(1.5,2,['p=' num2str(p)])
% [h,p]  = ttest2(TTBox(:,2),TTBox(:,3),'Vartype','unequal');
% text(2.5,2,['p=' num2str(p)])

TTBox.Session = NaN(size(SelectedTT,1),2);
TTBox.Session(1:sum(id_Session(:,1)),1)= SelectedTT(id_Session(:,1),9);
TTBox.Session(1:sum(id_Session(:,2)),2)= SelectedTT(id_Session(:,2),9);

% [h,p]  = ttest2(TTBox(:,1),TTBox(:,2),'Vartype','unequal');
% text(1.5,2,['p=' num2str(p)])


TTBox.Rat = NaN(size(SelectedTT,1),size(RATLIST,2));
for i = 1:size(RATLIST,2)
TTBox.Rat(1:sum(id_Rat(:,i)),i)= SelectedTT(id_Rat(:,i),9);
end



end