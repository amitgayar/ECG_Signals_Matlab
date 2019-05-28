
%clear all;
close all;
clc;

%============indices for variables representing extracted features============= 
DISP_ECG_COUNT = 600;
ENT=1;
ENERGY = 2;
POWER=3;
SD = 4;
MEAN = 5;
Covariance = 6;
DOMFREQ=7;
pNN50 = 8;
hrv_tri = 9;
RR_rmssd = 10;
NN50 = 11;
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
    ResultFile = strcat(ProjectPath,'/result/ivmd/text/',list.r(x),fileno(filecount),'.txt');
    ResultMat = strcat(ProjectPath,'/result/ivmd/',list.r(x),fileno(filecount),'.mat');
else
    [u, u_hat, omega] = VMD(A, alpha, tau, K, DC, init, tol);
    u_combined = sum(u)';
    ResultFile = strcat(ProjectPath,'/result/vmd/text/',list.r(x),fileno(filecount),'.txt');
    ResultMat = strcat(ProjectPath,'/result/vmd/',list.r(x),fileno(filecount),'.mat');
end

%============DyVMD Noise removal======================


 %=============creating text files=======================


fpt = fopen(ResultFile,'wt');
fprintf(fpt,'RowNo.      Entropy     Energy        Power       StdDev          Mean       Cov      DomFreq        pNN50           TRI          RMSSD        NN50    \n');

%=====================Window Fragmentation======================================
for t=1:Window_Size:T-Window_Size
    c=1;
    for r=t:t+Window_Size-1
        temp(c) = u_combined(r,1);        
        c=c+1;
    end
    
       
    %==================RR intervals calculation=============
    [qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(temp,Fs,0);
    RR = diff(qrs_i_raw)/Fs; %...........calc?
    
    %==============extracting stats =================
    [hrv_pNN50, TRI, rmssd, NNx] = stats(RR);
    [Entropy, Energy, Power, StdDev, Mean, DominantFreq, Cov] = feat(temp,Fs);
    %====================================================
    
    Props(row,ENT) = Entropy;
    Props(row,ENERGY) = Energy;
    Props(row,POWER) = Power;
    Props(row,SD) = StdDev;
    Props(row,MEAN) = Mean;
    if ~isempty(Cov)
    Props(row,Covariance) = Cov;
    end
    Props(row,DOMFREQ) = DominantFreq;
    if ~isempty(hrv_pNN50)        
         Props(row,pNN50) = hrv_pNN50;
    end
     if ~isempty(TRI) 
    Props(row,hrv_tri) = TRI;
    end
    if ~isempty(rmssd) 
        Props(row,RR_rmssd) = rmssd;
    end
    if ~isempty(NNx) 
         Props(row,NN50) = NNx;
    end
    %=================================================
    
    fprintf(fpt,'\n%5d',row);
    for k=1:11
        fprintf(fpt,'%15.3f',Props(row,k));
    end
    row = row+1;
end
fclose(fpt);

save(ResultMat ,'Props');
end
    if y==1 || y==2
        break;
    end
    x = 2;
end
