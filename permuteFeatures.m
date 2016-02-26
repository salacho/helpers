function [Xvals,Yvals,ErrorInfo] = permuteFeatures(Xvals,Yvals,ErrorInfo)
% function [Xvals,Yvals,ErrorInfo] = permuteFeatures(Xvals,Yvals,ErrorInfo)
%
% INPUT
% Xvals:        matrix. [nTrials,nFeatures]; Features matrix for all
%               trials. Organized with correct trials first, then followed by 
%               the features of the incorrect trials. 
% Yvals:        vector. Total number of trials with the correct trials first, 
%               then the incorrect after. Zeros (0) for correct trials, ones (1)
%               for incorrect trials.
% ErrorInfo
%
% OUTPUT
% Xvals:        matrix. [nTrials,nFeatures];
% Yvals:        vector. Total number of trials with the correct trials first, 
%               then the incorrect after. Zeros (0) for correct trials, ones (1)
%               for incorrect trials.
%
% Andres    : v1    : init. 2014
% Andres    : v2.   : separated the function from eegSelectFeatures and
%                     eegBaxterSelectFeat. 25 Jan 2016

nTrials = length(Yvals);

%% Permute trials to mix correct and incorrect trials to avoid biasing analysis (-Anyhow, it will be biased towards correct trials since, in average, we have more correct trials per session-)
if ErrorInfo.featSelect.doPerm
    permTrials = randperm(nTrials);
    % AFSG 20150728 was Xvals = Xvals(:,permTrials,:);
    Xvals = Xvals(permTrials,:);
    Yvals = Yvals(permTrials);
    ErrorInfo.featSelect.Yvals = Yvals;
    ErrorInfo.featSelect.trialsPerm = 1;                    % True when trials were permuted
    ErrorInfo.featSelect.permTrials = permTrials;
    warning('Correct and incorrect trials have been permutted...')
else
    ErrorInfo.featSelect.Yvals = Yvals;
    ErrorInfo.featSelect.trialsPerm = 0;
    ErrorInfo.featSelect.permTrials = 1:nTrials;
end

end