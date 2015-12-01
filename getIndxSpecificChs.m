function indxChs = getIndxSpecificChs(subChs,allChs)
%
% Get index of specific chanbnels from a larger list usinf their name, i.e.
% 'AFz', 'Cz'
%
% INPUT
% subChs:       cell. List of names of the channels to select. i.e. {'Cz','Pz'}
% allChs:       cell. List of all the channel names. i.e. {'AFz',...,'Oz'}
%
% OUTPUT
% indxChs:      vector. List of indeces for the subChs in allChs. 
%
% Andres    :      v1   : init. 29 Nov. 2015
%
%
% subChs = ErrorInfo.signalProcess.centralChsListPz;
% allChs = ErrorInfo.layout.eegChLbls;


indxChs = nan(1,length(subChs));
for iCh = 1:length(subChs)          % Find position of channel labels on EEG data
    indxChs(iCh) = find(strcmpi(allChs,subChs{iCh}));
end


end