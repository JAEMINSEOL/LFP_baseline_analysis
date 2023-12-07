RATLIST = {'232', '234', '295','415','561','313','425','454','471','487','553','562'};

for i = 1:size(TTQualTable,1)
SessionArray(i,1) = str2double(TTQualTable{i,1});
SessionArray(i,2) = str2double(TTQualTable{i,2});
if ~isempty(TTQualTable{i,5})
if strcmp(TTQualTable{i,5},'SUB')

        SessionArray(i,3)=1;
elseif strcmp(TTQualTable{i,5},'CA1')
        SessionArray(i,3)=2;   
elseif strncmp(TTQualTable{i,5},'CA3',3)
        SessionArray(i,3)=3;
else
        SessionArray(i,3)=0;
end
end

if ~isempty(TTQualTable{i,7})
    TTArray(i,1) =TTQualTable{i,4};
SpecArray(i,1) = TTQualTable{i,7};
SpecArray(i,2) = TTQualTable{i,9};
end
end
%%
TTRate_All =[]; t=1; TTRate_Best=[];
for ssRUN = 6:12
    if ssRUN==5 MaxSSNum = 6; elseif ssRUN>5 MaxSSNum = 4; else MaxSSNum=5; end
    thisRID = RATLIST{ssRUN};
    for ssnum_p = 1:MaxSSNum
        if and(ssnum_p>=5,ssRUN~=5) ssTYPE='AMB'; else ssTYPE='STD'; end
        if strcmp(thisRID,'232') ssnum=ssnum_p+3; elseif strcmp(thisRID,'415') ssnum = ssnum_p+9; else ssnum = ssnum_p; end
        if ssnum > 9 thisSID=num2str(ssnum); else thisSID = ['0' num2str(ssnum)]; end
        for RegionID = 1:3
            TTRate=[];
            id = find(and(and(SessionArray(:,1)==str2double(thisRID),SessionArray(:,2)==str2double(thisSID)),SessionArray(:,3)==RegionID));
            TTArray_c = TTArray(id,:);
            SpecArray_c = SpecArray(id,:);
            sz = round((length(id))/2); if sz==0 sz=1; end
            [y,idx] = mink(SpecArray(id,2),sz);
            TTRate(1:length(idx),1)=str2double(thisRID);
            TTRate(1:length(idx),2)=str2double(thisSID);
            TTRate(1:length(idx),3)=RegionID;
            TTRate(1:length(idx),4)=TTArray_c(idx);
            TTRate(1:length(idx),5)=SpecArray_c(idx,1);
            TTRate(1:length(idx),6)=SpecArray_c(idx,2);
            TTRate_All = vertcat(TTRate_All,TTRate);
            
            [y,idm] = maxk(TTRate(:,5),1);
            TTRate_Best = vertcat(TTRate_Best,TTRate(idm,:));
            t=t+1;
        end
    end
end