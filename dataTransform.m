function [corrEpochsTrans,incorrEpochsTrans] = dataTransform(corrEpochsProc,incorrEpochsProc,dataTransf)
% function [corrEpochsTrans,incorrEpochsTrans] = dataTransform(corrEpochsProc,incorrEpochsProc,dataTransf)
%
% Transforms data using the dataTransf criteria. Can be 'zcore' each trial or do nothing.
%
% INPUT
% corrEpochsProc:       matrix. [nchs, nTrials, nSamps]. Correct trials.  
%                       Already processed data (already passed through the eegSignalProces).
% incorrEpochsProc:     matrix. [nchs, nTrials, nSamps]. Incorrect trials. 
%                       Already processed data (already passed through the eegSignalProces),
% dataTransf:           string. Can be 'none', 'zscore', 
% 
% OUTPUT
% corrEpochsTrans:      matrix. [nchs, nTrials, nSamps]. Correct trials processed using the dataTransf function.  
% incorrEpochsTrans:    matrix. [nchs, nTrials, nSamps]. Incorrect trials processed using the dataTransf function.  
%
% Andres    :   v1  : init. 16 Oct 2015

switch dataTransf
    case 'zscore'
        corrEpochsTrans = zScoreData(corrEpochsProc);
        incorrEpochsTrans = zScoreData(incorrEpochsProc);
    case 'none'
        corrEpochsTrans = corrEpochsProc;
        incorrEpochsTrans = incorrEpochsProc;
    otherwise
        error('Data transformation %s not available!!!',dataTransf)
end

end