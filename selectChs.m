function [nChs,chList] = selectChs(ErrorInfo)
% function [nChs,chList] = selectChs(ErrorInfo)
%
% Finds the total number of channels available after selecting those registered by ErrorInfo.signalProces.ampsOrChLbls 
%
%
% Andres    :   v1  : init. 17 Oct. 2015


%% Main processing parameters
Fs              = ErrorInfo.epochInfo.Fs;                       % Sampling frequency
dcdWindow       = ErrorInfo.signalProcess.dcdWindow/1000;       % Boundaries (changed from seconds to ms) for data window used for decoding (with respect to feedback onset)
% epochLen        = ErrorInfo.signalProcess.dcdEpochLen/1000;   % from ms to seconds. Length of data used for decoding
baselineZero    = ErrorInfo.signalProcess.baselineZero/1000;    % Since Baxter has a delay due to the Arduino, usually 100 ms, the feedback onset time is actually delayed 100 ms.
% BaselineZero is the delay given by the arduino
baselineTime    = ErrorInfo.signalProcess.baselineLen/1000;     % Data length to take baseline from (in ms)
preStimTime     = ErrorInfo.epochInfo.preOutcomeTime/1000;      % Data length before stimulus presentation
rmvBaseline     = ErrorInfo.epochInfo.rmvBaseline;              % Flag setting if baseline is removed
rmvBaseDone     = ErrorInfo.epochInfo.rmvBaseDone;              % Flag used when baseline has been removed
ampsOrChLbls    = ErrorInfo.signalProcess.ampsOrChLbls;         % use amplifiers or channel labels to select channels
amps            = ErrorInfo.signalProcess.amps;                 % amplifiers used for analysis from now on.
chLbls          = ErrorInfo.signalProcess.chLbls;               % labels of channels to be used from now on.
medialChsList   = ErrorInfo.signalProcess.medialChsList;        % list of channels in the medial area usefull for decoding ErrPs 5x4
centralChsList  = ErrorInfo.signalProcess.centralChsList;       % list of channels in the central area usefull for decoding ErrPs 4x2 chs 
centralChsListPz = ErrorInfo.signalProcess.centralChsListPz;    % list of channels in the central area usefull for decoding ErrPs including Pz 4x2 + 1
pzChlbls        = ErrorInfo.signalProcess.pzChlbls;             % FCz, Cz, Pz   
chs2Remove      = ErrorInfo.signalProcess.chs2Remove;           % Channels to remove always from data. When almost all channels are used except a few already label
% badChStDevFactor = ErrorInfo.signalProcess.badChStDevFactor;    % factor used to assess if channels is noisy or not! factor to multiply with the standard deviation.

%% Choosing channels from arrays
sgnChs  = [];            	% List of all the chosen channels
switch lower(ampsOrChLbls)
    case 'amps',
        for iAmps = 1:length(amps)          % Channels from amplifier
            sgnChs  = [sgnChs ,(1:16) + (amps(iAmps)-1)*16]; %#ok<*AGROW>
        end
    case 'chlbls'
        for iCh = 1:length(chLbls)          % Find position of channel labels on EEG data
            sgnChs(iCh) = find(strcmpi(ErrorInfo.layout.eegChLbls,chLbls{iCh}));
        end
    case 'pzchlbls'
        for iCh = 1:length(pzChlbls)          % Find position of channel labels on EEG data
            sgnChs(iCh) = find(strcmpi(ErrorInfo.layout.eegChLbls,pzChlbls{iCh}));
        end
    case {'all chs','allchs'}
        sgnChs = 1:ErrorInfo.nChs;
    case 'bipolar'
        if ~ErrorInfo.signalProcess.doneBipolarMontage
            error('Calculate number of bipolar channels here!!')
            sgnChs = ErrorInfo.nChs;
            warning('...keep in mind the list of channels in bipolar montage also affects the plotting and maybe the feature selection process...')
            % the list of channels in bipolar montage also affects the
            % plotting and maybe the feature selection process
        else warning('Bipolar montage already calculated!!!')
        end
    case 'medialchs'
        % channels from the medial line to avoid those near the eyes,
        % temporal (which does not fit well cap), or occipital. Mainly for
        % decoding of ErrPs. 5x4
        
        for iCh = 1:length(medialChsList)          % Find position of channel labels on EEG data
            sgnChs(iCh) = find(strcmpi(ErrorInfo.layout.eegChLbls,medialChsList{iCh}));
        end
    case 'centralchs'
        % channels from the central line to avoid those near the eyes,
        % temporal (which does not fit well cap), or occipital. Mainly for
        % decoding of ErrPs, 3x3
        
        for iCh = 1:length(centralChsList)          % Find position of channel labels on EEG data
            sgnChs(iCh) = find(strcmpi(ErrorInfo.layout.eegChLbls,centralChsList{iCh}));
        end
    case 'centralpzchs'
        % channels from the central line to avoid those near the eyes,
        % temporal (which does not fit well cap), or occipital. Mainly for
        % decoding of ErrPs, 3x3
        
        for iCh = 1:length(centralChsListPz)          % Find position of channel labels on EEG data
            sgnChs(iCh) = find(strcmpi(ErrorInfo.layout.eegChLbls,centralChsListPz{iCh}));
        end
    case 'chs2remove'
        % Almost all channels. Only remove the most frontal ones (remove
        % eye mvmts) and, T7 and T8 due to extreme noisy activity
        sgnChs = 1:ErrorInfo.nChs;
        indxSgnChs = ones(1,ErrorInfo.nChs);
        % Find channels to remove
        for iCh = 1:length(chs2Remove)          % Find position of channel labels on EEG data
            indx2Remove(iCh) = find(strcmpi(ErrorInfo.layout.eegChLbls,chs2Remove{iCh}));
        end    
        indxSgnChs(indx2Remove) = 0;
        sgnChs = sgnChs(find(sgnChs.*indxSgnChs));  %#ok<*FNDSB>
    otherwise
        error('The option ''%s'' is not available!!',ampsOrChLbls)
        disp('The channels selected are:'), fprintf('%i,',sgnChs) %#ok<*UNRCH>
end
% Needs to be sorted!! otherwise the ChList gets messed up!
sgnChs = sort(sgnChs);

% List of all the good channels
ErrorInfo.epochInfo.chList = ErrorInfo.epochInfo.chList(sgnChs);            % update the list of channels
chList = sort(ErrorInfo.epochInfo.chList);                                  % indeces of the channels used for analysis

nChs = length(chList);

end
