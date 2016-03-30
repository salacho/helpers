    function FS = fisherScore(class1Feat,class2Feat) 
% function FS = fisherScore(class1Feat,class2Feat)
%
% Fisher Score for features used for decoding/classification. The bigger the fisher 
% score the more important are the features. The larger the numerator, the more different 
% the mean values of the classes are. The smaller the denominator the less variance within class
% The discriminant power of each feature was estimated using the Fisher score: ?m1-m2|/(s1+s2); 
% where mi and si are the mean value and variance of the samples from the ith class.
% 
% INPUT
% class1Feat:   matrix. [nTrials, nFeatures] List of features for each trial for class1 
% class2Feat:   matrix. [nTrials, nFeatures] List of features for each trial for class2 
%
% OUTPUT
% FS:           matrix. [nChs,nFeatures]. Fisher Score for all the features and channels
%
% Andres    : v1   : init. 25 Jan 2016

% Get mean and var regardless of dimensions
if ndims(class1Feat) ~= 2, error('The dimmensions of the feature space do not match the expected ones!!') %#ok<ISMAT>
else
    mean1 = mean(class1Feat,1);     % class mean
    mean2 = mean(class2Feat,1);
    var1 = var(class1Feat,[],1);    % class variance
    var2 = var(class2Feat,[],1);
end

% Fisher Score
FS = (abs(mean1-mean2))./(var1 + var2);             

end