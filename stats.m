function [hrv_pNN50 TRI rmssd NNx] = stats(RR)
hrv_pNN50 = 0;
tri = 0;
rmssd = 0;
NNx = 0;

TRI = HRV.TRI(RR,0);
rmssd = HRV.RMSSD(RR);
[hrv_pNN50, NNx] = HRV.pNNx(RR,0,50);

end

