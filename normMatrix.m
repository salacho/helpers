function [dataOut,dataNorm] = normMatrix(dataIn,typeNorm)
% function [dataOut,dataNorm] = normMatrix(dataIn,typeNorm)
%
% Computes the norm of a matrix or several matrices 'dataNorm' using 'typeNorm'
% string, and normalizes 'dataIn' matrix using 'dataNorm'. 
%
% INPUT
% dataIn:       matrix. Can be 2-D or 3-D. Usually used to compute L1-norm
%               of covariance matrices for Riemman Decoder. 
% typeNorm:     string. If 'none' gives a norm = 1;
%
% OUTPUT
% dataOut:      matrix(ces). Is dataIn with the norm applied to its values.
% dataNorm:     double or vector (matrix or matrices). Norm of the
%               matrix(ces) using the typeNorm approach
% 
% Andres    :   v1      : int. 2 Dec 2015

if strcmpi(typeNorm,'none')
    dataNorm = 1;
    dataOut = dataIn; 
else
    numDims = ndims(dataIn);
    dataOut = nan(size(dataIn));
    % For several trials
    if numDims == 3
        nTrials = size(dataIn,3);
        dataNorm = nan(1,nTrials);
        for iTrial = 1:nTrials, 
            dataNorm(iTrial) = norm(squeeze(dataIn(:,:,iTrial)),typeNorm); 
            dataOut(:,:,iTrial) = dataIn(:,:,iTrial)/dataNorm(iTrial);
        end
    % for one trial    
    elseif numDims == 2, 
        dataNorm = norm(dataIn,typeNorm);
        dataOut = dataIn/dataNorm;
    end
end

end
