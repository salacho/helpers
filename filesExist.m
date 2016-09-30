function filesExistLog = filesExist(sessionList,fileFolder,filename)
% function filesExistLog = filesExist(sessionList,fileFolder,filename)
%
% Evals if files exist or not.
%
% sessionList = scenarioSessionList
%
% Andres    :       v1 :        init. 29 Sep 2016. 

nIter = numel(sessionList);
filesExistLog =  zeros(nIter,1);

for iIter = 1:nIter
    % real subject number in filenames saved in cluster
    iSubj = sessionList(iIter);
    loadFilename = fullfile(fileFolder,sprintf('%s%i.mat',filename,iSubj));
    filesExistLog(iIter) = exist(loadFilename,'file')/2;
end

end