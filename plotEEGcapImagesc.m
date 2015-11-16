function [hSub,hAxes,hColor] = plotEEGcapImagesc(dataVals,xVals,yVals,plotInfo,layout)
% function [hSub,hAxes,hColor] = plotEEGcapImagesc(dataVals,xVals,yVals,plotInfo,layout)
%
% Plots dataVals using imagesc and the eegCap layout
%
% INPUT
% dataVals:         matrix. [nChs, xVals, yVals]
% xVals:            xAxis vector.
% yVals:            yAxis vector.
% plotInfo:         structure. Has info for detrending and plot properties
% layout:           structure. Has eegCap subplot layout values. nRows,
%                   nColms, and the proper location of subplot params.
% OUTPUT
% hPlot:            matrix. subplot handle for each channel.
% hAxes:            vector. Handles for the axes
%
% Andres    : v1    : init. 10 Nov. 2015. Based on code from 2013 for EEG SMR analysis.


%% Get Max-Min ranges, CLims
if plotInfo.doClims, plotInfo.clims = [min(min(min(dataVals,[],3),[],2)) max(max(max(dataVals,[],3),[],2))]; end

%% Plot parameters
[nChs,~,~] = size(dataVals); hColor = [];

%% Plotting al channels in their appropriate subplot location
hPlot = nan(nChs,1);
hAxes = nan(nChs,1);
hSub = nan(nChs,1);

% Values to plot. Either 1 or all channels
% Use subplots
for iSub = 1:layout.subplot.nCols*layout.subplot.nRows
    iCh = layout.subplot.layout(iSub);
    if iCh ~= 0
        % Proper layout in subplot space based on EEG electrode location
        hSub(iCh) = subplot(layout.subplot.nRows,layout.subplot.nCols,iSub);
        %% Clims
        if plotInfo.doClims
            hPlot(iCh) = imagesc(xVals,yVals,squeeze(dataVals(iCh,:,:)),[plotInfo.clims(1) plotInfo.clims(2)]);
        else
            hPlot(iCh) = imagesc(xVals,yVals,squeeze(dataVals(iCh,:,:))); if plotInfo.addColorbar, colorbar('eastoutside'); end
        end
        set(gca,'YDir','normal'),
        hAxes(iCh) = gca;
        axis tight
    end
end

if plotInfo.doClims, subplot(layout.subplot.nRows,layout.subplot.nCols,2), hColor = colorbar('westoutside'); caxis([plotInfo.clims(1) plotInfo.clims(2)]), axis off, end

end