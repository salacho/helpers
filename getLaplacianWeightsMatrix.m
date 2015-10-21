function laplaWeightsMatrix = getLaplacianWeightsMatrix(normDist)
% function laplaWeightsMatrix = getLaplacianWeightsMatrix(normDist)
%
% Construct a weights matrix of laplacian weights using the 'normDist' structure 
% This output is to be hardcoded in simulink
%
%
% Andres    :   v1      : init. 10 Sept 2015

nChs = length(normDist);

laplaWeightsMatrix = zeros(nChs,nChs);
for iCh = 1:nChs
    laplaWeightsMatrix(iCh,normDist(iCh).chIndx) = normDist(iCh).wgDist;
end

% %% How it was constructed before
% % Subtracting Weighted signals
% eegReRef = nan(size(eegY));
% % Get signal after removing laplacians
% for iCh = 1:size(eegY,1)
%     eegReRef(iCh,:) = eegY(iCh,:) - normDist(iCh).wgDist*eegY(normDist(iCh).chIndx,:);
% end
% 
% % To test both work the same
% eegRefMatrix = eegY - laplaWeightsMatrix*eegY;
% fprintf('How different both traces are: %0.15f\n',sum(sum(eegRefMatrix - eegReRef)));                              % sum of difference should equual almost zero ^(-10)
% R = corrcoef(eegRefMatrix(1,1:10000),eegReRef(1,1:10000));      % correlation coefficien should be 1
% imagesc(R),colorbar

end