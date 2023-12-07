function [VMean] = Mean_Velocity_Trial_JM(DivID,this_velocity,this_t,trial_iter)
%% 
DivID_r(3:8,:) = (DivID(3:8,:) - DivID(2,:))/2000;
i =trial_iter;
    for j = 3:8
VMean(1,j)=nanmean(this_velocity(and(this_t<DivID_r(j,i),this_t>=DivID_r(j-1,i))));
    end
 1;