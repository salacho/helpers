function CRinfo = getBehavDur(CRinfo)
% function CRinfo = getBehavDur(CRinfo)
%
% For Jonah's the Behav structure in CRinfo does not have the field 'dur',
% which contains the length (in time) of the different parts of the trial.
%
% INPUT
% CRinfo:   structure with the session and the directories where the files
%           are. Also the field Behav, lacking nested, the field 'dur'.
% OUTPUT
% CRinfo:   The structure Behav is updated, now it has the field 'dur'.
%
%     Behav.dur.itiDur:             seconds. time inter-trial interval.
%     Behav.dur.waitFixDur:         seconds. max. time to acquire fixation.
%     Behav.dur.holdFixDur:         seconds. time fixation has to be held before presenting the cue.
%     Behav.dur.cueDur:             seconds. time the cue is diplayed.
%     Behav.dur.maxRt:              seconds. max. time to wait until the eyes leave the fixation point.              
%     Behav.dur.maxSacc:            seconds. maximum time to wait that a saccade occurred.
%     Behav.dur.holdTargetDur:      seconds. time the monkey has to hold the target after selection. 
%     Behav.dur.postRespInterval:   seconds. time post response that is held the fixation point.   
%     Behav.dur.punNoFixDur:        seconds. timeout for no fixation acquired.
%     Behav.dur.punBrkFixDur:       seconds. timeout for breaking fixation.
%     Behav.dur.rwdStimDur:         seconds. time visual cue stays when correct target is selected. 
%     Behav.dur.punChcStimDur:      seconds. time visual stim. stays when incorrect target selected.
%     Behav.dur.punChcTimeOut:      seconds. time of timeout after an incorrect target is selected.      
%     Behav.dur.rwds:               [volt, seconds, seconds]. Time the reward relay is open the first time (1), time the reward relay is open second time (2).
%     Behav.dur.dlyDur:             seconds. Length of the delay.
%     Behav.dur.goDlyDur:           seconds. Length of GO delay (when the end of the delay does not mean the target can be acquired/hunted)
%
% Andres Salazar 
% Created: Nov 2013. 
% Last modified: 19 Feb 2014.

% As a safety measure in case the bhv file do not exist for the current
% session, use the ones from tmpSession. Otherwise the code will load the
% previously one giving weird results
if strcmpi(CRinfo.session(1),'c')
    tmpSession = 'CS20121012';
    monkeyName = 'chico';
elseif strcmpi(CRinfo.session(1),'j')
    tmpSession = 'JS20131022';
    monkeyName = 'jonah';
end

%% Loading PTB bhv. All monitor dimensions are in dva, not cm nor pixels
fprintf('Loading psychToolbox bhv file from the %s raw folder...\n',CRinfo.session)
Bhv.Path = fullfile(CRinfo.dirs.DataIn(1:end-4),'raw',CRinfo.session);
Bhv.CurrentPath = pwd; cd(Bhv.Path);
Bhv.Name        = dir([monkeyName,'Bhv*']);         % Behavioral files
% Solving problems when more than one Hdw or Bhv file exists
Res.Name        = dir([monkeyName,'Res*']);         % Results files from PTB. This is the commmon naming format the Bhv and Hdw files should have. Just replace 'Res' with 'Bhv' or 'Hdw'.

% Checking the file exist or using replace session
if ~isempty(Bhv.Name(end))
    if length(Bhv.Name) == 1
        load(Bhv.Name.name); cd(Bhv.CurrentPath);
    else
        resBhv.Name.name = strrep(Res.Name.name,'Res','Bhv');
        load(resBhv.Name.name); cd(Bhv.CurrentPath);
    end
    clear Bhv resBhv
else
    % Using a session that has the bhv files
    Bhv.Path = fullfile(CRinfo.dirs.DataIn(1:end-4),'raw',tmpSession);
    Bhv.CurrentPath = pwd; cd(Bhv.Path);
    Bhv.Name = dir([monkeyName,'Bhv*']);
    load(Bhv.Name.name); cd(Bhv.CurrentPath),
    warning('No file with the string ''Bhv'' was found in %s\nUsing the one with ''Bhv'' for session %s instead...',Bhv.Path,tmpSession) %#ok<WNTAG>
    clear Bhv
end

% Updating CRinfo.Behav with the fields in 'dur'
CRinfo.Behav.dur.itiDur             = bhv.itiDur;
CRinfo.Behav.dur.waitFixDur         = bhv.waitFixDur;
CRinfo.Behav.dur.holdFixDur         = bhv.holdFixDur;
CRinfo.Behav.dur.cueDur             = bhv.cueDur;
CRinfo.Behav.dur.dlyDur             = nan;                    % to set in the proper order and to use in case the wrong delayDur vaule is used.
CRinfo.Behav.dur.maxRt              = bhv.maxRt;
CRinfo.Behav.dur.maxSacc            = bhv.maxSacc;
CRinfo.Behav.dur.holdTargetDur      = bhv.holdTargetDur;
CRinfo.Behav.dur.postRespInterval   = bhv.postRespInterval;
CRinfo.Behav.dur.punNoFixDur        = bhv.punNoFixDur;
CRinfo.Behav.dur.punBrkFixDur       = bhv.punBrkFixDur;
CRinfo.Behav.dur.rwdStimDur         = bhv.rwdStimDur;
CRinfo.Behav.dur.punChcStimDur      = bhv.punChcStimDur;
CRinfo.Behav.dur.punChcTimeOut      = bhv.punChcTimeOut;
CRinfo.Behav.dur.rwds               = bhv.rwds;

% Add these two fields, that are in Chico but not in Jonah, with mock values
if isfield(bhv,'dlyDur')
    CRinfo.Behav.dur.dlyDur         = bhv.dlyDur;
    CRinfo.Behav.dur.trainDlyDur    = bhv.dlyDur;       % Since training and testing delay used to be the same
else
    CRinfo.Behav.dur.dlyDur         = bhv.test.dlyDur;
    CRinfo.Behav.dur.trainDlyDur    = bhv.train.dlyDur;
end

CRinfo.Behav.dur.goDlyDur = 0;

