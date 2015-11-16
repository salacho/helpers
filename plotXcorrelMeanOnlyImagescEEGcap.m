function plotXcorrelMeanOnlyImagescEEGcap(rMeanVals,dataType,autoCorrTxt,onlyCorrTrials,ErrorInfo)
% function plotXcorrelMeanOnlyImagescEEGcap(rMeanVals,onlyCorrTrials,ErrorInfo)
%
% Plots for each meanTrials, in the eegCap layout, the cross-correlation for all lags and trials.
% Saves figures in the ErorrInfo.dirs.newFolder folder.
%
% INPUT
%
%
% Andres    :   v1  : init. 12 Nov. 2013

%% Size
[~,rNumTrials,nLags] = size(rMeanVals);
trialList = 1:rNumTrials;
lagList = linspace(-(nLags-1)/2,(nLags-1)/2,nLags);

%% Properties
ErrorInfo.plotInfo.visible = 'on';
ErrorInfo.plotInfo.epochDetrend = 0;
ErrorInfo.plotInfo.equalLimits = 0;
ErrorInfo = eegGetFilenames(ErrorInfo);

%% Plot
% Naming
ErrorInfo.plotInfo.lagsText = sprintf('%s-eegCapLags-Clims%i-%s-rmBadTrials%0.1f',...
    dataType,ErrorInfo.plotInfo.doClims,autoCorrTxt,ErrorInfo.signalProcess.rmBadTrials*ErrorInfo.signalProcess.badChStDevFactor);

ErrorInfo.plotInfo.title = sprintf('%s %s %s',ErrorInfo.session,ErrorInfo.plotInfo.lagsText,ErrorInfo.dirs.saveFileSuffix(1:end-4));
fprintf('Plotting eegCap layout xCorrel for %s\n',ErrorInfo.plotInfo.lagsText)

% Plot
hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1 41 1600 784],'name',ErrorInfo.plotInfo.title,'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
[hSub,hAxes,hColor] = plotEEGcapImagesc(rMeanVals,lagList,trialList,ErrorInfo.plotInfo,ErrorInfo.layout); 

% Properties
set([hAxes; hColor],'FontSize',ErrorInfo.plotInfo.axisFontSz-8); subplot(hSub(27)), title(ErrorInfo.plotInfo.title)

% Line separating correct and incorrect trials
for iSub = 1:length(hSub), subplot(hSub(iSub)), line([lagList(1)-2 lagList(end)+2],[onlyCorrTrials + 0.5 onlyCorrTrials + 0.5],'color','k','linewidth',1), end

%% Save figure
% Folder where files will be saved
if ~isfield(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder)
    mkdir(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder)
end
% filename
saveFilename = fullfile(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder,sprintf('%s-xCorrel-%s-%s',...
    ErrorInfo.session,ErrorInfo.plotInfo.lagsText,ErrorInfo.dirs.saveFileSuffix));
% Save figure
saveas(hFig,saveFilename)
close(hFig)

end
