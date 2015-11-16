function plotXcorrelImagescEEGcap(rDataVals,rLags,nCorrTrials,ErrorInfo)
% function plotXcorrelImagescEEGcap(rDataVals,rLags,nTrials,nCorrTrials,ErrorInfo)
%
% Plots for each trial, in the eegCap layout, the cross-correlation for all lags and trials. 
% Saves figures in the ErorrInfo.dirs.newFolder folder.
%
% INPUT
%
%
% Andres    :   v1  : init. 11 Nov. 2013

%% Size
[~, nTrials1, nTrials2,~] = size(rDataVals);
trialNum = 1:nTrials2; 

%% Properties
ErrorInfo.plotInfo.visible = 'off';
ErrorInfo.plotInfo.epochDetrend = 0;
ErrorInfo.plotInfo.equalLimits = 0;

%% Plot
for trial1 = 1:nTrials1
    % Naming
    trial1Txt = getTrialTxt(trial1,nTrials1,nCorrTrials);
    lagsText = sprintf('eegCapLags-Clims%i-%s-rmBadTrials%0.1f',ErrorInfo.plotInfo.doClims,trial1Txt,ErrorInfo.signalProcess.rmBadTrials*ErrorInfo.signalProcess.badChStDevFactor);
    ErrorInfo.plotInfo.title = sprintf('%s %s %s',ErrorInfo.session,lagsText,ErrorInfo.dirs.saveFileSuffix(1:end-4));
    fprintf('Plotting eegCap layout xCorrel for %s\n',lagsText)
    
    % Plot
    hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1 41 1600 784],'name',ErrorInfo.plotInfo.title,'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
    dataLags = squeeze(rDataVals(:,trial1,:,:));
    [hSub,hAxes,hColor] = plotEEGcapImagesc(dataLags,rLags,trialNum,ErrorInfo.plotInfo,ErrorInfo.layout); %#ok<NASGU>
   
    % Properties
    set(hAxes,'FontSize',ErrorInfo.plotInfo.axisFontSz-8); subplot(hSub(27)), title(ErrorInfo.plotInfo.title)

    % Line separating correct and incorrect trials
    for iSub = 1:length(hSub), subplot(hSub(iSub)), line([rLags(1)-2 rLags(end)+2],[nCorrTrials + 0.5 nCorrTrials + 0.5],'color','k','linewidth',1), end
    
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
end

end
