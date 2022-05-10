
Initial_LFP;
warning off

SessionList = readtable([ROOT.Info '\SessionList.xlsx'],'ReadRowNames',false);
Experimenter = {'JS'};

for sid=1:size(SessionList,1)
    if ismember(SessionList.experimenter(sid),Experimenter)
        for tid = 1:24
            thisRID = jmnum2str(SessionList.rat(sid),3);
            thisSID = jmnum2str(SessionList.session(sid),2);
            thisTTID = num2str(tid);
            ROOT.Save = [ROOT.Raw.Mother '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' thisTTID];
            if ~exist(ROOT.Save), continue; end
            cd(ROOT.Save)
            
            fd = dir(ROOT.Save);
            for fid = 1: size(fd,1)
                winID = fd(fid).name;
                findDOT = find(winID == '.');
                if isempty(findDOT), continue; end
                thisCLID = winID(1, findDOT(end) + 1:end);
                oldName = ['T' thisTTID '.' thisCLID];
                if ~(str2double(thisCLID)>0 && strcmp(winID, oldName)), continue; end
                
                newName = ['TT' thisTTID '_cluster.' thisCLID];
                status = copyfile(oldName, newName);
                
                ss3dID = [thisRID '-' thisSID '-' thisTTID '-' thisCLID];
                
                cl2Ntt(ROOT.Raw.Mother, ss3dID, ss3dID)
                
                disp([thisRID '-' thisSID '-' thisTTID '-' thisCLID ' is finished'])
            end
        end
    end
end
