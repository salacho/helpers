function [CRinfo,OutcomeInfo] = getOutcmInfo(CRinfo,blockType,decodOnly)
% function [CRinfo,OutcomeInfo] = getOutcmInfo(CRinfo,blockType,decodOnly)
%
% This code uses 'goodDecodTrls.m' and 'errorEvts.m' to obtain all events
% and info related to all possible outcomes during the recordings (error),
% hence the name ErrorInfo. This function occurs after defining BCIinfo
% with field dirs pointing to data and save folders. See 'iniDirs.m'; for
% more info.
%
% INPUT
% CRinfo:                   Chronic Recording info structure. Has field to dirs
%     session               string. session
%     filedate              integer. Date of 'session' in the form YYYYMMDD
%     dirs.DataIn           string. Dir w/ datafiles. Mapping server using SFTP Net Drive
%     dirs.DataOut          string. Local Dir to output analyzed datafiles and figures too
%     dirs.saveFilename     string. Path where files are saved 
% blockType:                [0-3]. block of the session to get OutcmInfo 
%                           from (to be analyzed). 0 for all blocks, 1 for 
%                           'train' data, 2 for 'blocked' test, 3 for 
%                           'random' test data.
% decodOnly:                logical. True if only trials brain-controlled.
%                           Does not care what blockType is; if chosen block 
%                           is 'train' (1) and decodOnly is true, no 
%                           trials will be extracted. 
% 
% OUTPUT
% OutcomeInfo:              Structure with the following vector/cells:
%     TimeUnits:            'ms'
%     nTrials:              Total number of trials
%     lastTrainTrial:       Last trial in the training block. Used to have
%                           access to only decoder-controlled trials.
%     outcmLbl:               Vector [7x1]. Number for that outcome.
%     outcmTxt:               String. Name of the different outcomes ('correct',
%                           'noFix','fixBreak','sacMaxRt','sacNoTrgt','sacBrk',
%                           'inCorrect').
%     noutcms:                String. Vector with total number of trials for 
%                           each outcome.
%     block:                String. Informs if trials used were from the first, 
%                           second or third block ('Train','Blocked', 'Random' 
%                           respectively). If all blockes are used 'All' is used instead.  
%     nGoodTrls:            Number of good trials.
%     BCtrials:             Brain/decoder-controlled trials
%     BCcode:               EventCode for BC trials. For eye-controlled it is 5001. 
%                           Refer to 'setBhvParam_dlySaccBCI_chico.m', check for 
%                           bhv.event.controlSrc = (1:2)+5000; --> 1=eye, 2=brain/decoder
%     outcm%i:                Structure with times for different events for 
%                           outcome i (from 1 to 7). The vector/cells are: 
% 
%         outcmTrials:      logical vector for the trials for this outcome
%         outcmDecoder:     logical. Decoder-controlled trials (omits the first block - training) 
%         trlNum            Trial number in PTB ;
%         TrialStartTimes:  Times for beginning of trial
%         SampleStartTime:  
%         ExpectedResponse: Expected response  
%         Response:         Response given by the decoder/NHP
%         ReactionTime:     Time between removal of fixation point and
%                           saccade onset
%         RespErrorTime:    Time when last event was collected (upon the 
%                           ocurrence of an error)  
%         BlockNumber:      Block number. 1 for training, 2 for blocked trials, 
%                           3 for randomly presented targets
%         DelayOnsetTime:   Time when delay started  
%         DelayOffsetTime:  End of delay
%         itiOnsetTime:     Start of InterTrial Interval
%         FixationOnsetTime: Fixation spot on (end of ITI) (2 for cntr-out vsn; 200+1:#fixpt's for converge vsn)
%         TargetOnsetTime:  Spatial cue (saccade target) onset
%         SaccadeOnsetTime: Saccade onset/start (timestamped as eye leaves fixation window)
%         SaccadeOffsetTime:Saccade offset/end (timestamped as eye enters saccade window around saccade target)
%         SaccadeEndptLoc:  Location of saccade target. All seem to be 12.5
%         SaccadeVector:    Location of saccade vector. All seem to be 12.5
%         FixpointLoc:      Location of fixation point. Distance from
%                           center point.
%         TrainOrTest:      cell with 'train' or 'test' for each trial
%         rwdStimOn:        vector. Time reward stimulus (secondary) onset
%         punChc:           vector. Time punishment stimulus onset
%         BCtrial:          logical, 1 for brain/decoder-controlled trials
%         nTrials:          Number of trials for this outcome (error) 
%
% CRIinfo:                  Chronic Recording info structure. Added field 'pupilometry.BCtrials'
%                           Logical with 1s only for Brain-Controlled trials
%
% Author    : Andres
%
% andres    : 1.1   : initial
% andres    : 1.2   : changed trialInfo to BCItrialInfo. 26 Feb 2014

% Default values for decodOnly and blockType
if nargin == 1
    blockType = 0;
    decodOnly = false;
elseif nargin == 2
    warning('Setting decodOnly vble to false as default')
    decodOnly = false;
end
    
%% Loading files
% load bhv files
bhvEv = load([fullfile(CRinfo.dirs.DataIn,CRinfo.session,CRinfo.session),'-bhv.mat']);
%disp(bhvEv)
CRinfo.Behav = bhvEv.EventInfo.Behav;
CRinfo.EventInfo = bhvEv.EventInfo;

% Checking structure 'dur' IS contained in CRinfo.Behav structure. The 
% field 'dur' has the  length (in time) of the different parts of the trial.
if ~isfield(CRinfo.Behav,'dur')
    warning('Did not find the ''dur'' field in CRinfo.Behav!!!') %#ok<WNTAG>
    disp('Updating the Behav structure with the field ''dur'', with the times for the parts of a trial.')
    CRinfo = getBehavDur(CRinfo);
end

%% Target Locations & Eccentricity
% Verifying events were properly obtained, 'dlyscc' or 'cvm' in Behav structure
if ~mod(length(bhvEv.EventInfo.Behav.taskIDs),2) 
    CRinfo.BCIparams.nLocations    = 6;             %Overall number of target locations to analyze
    CRinfo.BCIparams.eccent        = 5;             %Eccentricity for files before May 23. [1:6] 1 closest, 6 farthest
    if CRinfo.filedate >= 20120523                  %Forcing eccentricity to be 1 since only targets from 1-6 are presented in these paradigm
        CRinfo.BCIparams.eccent      = 1;
    end
    % For dlySacc extract all tested target directions (in radians)
    CRinfo.BCIparams.tgtDirections = bhvEv.EventInfo.Behav.CntrOut.tgtLocsPolar(:,2) .* pi/180;
    
elseif strcmpi(bhvEv.EventInfo.Behav.taskIDs(1),'cvm')
    % For cvm
    warning('The event codes were obtained using a Behav structure based on the %s experiment, not the dlySacc.',char(bhvEv.EventInfo.Behav.taskIDs(1)));
    CRinfo.BCIparams.nLocations    = bhvEv.EventInfo.Behav.numSaccTrgts;            %Overall number of target locations to analyze
    CRinfo.BCIparams.eccent        = bhvEv.EventInfo.Behav.numVisCues/bhvEv.EventInfo.Behav.numSaccTrgts;   %Eccentricity for files before May 23. [1:6] 1 closest, 6 farthest
    % For cvm extract all tested target directions (in radians)
    CRinfo.BCIparams.tgtDirections = bhvEv.EventInfo.Behav.saccTrgtAng .* pi/180;
end

CRinfo.BCIparams.paradigm = bhvEv.EventInfo.Behav.paradigm;

%% Getting correct and incorrect trials, goodTrials and trials for each block
CRinfo = goodDecodTrls(CRinfo,bhvEv);

%% Getting all events for each error (including option for decoder-controlled only)
% Getting timestamps for each error type and BC and eye-controlled trials
CRinfo.BCItrialInfo.trlNum      = 12000:14500;      %number to substract to get the real trial number. Refer to 'setBCIParams.m', bci.event.trlNum 
CRinfo.BCItrialInfo.BCcode      = 5002;             %EventCode for BC trials. For eye-controlled it is 5001. Refer to 'setBhvParam_dlySaccBCI_chico.m', check for bhv.event.controlSrc = (1:2)+5000; --> 1=eye, 2=brain/decoder
CRinfo.BCItrialInfo.decodOnly   = decodOnly;        %Gets vent values only for decoder/brain-controlled trials         
CRinfo.BCItrialInfo.block       = blockType;        %block of the session analyzed. 0 for all blocks, 1 for 'train' data, 2 for 'blocked' test, 3 for 'random' test data.
[CRinfo,OutcomeInfo,~]          = outcomeEvts(CRinfo,bhvEv);

%% Info for good/test trials in 'BCItrialInfo' structure for loadEyeTraces
%CRinfo.BCItrialInfo
