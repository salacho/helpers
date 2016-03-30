function [vals,queryTime] = stopKey(listVals)
%
%
% INPUT
% listVals:     cell of strings. Values that will be used as stop keys. 
%
% OUTPUT
% 
% Andres    : 1.1   : init. 6 June 2014 

%% Ask for keyboard
disp('Please hit any number to stop!!...')

%% Possible numbers
if nargin <= 1
    numVals = 0:9;
    for iNum = 1:length(numVals)
        listVals{iNum} = num2str(numVals(iNum));        %#ok<*AGROW>
    end
end

%% Clear the keyboard buffer so only keys typed from now on will be readable
% FlushEvents('keyDown')
% lureQueryTime = 0;
prevTime = GetSecs;                                   % Have some maxTime for the quer
while ~CharAvail %&& lureQueryTime < bhv.lureQueryTime
    keyVal = GetChar(0,0);                            %keyVal = GetChar('getExtededData',0);
    vals = find(strcmp(keyVal,listVals));
    if vals
        FlushEvents('keyDown')
        numLures = vals;
        currTime = GetSecs;
        queryTime = currTime - prevTime;
        disp('Good Doggie!!!')
        return
    end
    %     currTime = GetSecs;
    %     lureQueryTime = currTime - prevTime;
end

