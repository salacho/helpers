function plotXcorrelMeanOnlyChImagesc(xcorrMeanVals,nCorrTrials,ErrorInfo)
% function plotXcorrelMeanOnlyChImagesc(xcorrMeanVals,nCorrTrials,ErrorInfo)
%
% Plots cross-correlation of all trials with mean correct and mean incorrect 
% per channel using imagesc.
% 
% INPUT
% xcorrMeanCorr:    matrix. Cross-correlation matrix [nChs,nTrialsCondtion1,nTrialsCondtion2]
% nCorrTrials:      integer. Number of correct trials/condition1
% ErrorInfo:        structure. Has plot properties. and name of file to save in titleInfo.
%
% Andres    :   v1  :   init. 10 Nov. 2015

[nChs,nMeanTrials,nLags] = size(xcorrMeanVals);
trialList = 1:nMeanTrials;
lagList = linspace(-(nLags-1)/2,(nLags-1)/2,nLags);

% Folder where files will be saved
if ~isfield(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder)
    mkdir(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder)
end

for iCh = 1:nChs
    % filename
    saveTxt = sprintf('%s-xCorrel_Clims%i-%s-%s-rmBadTrials%0.1f',...
        ErrorInfo.session,ErrorInfo.plotInfo.doClims,ErrorInfo.plotInfo.dataType,ErrorInfo.plotInfo.autoCorrTxt,ErrorInfo.signalProcess.rmBadTrials*ErrorInfo.signalProcess.badChStDevFactor);
    fprintf('Plotting xCorrel lags for %s\n',saveTxt)
    % title
    titleTxt = sprintf('%s %s',saveTxt,ErrorInfo.dirs.saveFileSuffix(1:end-4));
    % saveFile
    saveFilename = fullfile(ErrorInfo.dirs.saveFolder,ErrorInfo.plotInfo.newFolder,sprintf('%s-ch%i-%s',saveTxt,iCh,ErrorInfo.dirs.saveFileSuffix));
    
    % Figure properties
    hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1805 86 985 683],'name',sprintf('%s-ch%i',saveTxt,iCh),'NumberTitle','off','Visible','on');
    % Plot
    imagesc(lagList,trialList,squeeze(xcorrMeanVals(iCh,:,:)));
    set(gca,'YDir','normal'), hold on, 
    % Properties
    line([lagList(1) - 0.5 lagList(end) + 0.5],[nCorrTrials nCorrTrials],'color','k','linewidth',2), 
    xlabel('sampleLags','fontSize',ErrorInfo.plotInfo.axisFontSz,'fontweight','bold');
    ylabel('corrTrials      -       incorrTrials','fontSize',ErrorInfo.plotInfo.axisFontSz,'fontweight','bold');
    title(sprintf('Ch:%i - %s - %s',iCh,titleTxt,ErrorInfo.layout.eegChLbls{iCh}),'fontSize',ErrorInfo.plotInfo.axisFontSz,'fontweight','bold'),
    hCol = colorbar; ylabel(hCol,'cross-Correlation val.','fontweight','bold','fontSize',ErrorInfo.plotInfo.axisFontSz-3)
    
    % save file
    saveas(hFig,saveFilename)
    close(hFig)
end