function [CRinfo,OutcomeInfo,Event] = outcomeEvts(CRinfo,bhvEv)
%  function [CRinfo,OutcomeInfo,Event] = outcomeEvts(CRinfo,bhvEv)
% 
% Gets time stamps for different events related to all the possible
% outcomes, errors, incorrect and correct targets. Creates structure
% ErrorInfo with fields for each 7 different outcomes: 
%
% INPUT:
% CRinfo:                   Chronic Recording info structure. Has field to dirs
%     session               string. session
%     filedate              integer. Date of 'session' in the form YYYYMMDD
%     dirs.DataIn           string. Dir w/ datafiles. Mapping server using SFTP Net Drive
%     dirs.DataOut          string. Local Dir to output analyzed datafiles and figures too
%     dirs.saveFilename     string. Path where files are saved 
% bhvEv:                    Structure loaded form the session-bhv.mat file.
%
% OUTPUT:
% OutcomeInfo:              Structure with the following vector/cells:
%     TimeUnits:            'ms'
%     nTrials:              Total number of trials
%     lastTrainTrial:       Last trial in the training block. Used to have
%                           access to only decoder-controlled trials.
%     outcmLbl:             Vector [7x1]. Number for that outcome.
%     outcmTxt:             String. Name of the different outcomes ('correct',
%                           'noFix','fixBreak','sacMaxRt','sacNoTrgt','sacBrk',
%                           'inCorrect').
%     noutcms:              String. Vector with total number of trials for 
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
%         outcmDecoder:     decoder-controlled trials (omits the first block - training) 
%         trlNum            Trial number in PTB 
%         TrialStartTimes:  Times for beginning of trial
%         SampleStartTime:  
%         ExpectedResponse: Expected response  
%         Response:         Response given by the decoder/NHP
%         ReactionTime:     Time between removal of fixation point and
%                           saccade onset
%         RespErrorTime:    Time when last event was collected (upon the 
%                           ocurrence of an outcm)  
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
%         rwdStimOn:        vector. Time reward stimulus (secondary) onset
%         punChc:           vector. Time punishment stimulus onset
%                           center point.
%         nTrials:          Number of trials for this outcome 
%         BCtrial:          logical, 1 for brain/decoder-controlled trials
%         TrainOrTest:      same as BCtrial but using strings 'train' and 'test'.
%
% CRinfo:                   CR info structure. Added field 'pupilometry.BCtrials'
%                           Logical with 1s only for Brain-Controlled trials
% Event:                    Structure with the following vector/cells:  
%    BCcode:                Code for BCI paradigm. Usually is 5002
%    trlNum:                vector. Trial number matching PTB. Usually there is a gap between the last training trial and the first testing one. Ussually 1000.
%    BCtrials:              logical. One for trials that were brain-controlled (BC).
%    itiOnTime:             vector. Time for inter-trial-interval
%    fixOnTime:             vector. Time when fixation occurs.
%    spCueOnTime:           vector. Time when target is presented.
%    dlyOnTime:             vector. Time when delay onset starts
%    sacOnTime:             vector. Time when occurs saccade onset
%    sacOffTime:            vector. Time when occurs saccade offset
%    rwdStimOn:             vector. Time reward stimulus (secondary) onset
%    punChc:                vector. Time punishment stimulus onset
%    TrainOrTest:           cell, same size as the previous vectors. Has a string 'test' or 'train' labeling teach trial.
%    TrialStartTimes:       vector. Time when trial started
%    SampleStartTime:       vector. Same as spCueOnTime
%    ExpectedResponse:      vector. Values for the extected response (real, known target value)
%    Response:              vector. Values for the actual response (either saccade response or decoded target)
%    ReactionTime:          vector. Time between saccade onset and saccade offset
%    RespErrorTime:         vector. Time when response occured
%    DelayOnsetTime:        vector. Same as dlyOnTime , it is repeated
%    DelayOffsetTime:       vector. Time when delay offset occurs
%    SaccadeEndptLoc:       Matrix with the saccade end point location. [numTrials polar coord].
%    SaccadeVector:         Matrix. Saccade vector values [numTrials vector endpoints].
%    FixpointLoc:           Matrix. Fixation point location [numTrials polar coord].
%    TimeUnits:             'ms'.
%                     
% Author    : Andres
% 
% andres    : 1.1   : initial. Created Sept 2012 
% andres    : 1.2   : changed values to match ErrPs analysis. 24 July 2013
% andres    : 1.2   : changed trialInfo to BCItrialInfo. 26 Feb 2014

