function [i] = vmdplot(u_combined, u, A , K)

figure('Name', 'Original Signal');
plot(A(1:1000));
title('Original Signal');
xlabel('samples');
ylabel('Amplitude');

figure('Name', 'Recontructed Signal');
plot(u_combined(1:1000));
title('Recontructed Signal');
xlabel('Time, s');
ylabel('signal, Hz');

i=1;
while i<K+1
   figure('Name', 'Various Modes');
   
    for j=1:3
    
    Y = u(i,1:1000);
    subplot(3,1,j);
    plot(Y) 
    str = strcat('VMF ',num2str(i+j-1));
    title(str);
    xlabel('samples');
    ylabel('Amplitude'); 
             if i==K
                     break;
              end
    end
    i=i+3;
end 

Lu = length(u(1,1:1000));
NFFT = 2^nextpow2(Lu);
f = 2000/2*linspace(0,1,NFFT/2);

i=1;
while i<K+1
   figure('Name', 'Various Modes');
   
    for j=1:3
    
    Y = fft(u(i,1:1000),NFFT)/Lu;
    f = 2000/2*linspace(0,1,NFFT/2);        
    subplot(3,1,j);
    plot(f,2*abs(Y(1:NFFT/2))) 
    str = strcat('VMF ',num2str(i+j-1));
    title(str)
    xlabel('Freq (Hz)')
    ylabel('|Y(f)|')
              if i==K
                     break;
              end
    end
    i=i+3;
end  

end