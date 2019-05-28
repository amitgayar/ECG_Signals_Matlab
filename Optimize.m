% Optimize all data sets for RBFN and SVM
% Breast Cancer Data
% Diabetes
% Liver
% BCI
% Collected Data
%               
% Author: Aaron Pulver 12/4/13
load('load.mat');

Iterations = 50;
C1= 2.6;
C2 = 1.5;
SwarmSize = 20;
 AA = cat(1,AA, A.Props);
C_ECG_SVM = 0;
G_ECG_SVM = 0;

%ecg_struct = ecg_struct(:,1:11);
%ecg_struct = loading.LOAD(20);
[C_ECG_SVM, G_ECG_SVM] = PSO(Iterations,C1,C2,SwarmSize,ecg_struct);


fprintf('Ecg\n');
params = sprintf('-t 2 -c %f -g %f -q', C_ECG_SVM, G_ECG_SVM);
model = fitcsvm(ecg_struct.Learning.Features, ecg_struct.Learning.Labels, 'KernelFunction','rbf', 'KernelScale', C_ECG_SVM, 'BoxConstraint',G_ECG_SVM);
[predict_labeltest, scoretest, costtest] = predict(model,ecg_struct.Testing.Features); % test the training data
fprintf('SVM Ecg (Test): %f\n',scoretest(1));
[predict_labelval, scoreval, costval] = predict(model, ecg_struct.Validation.Features); % test the training data
fprintf('SVM Ecg (Validation): %f\n',scoreval(1));

