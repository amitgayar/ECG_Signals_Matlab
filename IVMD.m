function [K] = IVMD(signal, alpha, tau, DC, init, tol)
% =======source : "https://www.hindawi.com/journals/mpe/2016/1713046/"
K = 1; % for initial purpose working of VMD
f = signal;
r = 1;
while r > 0.05
    K = K + 1;
   [u, ~, ~] = VMD(f, alpha, tau, K, DC, init, tol);
   residue = f - sum(u)';
   r = cov(residue,f)/(std(f)*std(residue));
end