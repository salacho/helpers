function [shuffData,origData] = shuffleData(origData)
% function [shuffData,origData] = shuffleData(origData)
%
% Shuffles labels (origData) to confirm that decoder will not work (low performance) if shuffled (shuffData). 
%
% INPUT
% origData:     vector with labels for classifier. [nTrials 1]
%
% OUTPUT
% shuffData:    vector with labels shuffled for classifier. [nTrials 1]
% 
% Andres    :   v1  : init. 3 Feb 2016

warning('I am shuffling the ''trainY'' to show that this affects the dcd. performance!!!')
% Permuting trials to select them randomnly (not always from start to end)
trialsPermIndx = randperm(length(origData));               % randomnly organize all trials
shuffData = origData(trialsPermIndx);

end
