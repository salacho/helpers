function laplaWeightsMatrix = getSessionLaplaWeights(session)
% function  laplaWeightsMatrix = getSessionLaplaWeights(session)
%
% Calculates the laplacian matrix using the session name. 
%
%
% Andres    :   v1  : init. 10 Sept 2015

% To apply laplacian reref
% [xyDist,normDist,~] = getLayoutWeighNearNeigh(ErrorInfo,false);
%laplaWeightsMatrix = getLaplacianWeightsMatrix(normDist)
% eegRefMatrix = eegY - laplaWeightsMatrix*eegY;
% laplaWeightsMatrix

clc, close all

dirs = eegBaxterDirs('eegBaxter'); 
mainParams = eegBaxterSetDefaultParams(session,0,dirs,1,'eegBaxter');    % For eegBaxterMain.m and binaryBCI.m decodeOnly must be false; mainParams.epochInfo.decodOnly = 0;  % Not only decoding trials since now no decoding is happening.
% Get ErrorInfo
[corrEpochs,incorrEpochs,lureEpochs,ErrorInfo,baxter1stEpochs,baxter2ndEpochs,EventInfo] = ...
    eegBaxterLoadErrPs(mainParams); %#ok<*ASGLU,*NASGU>

[xyDist,normDist,~] = getLayoutWeighNearNeigh(ErrorInfo,false);
laplaWeightsMatrix = getLaplacianWeightsMatrix(normDist);

end