function [fitness] = FitnessFunctionSVM(C,G, Data)
%FitnessFunctionSVM The fitness function used to optimize the SVM
% Inputs: 
%   C: Cost
%   G: Gamma 
%   Data: The data stucture to optimize for
% Output:
%   fitness: The fitness of the function (0 is optimal)

    %params = sprintf('-t 2 -c %f -g %f -q',C,G);
    clear accuracy;
    
    %{
    model = fitcsvm(Data.Learning.Features,Data.Learning.Labels, 'KernelFunction','rbf', 'KernelScale', C, 'BoxConstraint',G);
    modelValidation = fitcsvm(Data.Validation.Features,Data.Validation.Labels, 'KernelFunction','rbf', 'KernelScale', C, 'BoxConstraint',G);
    mdlSVM = fitPosterior(model);
    vmdlSVM = fitPosterior(modelValidation);
    [label,score_svm] = resubPredict(mdlSVM);
    [vlabel,vscore_svm] = resubPredict(vmdlSVM);
    %[predict_label, accuracy1, dec_values] = predict(modelValidation, Data.Validation.Features);
    %[predict_label, accuracy2, dec_values] = predict(model, Data.Learning.Features);
    %fitness = abs(accuracy1(1)-accuracy2(1))/(accuracy1(1)+accuracy2(1));
    fitness = 1/(accuracy1(1)*accuracy2(1));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %}
    
    d.l.l = Data.Learning.Labels;
    d.l.f = Data.Learning.Features;
    
    indices = crossvalind('Kfold',d.l.l,10);
    cp = classperf(d.l.l);
    test=[];
    train=[];
    for i = 1:10
    test = (indices == i);
    train = ~test;
   
    label = classify(d.l.f(test,1:11),d.l.f(train,1:11),d.l.l(train,:),'diaglinear');
    %svm= fitcsvm (d.l.f(train, :), label);
    %classes = predict(svm, d.l.f(test, :));
    classperf(cp,label,test);
    end
     
     
    


  


Accuracy = cp.CorrectRate * 100;
fitness = Accuracy;
fprintf ("Accuracy rate is% d", Accuracy);

   % fprintf('Accuracy: %f Accuracy: %f\t L: %d B: %f \n',accuracy1(1),accuracy2(1),C,G);

   
end


% Assuming you have a vector with the labels in an array called "classes" and your data (features) in a matrix called "myData".
%{
   for ii = 1:19
   testProportion = (ii*5)/100
   c = cvpartition(d.l.l, 'holdout',testProportion);
   trainData = d.l.f(training(c,1),:);
   testData  = d.l.f(test(c,1),:);
   label = classify(testData,trainData,d.l.l(training(c,1),1));
   end
%}
