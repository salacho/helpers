function plotXcorrelCorrIncorrZeroeEEGcap(rCorrVals,rIncorrVals,onlyCorrTrials,ErrorInfo)
% function plotXcorrelCorrIncorrTraceEEGcap(rCorrVals,rIncorrVals,onlyCorrTrials,ErrorInfo)
%
% Plots in the eegCap layout the zeroLags cross-correlation of each trial with 
% meanCorr and meanIncorr. Saves figures in the ErorrInfo.dirs.newFolder folder.
%
% INPUT
% rCorrVals:    matrix. [nChs nTotalTrial]. Cross-correlation of all trials
%               with the meanCorrect trial. Correct trials always first
% rIncorrVals:  matrix. [nChs nTotalTrial]. Cross-correlation of all trials
%               with the meanIncorrect trial. Correct trials always first
% onlyCorrTrials:  integer. Number fo correct trials. Correct trials always first.
% ErrorInfo:    structure. PlotInfo, layout, and dirs. saving and naming params.
%
% Andres    :   v1  : init. 16 Nov. 2013

ErrorInfo.plotInfo.visible = 'on';
ErrorInfo.plotInfo.epochDetrend = 0;
ErrorInfo.plotInfo.equalLimits = 0;
nTrials = size(rCorrVals,2);

% Naming
dataType = {'meanCorr','meanIncorr'};
dataVals = {'rCorrVals','rIncorrVals'};

hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1 41 1600 784],'name','meanCorr-meanIcorr zeroLag all Chs','NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);

% Plot iSub
hAxes = []; hSub = []; hImag = []; hBar = []; 
for iSub = 1:2;
    % Txt
    lagsText{iSub} = sprintf('eegCapZeroLag-%s-rmBadTrials%0.1f',dataType{iSub},ErrorInfo.signalProcess.rmBadTrials*ErrorInfo.signalProcess.badChStDevFactor);
    ErrorInfo.plotInfo.title{iSub} = sprintf('%s %s-%s',ErrorInfo.session,ErrorInfo.dirs.saveFileSuffix(1:end-4),lagsText{iSub});
    fprintf('Plotting eegCap layout xCorrel for %s\n',lagsText{iSub})
    % Subplot
    hSub(iSub) = subplot(2,1,iSub);
    
%    [hSub,hAxes,hColor] = plotEEGcapImagesc(eval(eval('dataVals{iSub}'))',1,1:nTrials,ErrorInfo.plotInfo,ErrorInfo.layout)
    [hPlot,hLine,hAxes,hSub] = plotEEGcap(rCorrVals,1:nTrials,ErrorInfo.plotInfo,ErrorInfo.layout,rIncorrVals); %#ok<*ASGLU>
  
    % Properties
    set(gca,'YDir','normal'), axis tight, xlabel('Channels'), ylabel('Correct  -  Incorrect')
    hAxes(iSub) = gca;
    title(ErrorInfo.plotInfo.title{iSub})
    hBar = colorbar('eastoutside');
end

set(hAxes,'FontSize',ErrorInfo.plotInfo.axisFontSz-8); 

% Line separating correct and incorrect trials
for iSub = 1:length(hSub), subplot(hSub(iSub)), yLimVal = get(hAxes(iSub),'ylim');  line([onlyCorrTrials + 0.5 onlyCorrTrials + 0.5],[yLimVal],'color','k','linewidth',1), end

%% Save figure
% Folder where files will be saved
if ~isfield(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder)
    mkdir(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder)
end


$$$$$$$$

%% Save figure
% Folder where files will be saved
if ~isfield(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder)
    mkdir(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder)
end
% filename
saveFilename = fullfile(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder,sprintf('%s-xCorrel_mean&CorrIncorr-%s-%s',...
    ErrorInfo.session,lagsText,ErrorInfo.dirs.saveFileSuffix));
% Save figure
saveas(hFig,saveFilename)
close(hFig)

