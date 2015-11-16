function dataValsTrans = matrixDiagTrans(dataVals,dataTrans)
% function dataValsTrans = matrixDiagTrans(dataVals)
%
% Replaces the values in the diagonal of the dataVals matrix (if dataVals
% has 3-D, [nChs nTrials1 nTrials2], entries indxTrials1 = indxTrials2)
% with the mean value from the rest of the matrix (per ch -> dim1)
%
% INPUT
% dataVals:         matrix. [nChs nTrials1 nTrials2]
% dataTrans:        string. Data transformation function to be used. Can be
%                   dataTrans = 'mean', 'median', 
% OUTPUT
% dataValsTrans:    matrix. [nChs nTrials1 nTrials2] Values in the diagonal replaced by the transform function. 
% 
%
% Andres    :   v1  : init. 11 Nov. 2013

if ndims(dataVals) == 3
    [nChs,nTrials1,nTrials2] = size(dataVals);
    % Pre-allocate memory
    dataValsTrans = dataVals;
    for iCh = 1:nChs
        %% For this channel only
        chVals = squeeze(dataVals(iCh,:,:));
        %subplot(3,1,1),imagesc(chVals), colorbar

        %% Replace diagonal vals with
        minTrials = min(nTrials1,nTrials2);
        for iTrial = 1:minTrials, chVals(iTrial,iTrial) = nan; end
        %subplot(3,1,2),imagesc(chVals), colorbar
        
        %% Find value to put in diagonal
        switch dataTrans
            case 'mean', chTrans = nanmean(nanmean(chVals));
            case 'median', chTrans = nanmedian(nanmedian(chVals));
        end
        %for iTrial = 1:minTrials, chVals(iTrial,iTrial) = chTrans; end, subplot(3,1,3),imagesc(chVals), colorbar

        %% Place value in diagonal
        for iTrial = 1:minTrials, dataValsTrans(iCh,iTrial,iTrial) = chTrans; end
    end
else error('Matrix does not have 3 dimensions!!!')
end


end              %% end function