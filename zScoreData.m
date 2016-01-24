function zScoredData = zScoreData(dataOrig)
% function zScoredData = zScoreData(dataOrig)
%
% Z-scores data per trial. Subtracting the trial mean and dividing by trial
% variance.
% 
% INPUT
% dataOrig:         matrix. [nChs nTrials nSamps]. Or [nChs nSamps]
%
% OUTPUT
% zScoredData:      matrix. [nChs nTrials nSamps]. Or [nChs nSamps]
%                   z-scored data after processing on each trial.
%
% Andres    : v1    : init. 12 Sept 2015 
% Andres    : v2    : Fixed bug that was dividing by variance, not standard-deviation, 
%                     as it should have been done since the beginning. 23 Jan 2016

if ndims(dataOrig) == 2     %#ok<*ISMAT>
        dataMean = repmat(mean(dataOrig,2),[1 size(dataOrig,2)]);           % whole channel mean
        dataStDev = repmat(std(dataOrig,0,2),[1 size(dataOrig,2)]);
        zScoredData =  (dataOrig - dataMean)./dataStDev;
elseif ndims(dataOrig) == 3
    % pre-allocate memory
    zScoredData = nan(size(dataOrig));
    % z-scoring each trial
    for iTrial = 1:size(dataOrig,2)
        trialData = squeeze(dataOrig(:,iTrial,:));
        trialMean = repmat(mean(trialData,2),[1 size(dataOrig,3)]);         % trial mean
        %trialVar = repmat(var(trialData')',[1 size(dataOrig,3)]);          %#ok<UDIM> % need to do this to avoid 'var' thinking we are inputting weights to the variance calculation
        %zScoredData(:,iTrial,:) =  (trialData - trialMean)./trialVar;
        trialStDev = repmat(std(trialData,0,2),[1 size(dataOrig,3)]);
        zScoredData(:,iTrial,:) =  (trialData - trialMean)./trialStDev;
    end
else
    error('The number of dimmensions of the input data dataOrig (%i) is incorrect!!!',ndims(dataOrig))
end

disp('Z-scoring dataOrig!!')

end
