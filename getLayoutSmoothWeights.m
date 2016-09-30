function smoothW = getLayoutSmoothWeights(chsDist,chsList,outChannels,smoothType)
% function smoothW = getLayoutSmoothWeights(chsDist,chsList,outChannels,smoothType)
%
%
%
%
%
% Andres    :   v1      : init. 27 June 2016. 

% chsDist,chsList, outChannels
nChs = numel(outChannels);
subChsDistList = nan(nChs,nChs);
subChsList = nan(nChs,nChs);
subChsDist = nan(nChs,nChs);

% Change mapping from totalChannels to subChannels
for iCh=1:nChs
    % Get distance for only subChannels (what matters, since the other channels are not anymore)
    for iOut=1:nChs
        % Get subChs distances
        [indx,tmp] = intersect(chsList(iCh,:),outChannels(iOut));  % outChannels are currently available channels, subChannels. chsList(iCh,:) = neighbours of subCh
        if isempty(tmp), else subChsDist(iCh,iOut) = chsDist(iCh,tmp); end
        % subChs list using original mapping
        if isempty(indx), else subChsList(iCh,iOut) = indx; end         % in original mapping 
        % subchs list using subChannels mapping
        tmpCh = find(subChsList(iCh,:) == outChannels(iOut));
        if isempty(tmpCh), tmpCh = nan; end
        subChsDistList(iCh,iOut) = tmpCh;                               % in new subspace mapping
    end
end

%% Get values
% fix layout
subChsDist,subChsList,subChsDistList

switch smoothType
    case 'expDecay'
            subChsDist(iCh,:)
            smoothW = 
        subChsDistList(iCh,:)
end


end
