function [CRinfo] = goodDecodTrls(CRinfo,bhvEv)
% function [CRIinfo] = goodDecodTrls(CRIinfo,bhv)
%
% Gets logical vectors for the correct and decoder/brain-controlled trials
%
% Author    : Andres
%
% andres    : 1.1   : initial. 17 September 2012
% andres    : 1.2   : changed trialInfo to BCItrialInfo. Removed TrainOrTest test to avoid confusion. 
%                     Added 'numBlks'. Included option for session with only testing trials. 26 Feb 2014

% Pre-May 22 2012 files (delay saccade using six different eccentricities -36 targets-),
if CRinfo.filedate < 20120523
    % Choosing targets for one eccentricity
    targets = [1:6; 7:12; 13:18; 19:24; 25:30; 31:36];
    eccTargets = targets(CRinfo.BCIparams.eccent,:);
    % Trials to use = intersection of correct trials (outcome = 1) &
    % trials from the center-out (first) block & trials with targets at desired eccentricity
    %% Get correct trials
    goodTrials  = (bhvEv.EventInfo.ResponseError == 1) & ...
        (bhvEv.EventInfo.BlockNumber == 1) & ...
        ismember(bhvEv.EventInfo.ExpectedResponse,eccTargets);
    
    %% Get Decoder-controlled Trials
    CorrIncorrTrials = (bhvEv.EventInfo.ResponseError == 1 | bhvEv.EventInfo.ResponseError == 7) & ...
        (bhvEv.EventInfo.BlockNumber == 1) & ismember(bhvEv.EventInfo.ExpectedResponse,eccTargets);
    
    %% Get correct trials
    IncorrTrials  = (bhvEv.EventInfo.ResponseError == 7) & ...
        (bhvEv.EventInfo.BlockNumber == 1) & ...
        ismember(bhvEv.EventInfo.ExpectedResponse,eccTargets);
    
    % Post-May 22 2012 files (delay saccade, fixed radius -6 targets-)
else
    % Forcing eccentricity to be 1 since only targets from 1-6 are presented in these paradigm
    CRinfo.BCIparams.eccent = 1;
    % Trials to use = correct trials (outcome = 1)
    goodTrials = (bhvEv.EventInfo.ResponseError == 1);
    % Trials to use = correct & incorrect trials (outcome = 1,7)
    CorrIncorrTrials = (bhvEv.EventInfo.ResponseError == 1 | bhvEv.EventInfo.ResponseError == 7);
    % Trials to use = incorrect responses
    IncorrTrials = (bhvEv.EventInfo.ResponseError == 7);
end

% If TrainOrTest exists
if  isfield(bhvEv.EventInfo,'TrainOrTest')
    TrainTrials = find(strcmp(bhvEv.EventInfo.TrainOrTest,'train'));
    if ~isempty(TrainTrials)
        lastTrainTrial = TrainTrials(end);
    else
        lastTrainTrial = [];
    end
else
%     AFSG (2014-02-26) 
%     % Pre-Nov 05 2012 used two -600 trials- testing blocks 
%     if CRinfo.filedate < 20121105
%         % Are the training trials (600) in the first 1000 trials
%         if bhvEv.EventInfo.nTrials - 1200 <= 1000
%             lastTrainTrial = bhvEv.EventInfo.nTrials - 1200;
%         else
%             lastTrainTrial = 1000;
%         end
%         % Nov 5 2012 and on, only one -600 trials- testing block
%     else
%         % Are the training trials (600) in the first 1000 trials
%         if bhvEv.EventInfo.nTrials - 600 <= 1000
%             lastTrainTrial = bhvEv.EventInfo.nTrials - 600;
%         else
%             lastTrainTrial = 1000;
%         end
%         disp('Not ready yet!')
%     end
warning('TrainOrTest field does not exist in bhvEv.''EventInfo''') %#ok<WNTAG>
end
CRinfo.BCItrialInfo.lastTrainTrial = lastTrainTrial;

%% For Test trials: adding zeros to the training trials. These are not decoder-controlled
% Initial values (we will changed them in the next 'if' statement)
TrainCorrIncorrTrials                       = CorrIncorrTrials;
goodTrainTrials                             = goodTrials;
TestCorrIncorrTrials                        = CorrIncorrTrials;
goodTestTrials                              = goodTrials;
IncorrTestTrials                            = IncorrTrials;

if isempty(CRinfo.BCItrialInfo.lastTrainTrial)
    TrainCorrIncorrTrials(:)                    = 0;        %correct incorrect trials during training
    goodTrainTrials(:)                          = 0;        %1s for correct training trials
else
    TrainCorrIncorrTrials(lastTrainTrial+1:end) = 0;        %correct incorrect trials during training
    goodTrainTrials(lastTrainTrial+1:end)       = 0;        %1s for correct training trials
    TestCorrIncorrTrials(1:lastTrainTrial)      = 0;        %1s for decoder controlled trials
    goodTestTrials(1:lastTrainTrial)            = 0;        %1s for correct test trials
    IncorrTestTrials(1:lastTrainTrial)          = 0;        %1s for incorrect test trials
end

% Saving values in structures
%BCIinfo.nGoodTrials = sum(goodTrials);
CRinfo.BCItrialInfo.goodTrials              = logical(goodTrials);              %Correct trials (training and testing)
CRinfo.BCItrialInfo.goodTrainTrials         = logical(goodTrainTrials);         %Correct trials training 
CRinfo.BCItrialInfo.goodTestTrials          = logical(goodTestTrials);          %Correct trials testing 
CRinfo.BCItrialInfo.CorrIncorrTrials        = logical(CorrIncorrTrials);        %Correct and incorrect trials training/testing
CRinfo.BCItrialInfo.TestCorrIncorrTrials    = logical(TestCorrIncorrTrials);    %Correct and incorrect trials for test block
CRinfo.BCItrialInfo.TrainCorrIncorrTrials   = logical(TrainCorrIncorrTrials);   %Correct and incorrect trials during training
CRinfo.BCItrialInfo.IncorrTestTrials        = logical(IncorrTestTrials);        %Incorrect test trials

%% Block number (training = 1, blocked targets = 2, random targets = 3)
%TODO: there should be a better way to know the number of trials for each
%block. Using the PTB setBhvParam_dlySaccBCI_chico?

CRinfo.BCItrialInfo.numBlks = length(unique(bhvEv.EventInfo.BlockNumber));
CRinfo.BCItrialInfo.BlockNum = bhvEv.EventInfo.BlockNumber;
CRinfo.BCItrialInfo.Blk1 = (CRinfo.BCItrialInfo.BlockNum == 1);
CRinfo.BCItrialInfo.Blk2 = (CRinfo.BCItrialInfo.BlockNum == 2);
CRinfo.BCItrialInfo.Blk3 = (CRinfo.BCItrialInfo.BlockNum == 3);

