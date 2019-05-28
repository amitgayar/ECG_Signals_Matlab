%function [ecg_struct] = LOAD()
% ==========data structuring for machine learning=================
number = (1:20);
fileno = string(number);
AA = [];
SS = [];
a=[];



for filecount=1:18
    iteration = filecount   
    if filecount < 11
          file = strcat('result/ivmd/res_normal',fileno(filecount),'.mat');
          A = load(file);
          AA = cat(1,AA, A.Props);
    end                                                                                                        
	
    file = strcat('result//ivmd/res_stress',fileno(filecount),'.mat');
	S = load(file);
    %SN = isnan(S.Props);
%     SN = sum(SN,2);
    %for j=1:length(S.Props(:,1))
        %if SN(j,1) ==0
        SS = cat(1, SS, S.Props);
       % end
    %end
end

La = length(AA(:,1));
Ls = length(SS(:,1));

la6 = floor(0.6*La);
la8 = floor(0.8*La);
ls6 = floor(0.6*Ls);
ls8 = floor(0.8*Ls);

%========================creating ecg_struct=======================
div = la8-la6;
divS = ls8-ls6;
ecg.Learning.Features = cat(1, AA(1:la6,:), SS(1:ls6,:));
ecg.Learning.Labels = cat(1,2*ones(la6,1),4*ones(ls6,1));
ecg.Validation.Features = cat(1, AA(la6+1:la8,:), SS(ls6+1:ls8,:));
ecg.Validation.Labels = cat(1,2*ones(div,1),4*ones(divS,1));
ecg.Testing.Features = cat(1, AA(1+la8:end,:), SS(1+ls8:end,:));
ecg.Testing.Labels = cat(1,2*ones(floor(0.2*La),1),4*ones(floor(0.2*Ls),1));


ecg_struct = ecg;
save('load.mat');

%end