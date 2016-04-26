function [niSession,niChs,clockSession,listHandle] = niCardConfigure(devNumber,niConfigParams)
% function [niSession,niChs,clockSession,listHandle] = niCardConfigure(devNumber,niConfigParams)
%
% Configures the selected NI cards based with the device number "devNumber"
% All parameters for the device configuration are in "niConfigParams"
%
% INPUT: 
% devNumber:        integer. Usually 1 if only one coard connected 
%                   BEWARE: I HAVE NOT TESTED devNumber WITH OTHER USB
%                   DEVICES besides a sound card (NI card still devNumber = 1)
% niConfigParams:   structure. Contains all the parameters to set a new
%                   session and configure the channels read/writen in the NI card
% OUTPUT
% niSession:        NI card session with all channels configure.
% niChs:            structure referencing the configuration of all
%                   available channels (which will read or writte data to -including triggers-)
% niData:           global variable with matrix of data points collected at the niTime values.
% niTime:           global variable with the times of events
% listHandle:       listener handle
% clockSession:   	object for the internal clock used for digital
%                   input/outputs
%
% Created 16 Jan 2014
% Last modified 24 Jan 2014
% Andres v.1

%% Put al parameter in specific locations to create the appropriate channels
% Display devices and select the USB-NI card
allDevices = daq.getDevices;
if length(allDevices) > 1
    tgtDev = allDevices(devNumber);
    disp(tgtDev)
else
    tgtDev = allDevices(1);
    disp(tgtDev);
end

%% Create NI recording session and add Analog Input Channels (from niChsID) from device niDevID to the session.

niSession = daq.createSession('ni');

% Analog Input
if niConfigParams.doAnalogInChns
    for iAch = 1:niConfigParams.numAIchs
        %niAIchs(iAch) = niSession.addAnalogInputChannel(niConfigParams.devID,niConfigParams.AIchsID(iAch), 'Voltage');
        niSession.addAnalogInputChannel(niConfigParams.devID,niConfigParams.AIchsID(iAch), 'Voltage');
        niSession.Channels(iAch).Range             = niConfigParams.ChsValRange;                % NI ADC range of input data [Min. Max.], can be [-10 10]
        niSession.Channels(iAch).TerminalConfig    = niConfigParams.TerminalConfig;    % Type of recording with respect to GND. Can be 'Differential', 'SingleEnded', 'SingleEndedNonReferenced', 'PseudoDifferential'.
    end
end

% All channels at same ADC resolution and terminal configuration
niSession.Rate          = niConfigParams.SampRate;                      % NI card sampling rate
niSession.IsContinuous  = niConfigParams.IsContinuous;                  % record continuously or for a set time

if ~niSession.IsContinuous
    niSession.DurationInSeconds = niConfigParams.recordDurationInSec;   % total length of recording in seconds    
else
    % Need to add at least one listener -> http://www.mathworks.com/help/daq/ref/dataavailable.html
        listHandle = niSession.addlistener('DataAvailable',@getData);    
    %lh = niSession.addlistener('DataAvailable', @(src, event), expr)
end

%% Counter Output/clock
    %     for iCount = 1:niConfigParams.numCIOchs
    %          niCIOchs(iCount + numCIOchs) = niConfigParams.CIOchsID(iCount + numCIOchs);
    %          numCIOchs = numCIOchs + 1;
%% NEEDS DEBUGGING -> NOT WORKING PROPERLY!!!
if niConfigParams.doClockCh

    clockSession = daq.createSession('ni');
    clockSession.addCounterOutputChannel(niConfigParams.devID,0,'PulseGeneration')
    
	usedChs = clockSession.get('Channels');
    clockCh = find(strcmpi('ctr0',{usedChs.ID}));
    clockTerminal = clockSession.Channels(clockCh).Terminal;
    
    clockSession.Channels(clockCh).Frequency = niConfigParams.clockFreq;
    clockSession.Channels(clockCh).Name = 'dioClock';
    
    warning('For a clocked signal continuous recording is required')
    clockSession.IsContinuous = true;                   % For clocked signals the session must be continuously recording
    clockSession.startBackground();                     % start clock in the background    
end

