function [y, ym] = dyvmd(x, alpha, tau, K, DC, init, tol)	

wlen = 256;  
hop = wlen/8;
%nfft = wlen;

Sig = x;
clear x;
x = Sig;
% generate analysis and synthesis windows
awin = blackmanharris(wlen, 'periodic');
swin = hamming(wlen, 'periodic');

% representation of the signal as column-vector
x = x(:);
% determination of the signal length 
xlen = length(x);
% determination of the window length
wlen = length(awin);
% stft matrix size estimation and preallocation

L = 1+fix((xlen-wlen)/hop); % calculate the number of signal frames
    
y = zeros(xlen,1);
ym = zeros(xlen,K);
for l = 0:L-1
   % windowing
    xw = x(1+l*hop : wlen+l*hop).*awin;
    
   
  [u, ~, ~] = VMD(xw, alpha, tau, K, DC, init, tol);
  u_comb = sum(u)';
  u = u'; 
    
    y(1+l*hop : wlen+l*hop) = y(1+l*hop : wlen+l*hop) + (u_comb.*swin);
    for c=1:K
        ym(1+l*hop : wlen+l*hop,c) = ym(1+l*hop : wlen+l*hop,c) + (u(:,c).*swin);
    end
    
end

% =======================scaling of the signal
W0 = sum(awin.*swin);                  
y = y.*hop/W0;
ym = ym.*hop/W0;
end