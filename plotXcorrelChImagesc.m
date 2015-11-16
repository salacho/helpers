function plotXcorrelChImagesc(xCorrData,nCorrTrials,plotInfo,layout,dirs)
% function plotXcorrelChImagesc(xCorrData,nCorrTrials,plotInfo,layout,dirs)
% 
% Plots cross-correlation of all trials, mean correct, correct, incorrect,
% mean incorrect, per channel, for all trial combinations using imagesc.
% 
% INPUT
% xCorrData:    matrix. Cross-correlation matrix [nChs,nTrialsCondtion1,nTrialsCondtion2]
% nCorrTrials:  integer. Number of correct trials/condition1
% plotInfo:     structure. Has plot properties. and name of file to save in titleInfo.
% layout:       structure. Has subplot eegLayout properties and info
% dirs:         strucutre. Has location of files to save figures. 
%
% Andres    :   v1  :   init. 10 Nov. 2015

[nChs,nTrials1,nTrials2] = size(xCorrData);

% Folder where files will be saved
if ~isfield(dirs.saveFolder,plotInfo.newFolder)
    mkdir(dirs.saveFolder,plotInfo.newFolder)
end

for iCh = 1:nChs
    % filename
    saveFilename = fullfile(dirs.saveFolder,plotInfo.newFolder,sprintf('%s-ch%i-%s',plotInfo.saveTxt,iCh,dirs.saveFileSuffix));
    
    % Figure properties
    %hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1819 86 862 683],'name',mainTxt,'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);
    hFig = figure; set(hFig,'PaperPositionMode','auto','Position',[1819 86 862 683],'name',sprintf('%s-ch%i',plotInfo.saveTxt,iCh),'NumberTitle','off','Visible','off');
    % Plot
    imagesc(1:nTrials1,1:nTrials2,squeeze(xCorrData(iCh,:,:))');
    set(gca,'YDir','normal'), hold on, 
    % Properties
    line([nCorrTrials + 0.5 nCorrTrials + 0.5],[0 size(xCorrData,2)+ 1],'color','k','linewidth',2), 
    line([0 size(xCorrData,2)+1],[nCorrTrials + 0.5 nCorrTrials + 0.5],'color','k','linewidth',2)
    xlabel('corrTrials      -       incorrTrials','fontSize',plotInfo.axisFontSz,'fontweight','bold');
    ylabel('corrTrials      -       incorrTrials','fontSize',plotInfo.axisFontSz,'fontweight','bold');
    title(sprintf('Ch:%i - %s - %s',iCh,plotInfo.titleTxt,layout.eegChLbls{iCh}),'fontSize',plotInfo.axisFontSz,'fontweight','bold'),
    hCol = colorbar; ylabel(hCol,'cross-Correlation val.','fontweight','bold','fontSize',plotInfo.axisFontSz-3)
    % save file
    saveas(hFig,saveFilename)
    close(hFig)
end