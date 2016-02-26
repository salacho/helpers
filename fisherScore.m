function FS = fisherScore(class1Feat,class2Feat) 
% function FS = fisherScore(class1Feat,class2Feat)
%
% Fisher Score for features used for decoding/classification. The bigger the fisher 
% score the more important are the features. The larger the numerator, the more different 
% the mean values of the classes are. The smaller the denominator the less variance within class
% 
% INPUT
% class1Feat:   matrix. [nChs, nTrials, nFeatures] List of features for all 
%               channels of class1 trials 
% class2Feat:   matrix. [nChs, nTrials, nFeatures] List of features for all 
%               channels of class2 trials 
%
% OUTPUT
% FS:           matrix. [nChs,nFeatures]. Fisher Score for all the features and channels
%
% Andres    : v1    : init. 25 Jan 2016

% Get mena and var rgeardless of dimensions
if length(size(class1Feat)) == 3,                   
    mean1 = mean(class1Feat,3);  % class mean
    mean2 = mean(class2Feat,3);
    var1 = var(class1Feat,[],3);    % class variance
    var2 = var(class2Feat,[],3);
elseif length(size(class1Feat)) == 2,   
    mean1 = mean(class1Feat,2);  % class mean
    mean2 = mean(class2Feat,2);
    var1 = var(class1Feat,[],2);    % class variance
    var2 = var(class2Feat,[],2);
end

% Fisher Score
FS = (abs(mean1-mean2))./(var1 + var2);             

end