function plotXcorrelTraceEEGcap(rDataVals,rLags,nCorrTrials,ErrorInfo)
% function plotXcorrelTraceEEGcap(rDataVals,rLags,nCorrTrials,ErrorInfo)
%
% Plots in the eegCap layout the xross-correlation for all lags for each
% trial-trial combination. Saves figures in the ErorrInfo.dirs.newFolder
% folder.
%
% INPUT
%
%
% Andres    :   v1  : init. 11 Nov. 2013

ErrorInfo.plotInfo.visible = 'off';
ErrorInfo.plotInfo.epochDetrend = 0;
ErrorInfo.plotInfo.equalLimits = 0;
nTrials = size(rDataVals,2);

for trial1 = 1:nTrials
    for trial2 = 1:nTrials
        % Naming
        trial1Txt = getTrialTxt(trial1,nTrials,nCorrTrials);  trial2Txt = getTrialTxt(trial2,nTrials,nCorrTrials);
        lagsText = sprintf('eegCapLags-%s_%s-rmBadTrials%0.1f',trial1Txt,trial2Txt,ErrorInfo.signalProcess.rmBadTrials*ErrorInfo.signalProcess.badChStDevFactor);
        ErrorInfo.plotInfo.title = sprintf('%s %s-%s',ErrorInfo.session,ErrorInfo.dirs.saveFileSuffix(1:end-4),lagsText);
        fprintf('Plotting eegCap layout xCorrel for %s\n',lagsText) 
        
        % Plot
        hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1 41 1600 784],'name',ErrorInfo.plotInfo.title,'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
        dataLags = squeeze(rDataVals(:,trial1,trial2,:));
        [hPlot,hLine,hAxes] = plotEEGcap(dataLags,rLags,ErrorInfo.plotInfo,ErrorInfo.layout); %#ok<*ASGLU>
        set(hAxes,'FontSize',ErrorInfo.plotInfo.axisFontSz-8)

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
