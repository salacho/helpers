function niParams = niConfigParams
% function niParams = niConfigParams
% 
% Set the configuration parameters for the National Instrument card. Right
% now only tested for the USB NI-62118. devNumber = 1.  
%
% INPUT:
% devNumber:        Integer. Device number in the list found by the 
%                   "daq.getDevices" command. It is 1 by default.
% OUTPUT
% niParams:         Structure with all fields to set the configuration of
%                   the NI card. This parameters are used by
%                   "configureNIcard.m".
%
% Created 15 Jan 2014
% Last modified 16 June 2014
% Andres v.1

devNumber = 1;

%% NI Configuration Parameters
%posIndx = strcmpi(tgtDev,'USB-6218 (Device ID:');      Need to find a way to find the card, automatically, and use it to select the proper device. 
% Device and channels form the NI card
niParams.devNumber    = devNumber;            % Device number from al the list of devices in the computer
if niParams.devNumber == 1    
    niParams.devID  = 'dev1';       % name of the NI USB-6218 device in Andres' laptop
else
    warning('Device number not recognized!!!')    
end

% Get total number of channels to read from
niParams.numAIchs     = 0;            % Number of analog input channels (up to 32 in USB-6218
niParams.numAOchs     = 0;            % Number of analog output channels (up to 32in USB-6218
niParams.numDIchs     = 1;            % Number of digital input channels (up to 8 in USB-6218
niParams.numDOchs     = 8;            % Number of digital output channels (up to 8 in USB-6218
niParams.numCIOchs    = 1;            % Number of input/output counters

% Set analog channels and digital ports
niParams.AIchsID      = 0:7;          % Select chID of analog input channels (up to 32 in USB-6218
niParams.AOchsID      = 0:1;          % Select chID of analog output channels (up to 2 in USB-6218
niParams.DIlines      = [];            % Select chID of digital input channels (up to 8 in USB-6218
niParams.DOlines      = 0:7;          % Select chID of digital output channels (up to 8 in USB-6218

% For analog channels
niParams.ChsValRange  = [-5 5];           % Vector. [Min. Max.] Range of the input data. Can be also [-10 10]
niParams.TerminalConfig = 'SingleEnded';  % Will apply to all channels. Type of terminal recording configuration with respect to GND and other channels. Can be 'Differential', 'SingleEnded', 'SingleEndedNonReferenced', 'PseudoDifferential'.

% niParams.DIchsID = '';              % channel ID
% niParams.DOchsID = '';

niParams.numDIports = length(niParams.DIlines);              % Number of DI ports
niParams.numDOports = length(niParams.DOlines);              % Number of DO ports

% Define DIGITAL OUT ports only
% Sets digital out ports in order, starting from port0
%niParams.DOchsID = sprintf('port1/line1:7');       % seven lines (1:7) in port1, pin zero for 'clock'
niParams.DOchsID = sprintf('port1/line0:7');       % eight lines (0:7) in port1, no clock used, all

% Set ports for the counters. Only wo available for both input and output for USB NI-6218: 'ctr0','ctr1'
niParams.CIOchsID   = 0:1;         % Select chID of the counter input/output

%Counter measurement types. 'EdgeCount' the most common for now 
% 'EdgeCount','PulseWidth','Frequency','Position' 
niParams.CImeasType = 'EdgeCount';

% Channel properties
niParams.SampRate 	= 10000;%256     	% (AFSG 20170807), was 10000; % NI card sampling rate to match amplifiers and allow all outputs to be rread when outputSingle scan is used.

% Type of recording, continuous or for a set time 
niParams.IsContinuous = false;             % logical. True to stop only when 'stop' flag is used (daq.Session.stop).
if ~niParams.IsContinuous 
    niParams.recordDurationInSec = 10; 	% double. Duration of data recording in seconds
end

% Logical flags to use channels
niParams.doAnalogInChns   = false;     % logical. Set up NI analog input channels to read from them
niParams.doAnalogOutChns  = false;     % logical. Set up NI analog output channels to pull data from them
niParams.doDigitInChns    = false;     % logical. Set up NI digital input channels to read data from them
niParams.doDigitOutChns   = true;     % logical. Set up NI digital output channels to pull data from them
niParams.doCounterInChns  = false; 	% logical. Set up NI counter channels to read from them
niParams.doCounterOutChns = false; 	% logical. Set up NI counter channels to pull data from them
niParams.doPhotoDiode     = false;     % Simple code for photodiode data
niParams.doClockCh        = false;     % logical. Sets a ni NI session for a clocked signal (for digital input/output channels)

if niParams.doDigitInChns 
    niParams.doClockCh = true;
    warning('Any digital input/output needs a clock!!')
end
% Internal clock required for digital input/output
niParams.clockFreq = niParams.SampRate;

