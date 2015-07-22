function [plotErr] = plotErrorBars(xVals,meanVals,lowStd,upStd,plotParams)
% function [plotErr] = plotErrorBars(xVals,meanVals,lowStd,upStd,plotParams)
%
% Plots mean values and error values per mean as a silhouette of the mean's color. 
% The error values can be standard deviation, error, percentiles, any
% number.
%
% 
%
% This code is a modified version of shadedErrorBar by Rob Campbell.
% Available at http://www.mathworks.com/matlabcentral/fileexchange/26311-shadederrorbar 
%
% INPUT
% xVals:            vector. Values for the x axis when plotting. 
% MeanVals:         vector. Mean values, size of MeanVals must be equal to
%                   Xvals.
% lowStd:           vector. Lower bounds, std or errors plotted underneat the
%                   MeanVals. Must be the same size as MeanVals.
% upStd:            vector. Higher bounds, std or errors plotted over the
%                   MeanVals. Must be the same size as MeanVals.
% plotParams:       structure. Contains the colors used for the mean and
%                   low/upStd values: plotColors(1,:), the line width:
%                   lineWidth and line style: lineStyle.

% Default line style
if ~isfield(plotParams,'lineStyle')
    plotParams.lineStyle = '-';
end

hold on;
plotErr.H = plot(xVals,meanVals,'-',...
            'Color',plotParams.plotColors(1,:),...
            'LineWidth',plotParams.lineWidth); 

        
% lowStd = meanVals - 2*StdVals;
% upStd = meanVals + 2*StdVals;

% Error Bars color
col = get(plotErr.H,'color');
edgeColor = col + (1-col)*0.55;
patchSaturation=0.15; %How de-saturated or transparent to make the patch
faceAlpha=patchSaturation;
patchColor = col;
set(gcf,'renderer','openGL')

%Make the cordinats for the patch
stdP=[lowStd,fliplr(upStd)];
svP=[xVals,fliplr(xVals)];

%remove any nans otherwise patch won't work
xP(isnan(stdP)) = [];
stdP(isnan(stdP))  = [];

plotErr.patch = patch(svP,stdP,1,'facecolor',patchColor,...
              'edgecolor','none',...
              'facealpha',faceAlpha);

%Make nice edges around the patch. 
plotErr.edge(1) = plot(xVals,lowStd,'lineStyle',plotParams.lineStyle,'color',edgeColor);
plotErr.edge(2) = plot(xVals,upStd,'lineStyle',plotParams.lineStyle,'color',edgeColor);

plotErr.axes = get(gca);

% Max. values
end
