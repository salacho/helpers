function plotDataLikeMov(data,winSz,movSz,sampFreq)
%
% Plots a window of data with a size given by winSz (in seconds) section. 
% Hitting space or any key moves the data movSz (in seconds) 
% and pauses in order to move forward. Uses sampFreq for getting the 
% correct number of samples to plot. 
%
% INPUT
% data:     matrix or vector. Data to be plotted. If matrix, each row 
%           represents a channel and the columns are samples. 
% winSz:    double. Window size of the displayed data.
% movSz:    double. Size in seconds of the moving window 
%           (how much the window is moved).
% sampFreq: intger. Sampling frequency of the plotted data
%
% Author:   Andres
% Andres    : init.     : 7 August 2014. Colombian's presidential inauguration day.
% 

% From seconds to samples
winSamp = winSz*sampFreq;
movSamp = movSz*sampFreq;

timeVect = 1:1/sampFreq:length(data);       % time vector
dataLimit = min(winSamp,movSamp);           % To set last plotted section without error

% % Need to confirm rows are channels
% dataSz = size(data);
% if any(dataSz == 1)             % data is a vector
% else                            % data is a matrix
% end

for iSamp = 1:movSamp:length(data) - dataLimit
    plot(timeVect(:,iSamp:iSamp+winSz),data(:,iSamp:iSamp+winSz))
    xlabel('Time [seconds]')
    ylabel('Data values')
    title(sprintf('Data plotted using a window size of %0.2f and a moving window of %0.2f',winSamp, movSamp))
    axis tight
    pause
end
