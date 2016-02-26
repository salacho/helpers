function plotLayoutChNames(session,paradigmType)
% function plotLayoutChNames(session)
%
% Plots the names of the channels in the layout to properly select the
% channel names to be used for analysis and decoding.
%
% INPUT
% session:  string. Name of the session without the iRun. i.e. '001-20150820'
%
% Andres    : v1    : init. 21 Aug 2015

% session = '001-20150820'; paradigmType = 'eegBaxter';
% Paths and dirs

warning('on','all'), 
dirs = eegErrDirs(paradigmType); 
% Set default params
iRun = 0;           % zero for all population trials, all session, not only one run/block.
ErrorInfo = eegBaxterSetDefaultParams(session,iRun,dirs,1,paradigmType);    % For eegBaxterMain.m and binaryBCI.m decodeOnly must be false; ErrorInfo.epochInfo.decodOnly = 0;  % Not only decoding trials since now no decoding is happening.

% Plot Layout info
hFig = figure;
set(hFig,'PaperPositionMode','auto','Position',[1 41 1600 784],...
    'name',sprintf('%s eegLayout',...
    ErrorInfo.session),...
    'NumberTitle','off','Visible',ErrorInfo.plotInfo.visible);

% Plot eeg layout, all channels in their appropriate subplot location
hPlot = nan(ErrorInfo.nChs,1);
hAxes = nan(ErrorInfo.nChs,1);
hTitle = nan(ErrorInfo.nChs,1);
 
% Use subplots
for iSub = 1:ErrorInfo.layout.subplot.nCols*ErrorInfo.layout.subplot.nRows
    iCh = ErrorInfo.layout.subplot.layout(iSub);
    if iCh ~= 0
        % Proper layout in subplot space based on EEG electrode location
        subplot(ErrorInfo.layout.subplot.nRows,ErrorInfo.layout.subplot.nCols,iSub)
        % Detrend data before potting?
        hPlot(iCh) = imagesc(1);
        %hTitle(iCh) = title(['\color[rgb]{0,0,0} ',ErrorInfo.layout.eegChLbls{iCh},' -','\color[rgb]{0.8,0.2,0.1} ',num2str(iCh)]);
        hTitle(iCh) = title(sprintf('%s - %i',ErrorInfo.layout.eegChLbls{iCh},iCh));
        hAxes(iCh) = gca;
    end
end

% % Plot properties
set(hAxes(:),'Ydir','normal','XTick',[],'YTick',[]) %,'FontSize',ErrorInfo.plotInfo.axisFontSz-2,'YtickLabel',yTickLabel,'Ytick',yTickPos,'FontWeight','normal')
set(hTitle(:),'FontWeight','bold')

end