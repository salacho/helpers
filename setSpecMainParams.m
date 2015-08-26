function mainParams = setSpecMainParams(mainParams)
% function mainParams = getSpecMainParams(mainParams)
%
% Organizes the parameters used for spectral and spetrum analysis as well
% as for plotting.
%
% INPUT
% mainParams:       structure
%
% OUTPUT
% mainParams:       structure. 
%   specParams:     field 'specParams' is added including properties for
%                   spectrogram calculations using chronux
%
% Author    :   Andres
%
% Andres    : v1    : init. 28 July 2015

%% Spectrogram
sampFreq = mainParams.epochInfo.Fs;
TW  = 3;                %time-bandwidth window
K   = 2;                %number of slepian functions. K <= 2TW -1, [3,2] better than [2,2], [2,1]
window  =  0.4;         % AFSG 20150625: was window = 0.2  %length of window: 20 ms
winstep =  0.025;       %step the window is moved: 10 ms
fMin = 0;               %low freq.
fMax = sampFreq/2;             % high freq.

% Filter values for spectrogram must be between freq. boundaries of loaded data
if mainParams.epochInfo.doFilt
    % Use frequency range given by filter
    fMin = mainParams.epochInfo.freqRange(1);
    if mainParams.epochInfo.freqRange(2) < fMax, fMax = mainParams.epochInfo.freqRange(2); end
else
    % Use frequency range of the raw data
    fMin = 0; fMax = mainParams.sampFreq/2;
end
% Creating spec params structure
mainParams.specParams.nChs = mainParams.epochInfo.nChs;
mainParams.specParams.movingWin = [window winstep];
mainParams.specParams.params = struct(...
    'tapers',   [TW K],...                  % TW: time-bandwidth product. K: number of tapers to be used (K < 2TW-1).
    'pad',      0,...                       % zero padding. 0 to the next power of 2
    'Fs',       sampFreq,...              	% Sampling frequency. 256 Hz by default. USBamps default samp. freq.
    'fpass',    [fMin fMax],...             % frequency band for filter
    'err',      0,...                       % 0 for no error bars
    'trialave', 0);                         % 0 for no average across trial/channels

mainParams.specParams.freqBands = [0 100; 0 4; 4 8; 1 16; 8 16; 16 30; 0 40; 20 40; 40 80; 80 100];
mainParams.specParams.doTrials = false;      % true to calculate psectrogram for each trial, false otherwise

clear TW K fMin fMax window windstep

end
