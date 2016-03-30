function [niData,niTime,s] = photoDiodeSimple(Device,saveFilename) %#ok<*STOUT>
% function [niData,niTime] = photoDiodeSimple(Device,saveFilename)
%
% Simple function to read out photoDiode data, at 1kHz, for stimulus testing. 
% After running the code, hit 'Enter' to confirm the input port/line is the
% appropriate one and then the data starts to be collected. A second 'Enter' 
% press will stop the recording.
%
% Common usage:   [niData,niTime,s] = photoDiodeSimple('Dev1','putNameOfFiletoSaveHere')
%  clear all, saveFilename = 'testingAllFreq5Sec10Trials1pause_2'; Device = 'Dev1'; [niData,niTime,s] = photoDiodeSimple(Device,saveFilename);
% 
% INPUT
% Device:       string. Name of the device. If using the National
%               Instruments card NI-USB 6218, use 'Dev1'.
% saveFilename: string. Complete path and name (without the extension) of 
%               the file where the data will be saved in cvs format. If only
%               a name is given, the file will be saved in the current folder.
%               Data saved: niData and niTime.
%
% OUTPUT
% niData:       vector. [nSamples x 1]. This counter increases as new input
%               stimulus is fed via the photodiode channel.
% niTime:       vector. [nSamples x 1]. Time stamps in seconds. The size
%               of niTimes is equal to niData.
%x
% Andres v.1
% Created 22 Jan 2014
% Last modified 2 Feb 2014

clear tempData tempTime niData niTime 
close all
global niData niTime %#ok<*REDEF>
    
%% Load device and create session
disp('Configuring the NI card...')
disp(daq.getDevices)
s = daq.createSession('ni');
disp('If not device displayed check the proper NI drivers are installed.')
s.addAnalogInputChannel(Device, 0, 'Voltage');              % Configuring analog channel to be able to create counter channel
s.addCounterInputChannel(Device, 'ctr0', 'EdgeCount');      % Configuring digital counter
% Terminal, check physical connection where photodiode goes
fprintf('This is the input port and line %s.\nMake sure you connect the PhotoDiode terminal to the Digital GRN and to port %s.\nHit ''Enter'' to continue...',s.Channels(2).Terminal,s.Channels(2).Terminal)
pause
%disp(s)

%% Run continuously until hitting pause
s.IsContinuous  = true;                                     % Logic. true to record continuously, false to record for a set time
s.Rate = 1000;                                              % Sampling frequency for digital data. 1kHz is the default.
s.addlistener('DataAvailable',@getData);                    % Adding function to read data from the port/line
% Start recording
s.startBackground();                                        % Record data in the background
% Hit pause to finish recordings
fprintf('\nHit ''Enter'' to finish recording...\n')
pause

%% Clear the counters and release the channels
s.stop
s.resetCounters();
s.release

%% Basic plots
subplot(2,1,1),
plot(niTime,niData)
title('Number of photo-diode pulses','Fontweight','bold')
xlabel('Time [s]','Fontweight','bold')
ylabel('Number of pulses','Fontweight','bold')
axis tight

subplot(2,1,2),
plot(niTime(2:end),diff(niData)) %#ok<COLND>
title('Photo-diode events','Fontweight','bold')
xlabel('Time [s]','Fontweight','bold')
ylabel('Pulses','Fontweight','bold')
axis tight

%% Save data
csvwrite(sprintf('%s.csv',saveFilename),[niData,niTime])
fprintf('Data saved in the %s.cvs file!\n',saveFilename)

clear tempData tempTime 
% %% Analyze data
% pdPulses = find(diff(niData));
% indxStart = pdPulses(1);

end

%=========================================================================
function getData(src,event) %#ok<INUSL>
% function getData(src,event)
%
% Collects data and time every moment samples are available (when acquiring data 
% in the background)
%
% INPUT
% src:      the src of the data recorded. These are the channels and device
% event:    contains the data and time given by the specific event. In this
%           case is a callback due to the sampling frequency and the presence 
%           of data in the buffer.
% OUTPUT
% niData:   matrix. [samples x 1]. Data from each one of the
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
tempData = [tempData;event.Data(:,2)];

% Update time and data to be saved
niTime = tempTime; 
niData = tempData;

% Plot this event's data
plot(tempTime,tempData)
title('Number of photo-diode pulses','Fontweight','bold')
xlabel('Time [s]','Fontweight','bold')
ylabel('Number of pulses','Fontweight','bold')

end