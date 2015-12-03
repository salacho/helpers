function plotXcorrelZeroLagImagesc(dataValsCorr,dataValsIncorr,onlyCorrTrials,ErrorInfo,logData)
%
%
%
%
% Andres    :   v1  : init. 29 Nov. 2015

plotInfo = ErrorInfo.plotInfo;
[nChs, nTrials] = size(dataValsCorr);
xVals = 1:nChs;
yVals = 1:nTrials;

if logData, logTxt = 'logReal '; else logTxt = ''; end
hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1          41        1600         784],'name',sprintf('%s',logTxt),'NumberTitle','off','Visible','on');

%% Clims
if ErrorInfo.plotInfo.doClims
    hSub(1) = subplot(1,2,1);
    hPlot(1) = imagesc(xVals,yVals,dataValsCorr',[plotInfo.clims(1) plotInfo.clims(2)]);
    title(['meanCorr ', logTxt, 'xCorrelation']);
    set(gca,'YDir','normal'), axis tight, xlabel('Channels'), ylabel('Correct  -  Incorrect')
    line([0 nChs + 1],[onlyCorrTrials + 0.5 onlyCorrTrials],'color','k','linewidth',1);
    colorbar,
    
    hSub(2) = subplot(1,2,2);
    hPlot(2) = imagesc(xVals,yVals,dataValsIncorr',[plotInfo.clims(1) plotInfo.clims(2)]);
    title(['meanIncorr ', logTxt, 'xCorrelation']);
    set(gca,'YDir','normal'), axis tight, xlabel('Channels'), ylabel('Correct  -  Incorrect')
    line([0 nChs + 1],[onlyCorrTrials + 0.5 onlyCorrTrials],'color','k','linewidth',1);
    colorbar,
    
else
    hSub(1) = subplot(1,2,1);
    hPlot(1) = imagesc(xVals,yVals,dataValsCorr');
    title(['meanCorr ', logTxt, 'xCorrelation']);
    set(gca,'YDir','normal'), axis tight, xlabel('Channels'), ylabel('Correct  -  Incorrect trials')
    line([0 nChs + 1],[onlyCorrTrials + 0.5 onlyCorrTrials],'color','k','linewidth',2);
    colorbar,
    
    hSub(2) = subplot(1,2,2);
    hPlot(2) = imagesc(xVals,yVals,dataValsIncorr');
    title(['meanIncorr ', logTxt, 'xCorrelation']);
    set(gca,'YDir','normal'), axis tight, xlabel('Channels'), ylabel('Correct  -  Incorrect trials')
    line([0 nChs + 1],[onlyCorrTrials + 0.5 onlyCorrTrials],'color','k','linewidth',2);
    colorbar,
end

%% Save figure
% Folder where files will be saved
if ~isfield(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder)
    mkdir(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder)
end
% filename
saveFilename = fullfile(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder,sprintf('%s-xCorrel_mean&CorrIncorr-%s-%s',...
    ErrorInfo.session,logTxt,ErrorInfo.dirs.saveFileSuffix));
% Save figure
saveas(hFig,saveFilename)
close(hFig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5


end