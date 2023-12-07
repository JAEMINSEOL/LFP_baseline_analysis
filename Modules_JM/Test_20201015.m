 id= knnsearch(PHASE_mat.ts,t_spk);
area_apk = double(area_spk);
area_apk(:,6) = PHASE_mat.area(id);
area_apk(:,7) = PHASE_mat.linearized_pos(id);
area_apk(:,8) = x_spk;
area_apk(:,9) = y_spk;

c = jet(max(area_apk(:,6))+1);

scatter(area_apk(:,8),area_apk(:,9),3,c(area_apk(:,7),:))
axis ij

scatter3(area_apk(:,8),area_apk(:,9),area_apk(:,7),3,c(area_apk(:,6)+1,:),'filled')

j=1; k=2; fd=[]; st=[]; st(1)=PHASE_mat.ts(1);
for i=2:length(PHASE_mat.area)
    if PHASE_mat.area(i)==6 && PHASE_mat.area(i-1)==5
        fd(j)=PHASE_mat.ts(i-1);
        j=j+1;
    end
    
    if PHASE_mat.area(i)==1 && PHASE_mat.area(i-1)==0
        st(k)=PHASE_mat.ts(i-1);
        k=k+1;
    end
    
end

fd_t = knnsearch(t,fd');
st_t = knnsearch(t,st');

id =knnsearch(PHASE_mat.ts,t_spk);
temp(:,1) = PHASE_mat.area(id);
temp(:,2) = PHASE_mat.linearized_pos(id);
temp(:,3) = x_spk; temp(:,4) = y_spk;
temp(:,4) = PHASE_mat.trial(id);

id = find(temp(:,1)==5);
scatter(temp(id,3),temp(id,4),3,'k')

temp2 = [id,temp(id,1),temp(id,3),temp(id,4)];
ans(id,4) = 0; find(temp(id,4)>220)=1;


area_temp=zeros(length(area),1);
for i=100000:length(area)
    if max(area(i,:))==0
        area_temp(i)=0;
    else
    area_temp(i,1) = find(area(i,:)');
    end
end


figure;
c=hsv(5);
for i=1:4
    id = find(area(:,i)); 
    scatter(x(id),y(id),3,c(i,:),'filled')
    hold on
end
axis ij
xlim([200 500])
xlabel('rat 471 X pos'); ylabel('rat 471 Y pos'); 
legend({'area 1', 'area 2','area 3' ,'area 4','area 5'},'location','southwest')
















