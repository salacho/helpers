function sessionNumBlocks = getNumBlocks(subjectID)
% function sessionNumBlocks = getNumBlocks(subjectID)
%
% Gets the total number of blocks for all the possible sessions available 
% for the subject 'subjectID'
%
% INPUT
% subjectID:    string. Must match code in 'helpers' folder
%               the code for chico is chicoBCIsessions
% 
% Author    : Andres
%
% andres    : 1.1   : initial

% Paths and directories
dirs = initErrDirs;               % Paths where all data is loaded from and where chronic Recordings analysis are saved

% Get all sessions for Chico

% For chico
if strcmp(subjectID,'chico')
    allSubjectSessionList = chicoBCIsessions;
else
    
end
nSessions = length(allSubjectSessionList);

% Initialize vbles
sessionNumBlocks = struct(   'sessions', allSubjectSessionList,...     % Sessions
                            'vals',     nan(nSessions,3),...        % Possible values taken by each block
                            'numBlcks', nan(nSessions,1));          % Total number of blocks

% Get values for all sessions
for iSes = 1:nSessions
    % Session
    session = allSubjectSessionList{iSes};
    fprintf('Calculating number of blocks for %s...\n',session)
    % load bhv files
    bhvEv = load([fullfile(dirs.DataIn,session,session),'-bhv.mat']);
    % Number of blocks
    sessionNumBlocks(iSes).vals      = (unique(bhvEv.EventInfo.BlockNumber));
    sessionNumBlocks(iSes).numBlcks  = length(sessionNumBlocks(iSes).vals);
end

plot([sessionNumBlock.numBlcks])