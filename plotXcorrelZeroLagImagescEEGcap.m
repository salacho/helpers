function plotXcorrelZeroLagImagescEEGcap(r0CorrIncorr,nCorrTrials,ErrorInfo)
% function plotXcorrelZeroLagImagescEEGcap(r0CorrIncorr,nCorrTrials,ErrorInfo)
%
% Plots in the eegLayout the zero-lag cross-correlation across all trials>: correct,
% incorrect, meancorr and meanIncorr 
% 
% INPUT
% r0CorrIncorr:     matrix. Cross-correlation of correct, incorrect,
%                   meanCorr and meanIncorr for zero lag.
% nCorrTrials:      integer. Numer of correct trials.
% ErrorInfo:        structure.
%
% Andres    :   v1  :   init. 12 Nov. 2015

hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[ 1601 -123  1280 948],'name',...
    char(ErrorInfo.plotInfo.title),'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);

% Params
nTrials = size(r0CorrIncorr,3);
xVals = 1:nTrials; yVals = 1:nTrials; 

% Plot values
[hSub,hAxes,hColor] = plotEEGcapImagesc(r0CorrIncorr,xVals,yVals,ErrorInfo.plotInfo,ErrorInfo.layout);

% Properties
set([hAxes; hColor],'FontSize',ErrorInfo.plotInfo.axisFontSz-8); subplot(hSub(27)), title(ErrorInfo.plotInfo.title)     

% Line separating correct and incorrect trials
if ErrorInfo.plotInfo.doLine
    for iSub = 1:length(hSub), subplot(hSub(iSub)), hold on,
        line([nCorrTrials + 0.5 nCorrTrials + 0.5],[0 nTrials+1],'color','k','linewidth',ErrorInfo.plotInfo.lineWidth-4);
        line([0 nTrials+2],[nCorrTrials + 0.5 nCorrTrials + 0.5],'color','k','linewidth',2)
    end
end

% Save figure
saveFilename = fullfile(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder,sprintf('%s-xCorrel_mean&CorrIncorr-%s-%s',...
    ErrorInfo.session,ErrorInfo.plotInfo.title,ErrorInfo.dirs.saveFileSuffix));
saveas(hFig,saveFilename)
    
end