function [xyDist,normDist,eloc] = getLayoutWeighNearNeigh(ErrorInfo,plotDist)
% function [xyDist,normDist,eloc] = getLayoutWeighNearNeigh(ErrorInfo,maxDist,plotDist)
%
% Calculates the distance to neighbor electrodes and gets the list of those
% that are closer, weighted by its distance to the center electrode
%
% INPUT
% ErrorInfo.dirs.asciiLoc:  ascii file with extension *.loc read by readlocs.m file (eeglab) 
%                           for bciChallenge data only, or for other data not coded in 
%                           eegPreAmpConfig.m (see 'eegErrPs' folder) 
% maxDist:                  double. Max. distance to set neighbor channels. After visual 
%                           inspection of 56 channel for BCI challenge@NER2015, between 
%                           0.35 and 0.4 seem to be the most appropriate one.
% plotDist:                 logical. True to plot dist2Ch of all other channels
% ErrorInfo.bciNEC:         logical. TRUE fro BCI challenge data, FALSE for our own EEG
%                           data
%
% OUTPUT
% xyDist:                   matrix. [numChs numChs-1]. All the distances each row channel has
%                           to all the other channels
% normDist:     
%     xyDist:
%     wgDist:
%     chIndx:
%     labels:
%
% Author    :   Andres
%
% Andres    :   v1.0    : init. 14 Jan 2015. 

maxDist = ErrorInfo.signalProcess.laplaMaxDist;

%% Load file
if ErrorInfo.bciChallenge
    [eloc, labels, theta, radius, indices] = readlocs(ErrorInfo.dirs.asciiLoc);  % using bciChallenge2015xyFlip.xyz file. 
%[eloc, labels, theta, radius, indices] = readlocs(ErrorInfo.dirs.asciiLoc);
    maxDist = 0.35; %ErrorInfo.signalProcess.laplaMaxDist;
    disp('Using bciChallenge''s loc coordinates!!')
else
    eloc(:).X = ErrorInfo.layout.xyz(:,1)'/10;
    eloc(:).Y = ErrorInfo.layout.xyz(:,2)'/10;
    labels    = ErrorInfo.layout.eegChLbls';
    maxDist = 0.34; %ErrorInfo.signalProcess.laplaMaxDist;
    disp('Using gtec''s loc coordinates!!')
end

%% Define vbles
%maxDist = 0.35;      % max distance to set neighbor channels. After visual inspection 0.35 seems to be the most appropriate one     

nChs = length([eloc(:).X]);
xDist = [eloc(:).X];
yDist = [eloc(:).Y];
chList = 1:nChs;

% For each channel get the nearest neightbors
xyDist = nan(nChs,nChs-1);
otherChs = nan(nChs,nChs-1);
normDist = repmat(struct(...
    'xyDist',[],... 
    'wgDist',[],...
    'chIndx',[],... 
    'labels','',...
    'topoplotVals',[]),...
    [nChs 1]);

for iCh = 1:nChs 
    otherIndx = iCh ~= chList;
    otherChs(iCh,:) = chList(otherIndx);                % all other chanels besides iCh  
    xLen = repmat(xDist(iCh),[1 nChs-1]) - xDist(otherChs(iCh,:));
    yLen = repmat(yDist(iCh),[1 nChs-1]) - yDist(otherChs(iCh,:));
    xyDist(iCh,:) = sqrt(xLen.^2 + yLen.^2);            % Euclidean distance for X, Y coordinates
    % Get only the closest channels
    maxDistIndx = xyDist(iCh,:) <= maxDist;             % Indx of Electrodes
    normDist(iCh).xyDist = xyDist(iCh,maxDistIndx);
    normDist(iCh).wgDist = normDist(iCh).xyDist/sum(normDist(iCh).xyDist);
    normDist(iCh).chIndx = otherChs(iCh,maxDistIndx);
    normDist(iCh).labels = labels(normDist(iCh).chIndx);
    % Values useful to check in topoplot correct laplacian calculation and nearest neighbour map
    normDist(iCh).topoplotVals = zeros(nChs,1);
    normDist(iCh).topoplotVals(normDist(iCh).chIndx) = 1;   % nearest neighbours using the maxDist criteria)
    normDist(iCh).topoplotVals(iCh) = 2;                    % current channel (center of laplacian)
end

%% Plot distance
cLims = [0 2];
if plotDist
    for iCh = 1:nChs
        subplot(12,1,[11 12])      
        hold off
        plot(otherChs(iCh,:),xyDist(iCh,:))
        hold on,
        plot([1 nChs],[maxDist maxDist],'r'), axis tight
        title(sprintf('%i-%s',iCh,char(labels(iCh))))
        disp(labels(iCh))
        disp(normDist(iCh).labels)
        
        %% Test using topoplot
        subplot(12,1,[1 10])      
        vals2plot = normDist(iCh).topoplotVals;
        topoplot(vals2plot,ErrorInfo.layout.topoplotFile,'plotrad',0.5,'headrad',0.38,'maplimits',cLims)
        title(sprintf('Neighbors %s',char([normDist(iCh).labels])'),'FontWeight',ErrorInfo.plotInfo.titleFontWeight,'FontSize',ErrorInfo.plotInfo.titleFontSz); %(slopeSamp2Sec*iSamp + interceptSamp2Sec)),,'FontWeight',ErrorInfo.plotInfo.titleFontWeight,'FontSize',ErrorInfo.plotInfo.titleFontSz);
        cbH = colorbar; colorbarTxtHandle = get(cbH,'Title');
        set(colorbarTxtHandle,'String',char(labels(iCh)))
        pause
        clf
    end
end


end