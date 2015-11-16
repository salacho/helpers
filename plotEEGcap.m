function [hPlot,hLine,hAxes] = plotEEGcap(dataVals,timeVals,plotInfo,layout)
% function [hPlot,hLine,hAxes] = plotEEGcap(dataVals,timeVals,plotInfo,layout)
%
% Plots in the eegCap layout the dataVals using the x-axis in timeVals
%
% INPUT
% dataVals:         matrix. [nChs, nSamps] 
% timeVals:         xAxis vector. [nSamps 1].
% plotInfo:         structure. Has info for detrending and plot properties
% layout:           structure. Has eegCap subplot layout values. nRows,
%                   nColms, and the proper location of subplot params.
% OUTPUT
% hPlot:            matrix. subplot handle for each channel. 
% hLine:            vector. Handles for the lines setting a specific event
%
% Andres    : v1    : init. 09 Nov. 2015. Based on code from 2013 for EEG SMR analysis.


%% Get Max-Min ranges
tracesVals.dataVals = (dataVals);
maxMinVals = getMaxMin(tracesVals,plotInfo.epochDetrend);
nPlots = length(tracesVals); hLine = [];

%% Plot parameters
[nChs,nSamps] = size(dataVals);

%% Plotting al channels in their appropriate subplot location
hPlot = nan(nChs,1);
hAxes = nan(nChs,1);
tracesFields = fields(tracesVals);

for iAve = 1:nPlots%nPlots:-1:1
    % Values to plot. Either 1 or all channels
    eval(sprintf('plotVals = tracesVals.%s;',char(tracesFields(iAve))))
    % Use subplots
    for iSub = 1:layout.subplot.nCols*layout.subplot.nRows
        iCh = layout.subplot.layout(iSub);
        if iCh ~= 0
            % Proper layout in subplot space based on EEG electrode location
            subplot(layout.subplot.nRows,layout.subplot.nCols,iSub)
            
            %% Time traces
            % Detrend data before potting?
            if plotInfo.epochDetrend, hPlot(iCh,iAve) = plot(timeVals,detrend(plotVals(iCh,:)),'color',plotInfo.colorErrP(iAve,:));   %#ok<*NODEF>
            else hPlot(iCh,iAve) = plot(timeVals,plotVals(iCh,:),'color',plotInfo.colorErrP(iAve,:));
            end
            hAxes(iCh) = gca;
            
            % Use equal y limits
            if plotInfo.equalLimits
                if iAve == 4, ylim([maxMinVals.yMin maxMinVals.yMax]), end
                % Plot time feedback presentation
                hLine(iCh,iAve) = line([0 0],[maxMinVals.yMin maxMinVals.yMax],'lineStyle','--','color','k'); %#ok<AGROW>
            end
            axis tight, hold on
        end
    end
end
% Some plot properties
set(hPlot,'lineWidth',plotInfo.lineWidth-4)
set(hAxes,'FontSize',plotInfo.axisFontSz-5)
if plotInfo.equalLimits, set(hLine,'lineWidth',plotInfo.lineWidth-5,'color','k'), end

subplot(layout.subplot.nRows,layout.subplot.nCols,5)
title(plotInfo.title)


end