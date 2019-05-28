function [Entropy, Energy, Power, StdDev, Mean, DominantFreq, Cov] = feat(Signal, SamplingRate)
%subplot(3,1,1); 
%plot(Signal);
%title('Sub-Part of the Original Signal');
Entropy=0;
Energy=0;
Power=0;
SD=0;
Mean=0;
DominantFreq=0;
Cov = 0;

L = length(Signal);
nfft = 2^nextpow2(L); % Next power of 2 from length of y
x = Signal;
x = x - mean(x);       

%plot(t,x), axis('tight'), grid('on'), title('Time series'), figure

y = fft(x,nfft); % Fast Fourier Transform
y = abs(y.^2); % raw power spectrum density
y = y(1:1+nfft/2); % half-spectrum
[~,k] = max(y); % find maximum

f_scale = (0:nfft/2)* SamplingRate/nfft; %-------------- frequency scale
%plot(f_scale, y),axis('tight'),grid('on'),title('Dominant Frequency')
DominantFreq = f_scale(k); %--------------- dominant frequency estimate


% Plot single-sided amplitude spectrum.
%subplot(3,1,2); 
%plot(f,2*abs(Y(1:nfft/2)));
%title('Single-Sided Amplitude Spectrum of y(t)');
%xlabel('Frequency (Hz)');
%ylabel('|Y(f)|');

IMF = [];
Sum=0;
Sum_2=0;
for r=1:L
    IMF(r) = Signal(r) * cos(2*pi*(r/SamplingRate));
    Sum = Sum + IMF(r); 
    Sum_2 = Sum_2 + power(IMF(r),2);
end

Entropy = entropy(IMF);
Mean = mean(IMF);
Energy = Sum_2/SamplingRate;
Power = Sum_2/L;

%Power = (norm(IMF)^2)/L   %-----------alternate
StdDev = std(IMF);  %............StdDev changed to std
Cov = cov(IMF);
%subplot(3,1,3); plot(IMF); title('Sub-Part of the Original Signal');
end