function trialValTxt = getTrialTxt(trialVal,nTrials,nCorrTrials)
% function trialValTxt = getTrialTxt(trialVal,nTrials,nCorrTrials)
%
% Determines trial naming for nTrials with nCorrect and nIncorrect trials
% including the meanCorrect epoch at the beginning and the meanIncorrect
% epoch at the end.
%
% INPUT
% trialVal:         integer. current trial
% nTrials:          integer. Total number of trials, sum of correct, incorrect, meanCorr and meanIncorr 
% nCorrTrials:      integer. total number of correct trials including the meanCorr
%
% Andres    :   v1      : init. 10 Nov. 2015

% for trialVal = 1:nTrials
if trialVal == 1,trialValTxt = 'meanCorr';
else
    if trialVal <= nCorrTrials, trialValTxt = sprintf('corrTrial%i',trialVal);
    else if and(trialVal > nCorrTrials,trialVal < nTrials), trialValTxt = sprintf('incorrTrial%i',trialVal);
        else trialValTxt = 'meanIncorr';
        end
    end
end
%     disp([num2str(trialVal),'-',trialValTxt])
%     pause
% end