BCcode = CRinfo.BCItrialInfo.BCcode;
trlNum = CRinfo.BCItrialInfo.trlNum;

% Outcome analysis
OutcomeInfo.session     = CRinfo.session;
OutcomeInfo.TimeUnits   = bhvEv.EventInfo.TimeUnits;
OutcomeInfo.nTrials     = bhvEv.EventInfo.nTrials;
OutcomeInfo.outcmLbl    = cell2mat(bhvEv.EventInfo.Behav.outcomes(:,1));
OutcomeInfo.outcmTxt    = (bhvEv.EventInfo.Behav.outcomes(:,2));
OutcomeInfo.noutcms     = nan(1,length(OutcomeInfo.outcmTxt));

%% Getting the times (in milliseconds) for specific events in each trial
Event.session       = CRinfo.session;                   % subject/session
Event.BCcode        = BCcode;                           % EventCode for BC trials. For eye-controlled it is 5001. Refer to 'setBhvParam_dlySaccBCI_chico.m', check for bhv.event.controlSrc = (1:2)+5000; --> 1=eye, 2=brain/decoder
Event.trlNum        = nan(OutcomeInfo.nTrials,1);       % Trial numbers (actual trial number in PsychToolbox, not local count) 
Event.BCtrials      = zeros(OutcomeInfo.nTrials,1);     % Brain/decoder-controlled trials
Event.itiOnTime     = nan(OutcomeInfo.nTrials,1);       % Start of InterTrial Interval
Event.fixOnTime     = nan(OutcomeInfo.nTrials,1);       % Fixation spot on (end of ITI) (2 for cntr-out vsn; 200+1:#fixpt's for converge vsn)
Event.spCueOnTime   = nan(OutcomeInfo.nTrials,1);       % Spatial cue (saccade target) onset
Event.dlyOnTime     = nan(OutcomeInfo.nTrials,1);       % Sample stimulus offset/delay period onset
Event.sacOnTime     = nan(OutcomeInfo.nTrials,1);       % Saccade onset/start (timestamped as eye leaves fixation window)
Event.sacOffTime    = nan(OutcomeInfo.nTrials,1);       % Saccade offset/end (timestamped as eye enters saccade window around saccade target)
Event.rwdStimOn     = nan(OutcomeInfo.nTrials,1);       % Reward stimulus presentation onset
Event.juiceOn       = nan(OutcomeInfo.nTrials,1);       % Reward juice delivery onset
Event.punChc        = nan(OutcomeInfo.nTrials,1);       % Punishment stimulus presentation onset
Event.TrainOrTest   = nan(OutcomeInfo.nTrials,1);
Event.TrialStartTimes   = bhvEv.EventInfo.TrialStartTimes;
Event.SampleStartTime   = bhvEv.EventInfo.SampleStartTime;
Event.ExpectedResponse  = mod(bhvEv.EventInfo.ExpectedResponse - 1,CRinfo.BCIparams.nLocations) + 1;      % Changing target number to avoid th
Event.Response          = mod(bhvEv.EventInfo.Response - 1,CRinfo.BCIparams.nLocations) + 1;      % Changing target number to avoid th
Event.ReactionTime      = bhvEv.EventInfo.ReactionTime;
Event.RespErrorTime     = bhvEv.EventInfo.RespErrorTime;        % Timestamp of ResponseError code (NOTE: not a good est. of RT, but maybe useful to indicate end of fixbreak trials???)
Event.DelayOnsetTime    = bhvEv.EventInfo.DelayOnsetTime;
Event.DelayOffsetTime   = bhvEv.EventInfo.DelayOffsetTime;
Event.SaccadeEndptLoc   = bhvEv.EventInfo.SaccadeEndptLoc;
Event.SaccadeVector     = bhvEv.EventInfo.SaccadeVector;
Event.FixpointLoc       = bhvEv.EventInfo.FixpointLoc;
Event.TimeUnits         = bhvEv.EventInfo.TimeUnits;

for ii = 1:OutcomeInfo.nTrials
    ncodes = bhvEv.EvtIDTrial(ii,:);
%     % Trial start
%     if any(ismember(CRinfo.Behav.event.trialStart,ncodes))
%         [~,LOC] = ismember(CRinfo.Behav.event.trialStart,ncodes);
%         Event.TrialStart2(ii) = bhvEv.EvtTimesTrial(ii,LOC);
%     end
    % Start of InterTrial Interval
    if any(ismember(CRinfo.Behav.event.itiOn,ncodes))
        [~,LOC] = ismember(CRinfo.Behav.event.itiOn,ncodes);
        Event.itiOnTime(ii) = bhvEv.EvtTimesTrial(ii,LOC);
    end
    % Fixation spot on (end of ITI) (2 for cntr-out vsn; 200+1:#fixpt's for converge vsn)
    if any(ismember(CRinfo.Behav.event.fixOn,ncodes))
        [~,LOC] = ismember(CRinfo.Behav.event.fixOn,ncodes);
        Event.fixOnTime(ii) = bhvEv.EvtTimesTrial(ii,LOC(find(LOC)));
    end
    % Spatial cue (saccade target) onset
    if any(ismember(CRinfo.Behav.event.spCueOn,ncodes))
        [~,LOC] = ismember(CRinfo.Behav.event.spCueOn,ncodes);
        Event.spCueOnTime(ii) = bhvEv.EvtTimesTrial(ii,LOC(find(LOC)));
    end
    % Saccade onset/start (timestamped as eye leaves fixation window)
    if any(ismember(CRinfo.Behav.event.sacOn,ncodes))
        [~,LOC] = ismember(CRinfo.Behav.event.sacOn,ncodes);
        Event.sacOnTime(ii) = bhvEv.EvtTimesTrial(ii,LOC);
    end
    % Saccade offset/end (timestamped as eye enters saccade window around saccade target)
    if any(ismember(CRinfo.Behav.event.sacOff,ncodes))
        [~,LOC] = ismember(CRinfo.Behav.event.sacOff,ncodes);
        Event.sacOffTime(ii) = bhvEv.EvtTimesTrial(ii,LOC);
    end
    
    % Rwd juice stimulus on (timestamped as moment when juice rwd is delivered)
    if any(ismember(CRinfo.Behav.event.rwdOn,ncodes))
        [~,LOC] = ismember(CRinfo.Behav.event.rwdOn,ncodes);
        Event.juiceOn(ii) = bhvEv.EvtTimesTrial(ii,LOC);
    end
    
    % Rwd stimulus on (timestamped as moment when rwd stimulus is presented)
    if any(ismember(CRinfo.Behav.event.rwdStimOn,ncodes))
        [~,LOC] = ismember(CRinfo.Behav.event.rwdStimOn,ncodes);
        Event.rwdStimOn(ii) = bhvEv.EvtTimesTrial(ii,LOC);
    end
    % Error punisher stimulus onset
    if any(ismember(CRinfo.Behav.event.punChc,ncodes))
        [~,LOC] = ismember(CRinfo.Behav.event.punChc,ncodes);
        Event.punChc(ii) = bhvEv.EvtTimesTrial(ii,LOC);
    end
    %Trial numbers (actual trial number in PsychToolbox, not local count)
    if sum(ismember(trlNum,ncodes))         %Is Event.trialCode a number between 12001:14000?
        Event.trlNum(ii) = trlNum(ismember(trlNum,ncodes)) - trlNum(1);
    end
    % Is trial brain or eye-controlled?
    % In 'setBhvParam_dlySaccBCI_chico.m' the field 'controlSrc' in 'bhvEv.event' determines if BC or EC.
    % bhv.event.controlSrc = (1:2)+5000; --> Source of target-choice control on each trial: 1=eye, 2=brain/decoder
    if any(ismember(Event.BCcode,ncodes))
        Event.BCtrials(ii) = true;
    end
    %     disp(ncodes);
    %     disp(Event.BCtrials(ii));
    %     pause
    
    % Some values for Response are nans. Solving the problem
    if any(isnan(Event.Response(ii)))
        if any(ismember(CRinfo.Behav.event.chosenTrgt,ncodes))
            [~,LOC] = ismember(CRinfo.Behav.event.chosenTrgt,ncodes);
             RespVal = ncodes(LOC(find(LOC))) - 1000;
             Event.Response(ii) = mod(RespVal - 1,CRinfo.BCIparams.nLocations) + 1;         % resetting the val to be 1-6 not 1-18 due to the use of three blocks.
        end
    end
    
end

if isfield(bhvEv.EventInfo,'TrainOrTest')
    Event.TrainOrTest = bhvEv.EventInfo.TrainOrTest;
end

% if isfield(bhvEv.EventInfo,'ControlSrc');
%      Event.BCtrials2 = strcmp(bhvEv.EventInfo.ControlSrc,'brain');
% end

%% Getting trials for each outcm condition
for kk = 1:7; outcmTxt{kk} = sprintf('outcm%i',kk); end

for iOutcm = 1:length(OutcomeInfo.outcmLbl)
    iTxt = outcmTxt{iOutcm};
    % Calculating outcmTrials and outcmDecoder
    if iOutcm == 1
        outcmTrials = logical(CRinfo.BCItrialInfo.goodTrials);
        %outcmDecoder = logical(outcmTrials.*Event.BCtrials);
        %outcmDecoder = logical((CRinfo.BCItrialInfo.TestCorrIncorrTrials == CRinfo.BCItrialInfo.goodTrials).*Event.BCtrials);
    else
        outcmTrials = logical(OutcomeInfo.outcmLbl(iOutcm) == bhvEv.EventInfo.ResponseError);
        %outcmDecoder = logical(outcmTrials.*Event.BCtrials);
        %outcmDecoder = logical((CRinfo.BCItrialInfo.TestCorrIncorrTrials == outcmTrials).*Event.BCtrials);
    end
    
    outcmDecoder = logical(outcmTrials.*Event.BCtrials);
    % If only using trials controlled by decoder
    if CRinfo.BCItrialInfo.decodOnly
        outcmTrials = outcmDecoder; 
        OutcomeInfo.(iTxt).decodOnly = true;
    else
        OutcomeInfo.(iTxt).decodOnly = false;
    end
    
    % Choosing block to be analyzed
    switch CRinfo.BCItrialInfo.numBlks
        case 1
            % when only one block used, separated in training and testing but not numbered 1-3 blocks
            outcmBlock = 'All';
            warning('Adding all trials since only one block was found') %#ok<WNTAG>
        case 2
            % When the trials were training and random
            warning('Only two blocks: training and random') %#ok<WNTAG>
            switch CRinfo.BCItrialInfo.block
                case 0
                    outcmBlock = 'All';
                case 1
                    outcmTrials = outcmTrials.*CRinfo.BCItrialInfo.Blk1;
                    outcmBlock = 'Train';
                case 2
                    outcmTrials = outcmTrials.*CRinfo.BCItrialInfo.Blk2;
                    outcmBlock = 'Random';
            end
        case 3
            % When the trials were training, blocked, and random
            warning('All three blocks: training, blocked, and random') %#ok<WNTAG>
            switch CRinfo.BCItrialInfo.block
                case 0
                    outcmBlock = 'All';
                case 1
                    outcmTrials = outcmTrials.*CRinfo.BCItrialInfo.Blk1;
                    outcmBlock = 'Train';
                case 2
                    outcmTrials = outcmTrials.*CRinfo.BCItrialInfo.Blk2;
                    outcmBlock = 'Blocked';
                case 3
                    outcmTrials = outcmTrials.*CRinfo.BCItrialInfo.Blk3;
                    outcmBlock = 'Random';
            end
    end
    outcmTrials  = logical(outcmTrials);
    
    % Get all structure for each outcm
    OutcomeInfo.(iTxt).outcmTrials       = outcmTrials;
    OutcomeInfo.(iTxt).outcmDecoder      = outcmDecoder;                                                        % Decoder-controlled Trials for this outcm. Only applies to outcm1(correct) and outcm7(incorrect)
    OutcomeInfo.noutcms(iOutcm)          = sum(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).trlNum            = Event.trlNum(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).TrialStartTimes   = Event.TrialStartTimes(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).SampleStartTime   = Event.SampleStartTime(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).ExpectedResponse  = Event.ExpectedResponse(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).Response          = Event.Response(OutcomeInfo.(iTxt).outcmTrials);                % Could be wrong or right response
    %OutcomeInfo.(iTxt).ResponseTime     = Event.ResponseTime(OutcomeInfo.(iTxt).outcmTrials);            % The same as RespErrorTime
    OutcomeInfo.(iTxt).ReactionTime      = Event.ReactionTime(OutcomeInfo.(iTxt).outcmTrials);
    % Timestamp of ResponseError code (NOTE: not a good est. of RT, but maybe useful to indicate end of fixbreak trials???)
    OutcomeInfo.(iTxt).RespErrorTime     = Event.RespErrorTime(OutcomeInfo.(iTxt).outcmTrials);
    %OutcomeInfo.(iTxt).ConditionNumber = Event.ConditionNumber(OutcomeInfo.(iTxt).outcmTrials);
    %OutcomeInfo.(iTxt).TaskID = Event.TaskID(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).BlockNumber       = CRinfo.BCItrialInfo.BlockNum(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).DelayOnsetTime    = Event.DelayOnsetTime(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).DelayOffsetTime   = Event.DelayOffsetTime(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).itiOnsetTime      = Event.itiOnTime(OutcomeInfo.(iTxt).outcmTrials);               % Start of InterTrial Interval
    OutcomeInfo.(iTxt).FixationOnsetTime = Event.fixOnTime(OutcomeInfo.(iTxt).outcmTrials);               % Fixation spot on (end of ITI) (2 for cntr-out vsn; 200+1:#fixpt's for converge vsn)
    OutcomeInfo.(iTxt).TargetOnsetTime   = Event.spCueOnTime(OutcomeInfo.(iTxt).outcmTrials);             % Spatial cue (saccade target) onset
    OutcomeInfo.(iTxt).SaccadeOnsetTime  = Event.sacOnTime(OutcomeInfo.(iTxt).outcmTrials);               % Saccade onset/start (timestamped as eye leaves fixation window)
    OutcomeInfo.(iTxt).SaccadeOffsetTime = Event.sacOffTime(OutcomeInfo.(iTxt).outcmTrials);              % Saccade offset/end (timestamped as eye enters saccade window around saccade target)
    OutcomeInfo.(iTxt).rwdStimOn         = Event.rwdStimOn(OutcomeInfo.(iTxt).outcmTrials);               % Reward stimulus presentation onset
    OutcomeInfo.(iTxt).juiceOn           = Event.juiceOn(OutcomeInfo.(iTxt).outcmTrials);                 % Reward acknowledgement by juice delivery 
    OutcomeInfo.(iTxt).punChc            = Event.punChc(OutcomeInfo.(iTxt).outcmTrials);                  % Punishment stimulus presentation onset
    OutcomeInfo.(iTxt).SaccadeEndptLoc   = Event.SaccadeEndptLoc(OutcomeInfo.(iTxt).outcmTrials);                                                 % All seem to be 12.5
    OutcomeInfo.(iTxt).SaccadeVector     = Event.SaccadeVector(OutcomeInfo.(iTxt).outcmTrials);           % All seem to be 12.5
    OutcomeInfo.(iTxt).TrainOrTest       = Event.TrainOrTest(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).FixpointLoc       = Event.FixpointLoc(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).BCtrial           = Event.BCtrials(OutcomeInfo.(iTxt).outcmTrials);
    OutcomeInfo.(iTxt).nTrials           = sum(OutcomeInfo.(iTxt).outcmTrials);
end

OutcomeInfo.block           = outcmBlock;
OutcomeInfo.BCtrials        = Event.BCtrials;
CRinfo.BCItrialInfo.BCtrials   = Event.BCtrials;

% %% Typical task epoch durations
% Behav.dur.itiDur          = 3.00;       % iti duration
% Behav.dur.waitFixDur      = 2.50;       % max wait for fixation
% Behav.dur.holdFixDur      = 0.50;       % hold fixation period before cue stim comes on (change to 0.5?)
% Behav.dur.cueDur          = 0.35;       % duration of cue stimulus (image for cvm task, saccade trgt for dlysacc task) on screen
% Behav.dur.dlyDur          = 0.75;       % delay between cue stimulus offset and target array presentation
% Behav.dur.goDlyDur        =    0;       % delay between target array onset and the go cue
% Behav.dur.maxRt           = 0.25;       % maximum time to break central fixation after the go cue
% Behav.dur.maxSacc         = 0.10;       % maximum time to acquire target after the central fixation was broken
% Behav.dur.holdTargetDur   = 0.10;       % time necessary to hold fixation at the saccade-target at the end of the saccade
% Behav.dur.punNoFixDur     =    0;       % duration of punisher stimulus after no-fixation trials
% Behav.dur.punBrkFixDur    =    0;       % duration of punisher stimulus after fixation-break trials
% Behav.dur.rwdStimDur      = 0.50;       % duration of 2ndary reinforcer stim and chosen target presented dur rwd on correct trials
% Behav.dur.punChcStimDur   = 0.50;       % duration of 2ndary punishment stim and chosen target presented after choice outcms
% Behav.dur.punChcTimeOut   = 3.00;       % additional 'time-out' delay after choice error as negative reinforcer
% Behav.dur.rwds            = [2 .04 .01];% reward parameters [number of pulses, pulse-duration (s), pause btwn pulses(s)]

