%ECGPath = strcat(ProjectPath,'/database_ecg/stressed_mias/ecg_S1.txt');

alpha = 2000;       % moderate bandwidth constraint
tau = 0;            % noise-tolerance (no strict fidelity enforcement)
K = 3;              % 3 modes
DC = 0;             % no DC part imposed
init = 1;           % initialize omegas uniformly
tol = 1e-6;



sel = input('enter 1 for database_ecg files or 0 for the noised file saved in current directory\n   ');
if sel
    xf = input('Enter 0 for normal and 1 for stressed:\n     ');
    if xf
        xf = 'stressed';
    else 
        xf = 'normal';
    end
	file = input('enter the file name with extension:\n     ','s');
	file = strcat('database_ecg/',xf,'/',file);
	fpt_1 = fopen(file,'r');
	A = fscanf(fpt_1,'%g');
	fclose(fpt_1);
else
    
	file = input('enter the noised file name with extension (eg. xyz.mat):\n  ','s');
	B = load(file);
    C(:,1) = B.val;
    A = C;
    
end 

La = length(A);
T = min(4000,La);
t = 0:T-1;
freqs = t;
fs = 200;
A = A(1:T,1);
signal = A;



vmd = input('enter 0 for VMD or 1 for IVMD\n      ');
if vmd
    [K] = IVMD(signal, alpha, tau, DC, init, tol);      
	[u, u_hat, omega] = DyVMD(A, alpha, tau, K, DC, init, tol);
	u_combined = sum(u)';
	[i] = vmdplot(u_combined,u, A ,K);
else
	[u, u_hat, omega] = VMD(A, alpha, tau, K, DC, init, tol);
	u_combined = sum(u)';
	[i] = vmdplot(u_combined,u, A ,K);
    msr = immse( u_combined , A ) % Mean square error
    prd = 100*sqrt(sum((u_combined-A).^2)/sum(A.^2)) %Percentage root mean square difference
    snr = 10*log10(sum((2*A-u_combined).^2)/sum((u_combined-A).^2)) % Signal to noise ratio improvement
end

