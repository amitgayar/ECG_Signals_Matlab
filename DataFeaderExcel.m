
%clear all;
close all;
clc;


%=============Parameters for VMD ======================================================

alpha = 2000;        % moderate bandwidth constraint
tau = 0;            % noise-tolerance (no strict fidelity enforcement)
K = 3;              % 3 modes
DC = 0;             % no DC part imposed
init = 1;           % initialize omegas uniformly
tol = 1e-7;
%===================File name structure============================================================
list.d = ["normal/ecg_n","stressed/ecg_s"];
list.r = ["res_normal","res_stress"];



for jj = 1:2   %.........2 iterations for normal and stressed signals
    if jj==1
        vmd = input('enter 0 for VMD or 1 for IVMD with dynamic windowing\n');
        prompt = 'Enter 1 for normal signals\n      2 for stressed signals\n      3 for both signals\n';
        x = input(prompt);
        y = x;
        switch x
                case 3
                      x = 1;
                otherwise
                    continue
        end
    end
    
    
%=================== ECG Data Acquisition =================================
ProjectPath = pwd;
number = (1:20);
fileno = string(number);
filemax=input('\n Enter number of files to process:\n');
for filecount=1:filemax   %......max number of files
    Props = zeros(1000:12);
    ECGPath = strcat(ProjectPath,'/database_ecg/',list.d(x),fileno(filecount),'.txt');
    
    if ~isfile(ECGPath) 
         break
    end
    
  
    fpt_1 = fopen(ECGPath,'r');  
    A = fscanf(fpt_1,'%g');     %------reading the signal
    No_of_Data = length(A);
    fclose(fpt_1);
    L = length(A);
             %......segment of file to be processed 3600
    T = L;         
    fs = 1/T;



temp = [];
row=1;
Window_Size = 1000;    %------------------------------------------Window_Size 
Fs = 200;              %----------------------------------------sampling freq

%=================choosing improved VMD======================
if vmd
    [K] = IVMD(A, alpha, tau, DC, init, tol);
    [u, ~] = dyvmd(A, alpha, tau, K, DC, init, tol);
    u_combined = u;
    ResultFile = strcat('result/ivmd/text/',list.r(x),fileno(filecount),'.csv');
    ResultMat = strcat('result/ivmd/',list.r(x),fileno(filecount),'.mat');
else
    [u, u_hat, omega] = VMD(A, alpha, tau, K, DC, init, tol);
    u_combined = sum(u)';
    ResultFile = strcat('result/vmd/text/',list.r(x),fileno(filecount),'.csv');
    ResultMat = strcat('result/vmd/',list.r(x),fileno(filecount),'.mat');
end

%============DyVMD Noise removal======================
%=====================Window Fragmentation======================================
for t=1:Window_Size:T-Window_Size   
    temp = u_combined(t:t+Window_Size-1,1);        
      
    
   
    
       
    %==================RR intervals calculation=============
    [qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(temp,Fs,0);
    RR = diff(qrs_i_raw)/Fs; %...........calc?
    
    %==============extracting stats =================
    [Entropy, Energy, Power, StdDev, Mean, DominantFreq, Cov] = feat(temp, Fs);
    featv = [Entropy, Energy, Power, StdDev, Mean, DominantFreq, Cov];
    [hrv_pNN50 ,TRI, rmssd, NNx] = stats(RR);
    statv = [hrv_pNN50 ,TRI ,rmssd, NNx];
     
    %====================================================
    
    feath = [featv,statv];
    %=================================================
    Props = cat(1,Props,feath);
    
    
end


save(ResultMat ,'Props');
heading = ["Entropy","Energy","Power","StdDev","Mean","DomFreq","Cov","pNN50","TRI","RMSSD","NN50"];
excel = cat(1,heading,Props);
kkl = num2cell(excel);
kkl = cell2table(kkl);
writetable(kkl,ResultFile);
end
    if y==1 || y==2
        break;
    end
    x = 2;
end
