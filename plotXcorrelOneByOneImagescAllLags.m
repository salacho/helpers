function plotXcorrelOneByOneImagescAllLags(corrEpochsProc,xcorrMeanCorr,xcorrMeanIncorr,xcorrMeanCorrMeanIncorr,rLags)
% function plotXcorrelOneByOneImagescAllLags(corrEpochsProc,xcorrMeanCorr,xcorrMeanIncorr,xcorrMeanCorrMeanIncorr,rLags)
%
% Imagesc cross-correl mancorr and meanIncorr with all the trials, correct and incorrect.
%
%
%
% Andres    :   v1  : init. 2 Dec. 2015

hFig = figure;
set(hFig,'position',[1          41        1600         784]);

onlyCorrTrials = size(corrEpochsProc,2);
nChs = size(xcorrMeanCorr,1);
nTrials = size(xcorrMeanCorr,2);
for iCh = 1:nChs,
    corrVals = squeeze(xcorrMeanCorr(iCh,:,:))';
    incorrVals = squeeze(xcorrMeanIncorr(iCh,:,:))';
    subplot(14,2,1:2:24), imagesc(rLags,1:nTrials,corrVals),
    set(gca,'YDir','normal'), axis tight, xlabel('Channels'), ylabel('Correct  -  Incorrect trials')
    line([rLags(1)-1 rLags(end) + 1],[onlyCorrTrials onlyCorrTrials],'color','k','linewidth',2);
    colorbar('northoutside'),
    
    subplot(14,2,2:2:24), imagesc(rLags,1:nTrials,incorrVals),
    set(gca,'YDir','normal'), axis tight, xlabel('Channels'), ylabel('Correct  -  Incorrect trials')
    line([rLags(1)-1 rLags(end) + 1],[onlyCorrTrials onlyCorrTrials],'color','k','linewidth',2);
    hCol = colorbar('northoutside'); %xlabel(hCol,title(iCh))
    
    meanCorrCorrel =  squeeze(xcorrMeanCorrMeanIncorr(:,1,:));
    meanIncorrCorrel = squeeze(xcorrMeanCorrMeanIncorr(:,3,:));
    subplot(14,2,25:2:28), plot(rLags,meanCorrCorrel(iCh,:),'g');
    subplot(14,2,26:2:28), plot(rLags,meanIncorrCorrel(iCh,:),'r');
    hold off, axis tight, title(iCh)
    pause,
end