%% Digital Input (need analog input to work as clockof the DI system)
% NEEDS DEBUGGING -> NOT WORKING PROPERLY!!!
if niConfigParams.doDigitInChns
    warning('Digital Inputs need and extra analog input as clock of the DI acquisition loop!')
    for iDch = 1:niConfigParams.numDIports        
        niSession.addDigitalChannel(niConfigParams.devID,niConfigParams.DIchsID(iDch),'InputOnly');
        niSession.addClockConnection('External',sprintf('%s/%s',niConfigParams.devID,clockTerminal),'ScanClock');
    end
end

%% PhotoDiode
if niConfigParams.doPhotoDiode
    niSession = daq.createSession('ni');
    niSession.addAnalogInputChannel(niConfigParams.devID, 0, 'Voltage');            % Analog input to set a virtual internal clock
    niSession.addCounterInputChannel(niConfigParams.devID, 'ctr0', 'EdgeCount');    % Counts every edge.
    % Terminal, physical connection
    fprintf('This is the input port and line %s\n Make sure you connect the PhotoDiode terminal to the Digital GRN and to port %s\n',niSession.Channels(1).Terminal,niSession.Channels(1).Terminal)
    listHandle = niSession.addlistener('DataAvailable',@getData);
end


%% THIS HAS NOT BEEN TESTED
% % Counter Input Channels
% numCIOchs = 0;
% if niConfigParams.doCounterInChns
%     for iCount = 1:niConfigParams.numCIOchs
%     % To add a counter channel, to count photodiode activity
%     niCIOchs(iCount) = niSession.addCounterInputChannel(niConfigParams.devID,niConfigParams.CIOchsID(iCount),niConfigParams.CImeasType);
%     numCIOchs = numCIOchs + 1;
%     end
% end
% 
% 
% % Analog Output
% if niConfigParams.doAnalogOutChns
%     for iAch =1:niConfigParams.numAOchs
%         niAOchs(iAch) = niSession.addAnalogOutputChannel(niConfigParams.devID,niConfigParams.AOchsID(iAch),'Voltage');
%     end
% end
% 


%     %% Setting a trigger
%     %Create an external trigger connection and set the trigger to run one time.
%     niAIchs = niSession.addTriggerConnection('External','Dev3/PFI0','StartTrigger');
%     niSession.Connections(1).TriggerCondition = 'RisingEdge';
%     niSession.TriggersPerRun = 1;
%     %Set the rate and the duration of the acquisition.
%     niSession.Rate = 50000;
%     niSession.DurationInSeconds = 0.01;
%     %Acquire data in the foreground and plot the data.
%     [data, timestamps] = niSession.startForeground;
%     plot(timestamps, data);

if ~exist('clockSession','var')
    clockSession = [];
else
end

% 
% % Digital Output
% if niConfigParams.doDigitOutChns
% end
% 

%% Output vbles with all channel information
niChs = 1;
% niChs.AIchs = niAIchs;
% niChs.AOchs = niAOchs;
% niChs.DIchs = niDIchs;
% niChs.DOchs = niDOchs;
% niChs.CIChs = niCIchs;
% niChs.COChs = niCOchs;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===================================================================================================================
function getData(src,event)
% function getData(src,event)
%
% Collects data and time every time data is available (upon acquiring data 
% in the backgrund)
%
% INPUT
% src:      the src of the data recorded. These are the channels and device
% event:    contains the data and time given by the specific event. In this
%           case is a callback due to the sampling frequency and the presence 
%           of data in the buffer.
% OUTPUT
% niData:   matrix. [samples x numChannels]. Data from each one of the
%           channels recorded.
% niTime:   vector. [samples x 1]. Time for the samples recorde. These 
%           values are in seconds and give the sampling frequency of the 
%           acquisition device
%
% Created 15 Jan 2014
% Last Modified 22 Jan 2014
% Andres v.1

persistent tempData tempTime
global niData niTime

% Collect new data points
tempTime = [tempTime;event.TimeStamps];
tempData = [tempData;event.Data];

% Update time and data to be saved
niTime = tempTime; 
niData = tempData;

% Plot recorded data
plot(event.TimeStamps, event.Data)
xlabel('Time (secs)');
ylabel('Voltage')


end
%% Trigger photodiode to start recording after first flash.
