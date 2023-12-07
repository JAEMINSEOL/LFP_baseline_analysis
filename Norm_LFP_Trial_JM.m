function [PMean] = Norm_LFP_Trial_JM(LFPData,DivID,params)
%% 
for i = 1:size(LFPData,2)
    if max(LFPData(:,i))~=0 
[S.EV1,f] = mtspectrumc(LFPData(DivID(2,i)-DivID(1,i)+1:DivID(7,i)-DivID(1,i)+1,i), params);


PMean(i,1) = trapz(linspace(min(f),max(f),length(f)),S.EV1);
for j = 2:7
    data = LFPData(DivID(j-1,i)-DivID(1,i)+1:DivID(j,i)-DivID(1,i)+1,i);
    if size(data,1)/2 > params.tapers(1)
[S.(['EV' num2str(j)]),f] =  mtspectrumc(data, params);
if length(f)>1
PMean(i,j) = trapz(linspace(min(f),max(f),length(f)),S.(['EV' num2str(j)]));
end
    end
end

[Sb,f] =  mtspectrumc(LFPData(DivID(7,i)-DivID(1,i)+1:DivID(8,i)-DivID(1,i)+1,i), params);
PMean(i,8) = trapz(linspace(min(f),max(f),length(f)),Sb);
    end

end