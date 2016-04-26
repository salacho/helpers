function [niData,niTime,niConfigParams] = niCardMain(devNumber,doTesting, numTrials)
% function [niData,niTime,niConfigParams] = niCardMain(devNumber,doTesting,numTrials)
%
% Acquires and writes data from a NI card specificed by devNumber (number of deviced available in the computer).
% Saves data and time stamp
%
% INPUT:
% devNumber:        integer. Device number in the list found by the 
%                   "daq.getDevices" command. It is 1 by default.
% doTesting:        logical. True to run tests. False to run a real
%                   recording session.
% OUTPUT
% niData:           global variable with matrix of data points collected at the niTime values.
% niTime:           global variable with the times of events
%
% Created 10 Jan 2014
% Last modified 21st Jan 2014
% Andres. v1.

warning('All open ports have to be set to HIGH or LOW states, NEVER, NEVER leave them in the "AIR"')
global niData niTime
doTesting = 1;
devNumber = 1;

% Set configuration parameters
niConfigParams = niCardSetConfigParams(devNumber);
% Configure the NI card
[niSession,niChs,clockSession, listener] = niCardConfigure(devNumber,niConfigParams);

% AFSG 20140606. 
% The startForeground method cannot be called with IsContinuous set to
% true.  Use startBackground.
% dataIn = niSession.startForeground;
% plot(dataIn)
 

% clockSession.stop
% niSession.removeConnection
% niSession.release

%% Collect a single scan
% data = niSession.inputSingleScan;         % Could be used to test ports 

%% Record data
%[data,time] = niSession.startForeground;            % Interrupts matlab command line...

% Pause the system to start eveything in synch

disp('Hit any key to start the recording...'), pause

if niSession.IsContinuous
    if doTesting
        pauseSec = (numTrials/20)*116;
        niSession.startBackground();
        pause(pauseSec)
        niSession.stop                      % flag to stop when IsContinuous flag set to "true"
    
        % AFSG 20140606. Broken after the pauseSec was reached
        %niSession.resetCounters();
        
%         FlushEvents('keyDown')
%         listVals = {'0','9'};
%         [vals,queryTime] = stopKey(listVals);
              
    else
        % Real recording stuff here!!!
    end
else
    % Not continuous, set a max time for recording
    %[data,time] = niSession.startBackground;
    %SET IF MAX AFTER TRIGGER OR NOT!!! 
end

niConfigParams.numTrials = numTrials;

plot(niTime,niData)
xlabel('time [s]')
ylabel('AO voltage [V]')

whos niData
whos niTime

% Savefile
saveDataPath   = 'C:\Data\ErrPs\raw\photoDiode\';
dte     = clock;
saveFilename = ...                               % Format: PathPhotoDiodeYYYYMMDD-hhmm
    [saveDataPath 'PhotoDiode' sprintf('%d%02d%02d-%02d%02d-%itrls.mat',dte(1:5),numTrials+3)];
save(saveFilename,'niData','niTime','niConfigParams')

end

%% Trigger photodiode to start recording after first flash.
%niSession.IsWaitingForExternalTrigger = true;
%Count edges of a pulse using a counter input channel on your device.

% s.createSession('ni')
% s.addCounterInputChannel('Dev1', 'ctr0', 'EdgeCount');
% s.inputSingleScan()
