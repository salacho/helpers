function [svdTrainingX,svdTestX,nSV,Mx] = dataSVD(trainingX, testX, nSV, mxSVD)
%function [svdTrainingX,svdTestX,nSV,Mx] = dataSVD(trainingX, testX, nSV, mxSVD)
%
% Singular Value Decomposition of neural data. nSV determines the rank (or
% number of singular vectors) used to project training and testing data to.
% mxSVD is a logical flag that usually is set to TRUE in order to use the
% template projection matrix Mx. If set to FALSE, the dimensionality
% reduction is applied only to the training data.
% 
% INPUTS:
% trainingX     matrix. Training dataset in the form [nTrails x numFeatures]
% testX         matrix. Set of testing data in the form [nTestTrials x numFeatures]
% nSV           integer. Number of modes to use after SVD calculations
% mxSVD         logical. Use template modes matrix Mx to reduce DIM as (Markowitz et al. JNeurosc 2011). 
%               If false, a DIM reduced trainingX is used to train decoder but no Mx projection is used for testing.
%
% OUTPUTS:
% svdTrainingX  matrix. Training dataset with number of features reduced by nSV
% svdTestX      matrix. Set of testing data with number of features reduced by nSV
% nSV           integer. number of modes to use after SVD calculations
% Mx            matrix. Template matrix to project features to reduced dimension
%
% Created: 19 March 2013
% Last modified: 28 March 2013

%% Getting template matrix (Mx) to project most significant (nSV) singular vectors (dim reduction) 

% Checking desired rank < number of features
if nSV > size(trainingX,2)        % No point for rank to be larger than number of features
    disp(sprintf('SVD rank (%i) is larger than the total number of features (%i). \nChanging rank to max. number of features.',nSV,size(trainingX,2)));
    nSV = size(trainingX,2);
end
disp(sprintf('\nDimensionality reduction: \tSVD rank: %i\n',nSV))

%% Reducing trainingX and testX data after applying SVD
if mxSVD
    %tStartXX = tic;
    trainingXX = trainingX*trainingX';              % Training data inner product -> nTrainTrials x nTrainTrials
    %tEndXX = toc(tStartXX);
    %disp(sprintf('Square trainingX matrix calculation took %0.2f seconds.',tEndXX));
    
    tStartSVD = tic;
    [~,Sx,Vx] = svd(trainingXX,0);                  % Singular Value Decomposition. [Ux,Sx,Vx] = svd(trainingXX,'econ') % with nTrials<nCov. If trainingXX too big!
    timeSVD = toc(tStartSVD);
    disp(sprintf('SVD of square trainingX matrix took %0.2f seconds.',timeSVD))
    
    % Creating template matrix M: feature extraction & DIM reduction
    Mx = (trainingX')*Vx(:,1:nSV);                  % Feature Modes of trainingX calculated by projecting trainingX onto the first nSV singular vectors
    
    % Projecting nSV singular vectors of trainingX and testX to reduce its DIM
    svdTrainingX = trainingX*Mx;
    svdTestX = testX*Mx;
else
    %For trainingX
    [Ux,Sx,Vx] = svd(trainingX,0);
    svdTrainingX = Ux(:,1:nSV)*Sx(1:nSV,1:nSV)*Vx(:,1:nSV)';
    %For testX
    [Ux,Sx,Vx] = svd(testX,0);
    svdTestX = Ux(:,1:nSV)*Sx(1:nSV,1:nSV)*Vx(:,1:nSV)';
    Mx = 1;                                         % Template Modes matrix. Mx = 1 if no projection Mx applied to testX data
end

%% TODO Checking Mean Representation Accuracy as a result of DIM reduction
% gamma = 0.5;
% mag_svol = cumsum(Sx)./sum(Sx);
% [min,p] = min(abs(gamma-mag_svol));

% [U,D,V] = svd(trainingX);
% U3=U(:,1:nSV);                 
% aveRepAcc = trace(trainingX'*(U3)*U3'*trainingX)/trace(trainingX'*trainingX);
% 
% [U,D,V] = svd(testX);
% U3=U(:,1:nSV);                 
% aveRepAcc = trace(testX'*(U3)*U3'*testX)/trace(testX'*testX);
% 
% figure;hist(aveRepAcc,20);grid; 
% xlabel('Mean Representation Accuracy');
% title('Mean Representation Accuracy as a result of reduction')
