function niCard2Dante
%function niCard2Dante
%
%
%

%% National Instruments digital IO
% Configuration parameters for NI card
hdw.niDio.niParams = niConfigParams;

if strcmp(environment,'exp')
    % Display devices and select the USB-NI card
    allDevices = daq.getDevices;
    if length(allDevices) > 1, tgtDev = allDevices(hdw.niDio.niParams.devNumber); disp(tgtDev)
    else tgtDev = allDevices(1); disp(tgtDev);
    end
    
    % Create a NI recording session and add digital output channels
    hdw.niDio.niSession = daq.createSession('ni');
    % TO DO: need to add a better/more modular way of including input and
    % output channels
    hdw.niDio.niSession.addDigitalChannel(hdw.niDio.niParams.devID, hdw.niDio.niParams.DOchsID, 'OutputOnly'); %
    
    % Set all output ports as zeros
    hdw.niDio.niSession.outputSingleScan(zeros(1,8));
end
