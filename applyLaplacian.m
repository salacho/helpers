function dataProj = applyLaplacian(dataRaw,laplaWeights)
%
% Subtracts from each channel the projected activity using the weights in laplaW 
% Data must be in the form [nChs x n=Samps] since projections occurs in the 1D of dataRaw.
%
% INPUT
% dataRaw:      matrix. [nChs nSamps] or [nChs nTrials nSamps]
% laplaW:       matrix. [nChs nChs]. Ussually only some channels have values ~=
%               0;
% OUTPUT
% dataProj:     matrix. Data projected with the same dimmensionality over
%               the time samples. size(dataProj) == size(dataProj)
%
% Andres    :   v1  : init. 11 Sept 2015

nDims = ndims(dataRaw); 

if nDims == 2                           % for data organized as long EEG recording (before epoching)
    disp('Applied laplacian to denoise the data on each channel!!!!')
    dataProj = dataRaw - laplaWeights*dataRaw;
elseif nDims == 3                       % for data organized in trials
    disp('Applied laplacian to denoise the data on each channel and trial!!!!')
    nTrials = size(dataRaw,2);
    dataProj = nan(size(dataRaw));      % pre-allocate memory
    for iTrial = 1:nTrials
        dataProj(:,iTrial,:) = squeeze(dataRaw(:,iTrial,:)) - laplaWeights*squeeze(dataRaw(:,iTrial,:));
    end
else
    error('The dimensionality of the input vble ''dataRaw'' doe not match!')
end


end