function checkSpectrum(y)
% function checkSpectrum(y)
%
% Plots the spectrum of a signal to check the sources of noise.
%
% INPUT
% y:        matrix. EEG data in the form [chs x samples]. First row is
%           time, 34 is triggers. 
%
% Andres    : v1    : init. 21 Aug 2015

%% Spec params
sampFreq = 1/(y(1,3) - y(1,2));
TW  = 3;                %time-bandwidth window
K   = 2;                %number of slepian functions. K <= 2TW -1, [3,2] better than [2,2], [2,1]
window  =  0.4;         % AFSG 20150625: was window = 0.2  %length of window: 20 ms
winstep =  0.025;       %step the window is moved: 10 ms
fMin = 0;               %low freq.
fMax = sampFreq/2;             % high freq.

% Creating spec params structure
specParams.movingWin = [window winstep];
specParams.params = struct(...
    'tapers',   [TW K],...                  % TW: time-bandwidth product. K: number of tapers to be used (K < 2TW-1).
    'pad',      0,...                       % zero padding. 0 to the next power of 2
    'Fs',       sampFreq,...              	% Sampling frequency. 256 Hz by default. USBamps default samp. freq.
    'fpass',    [fMin fMax],...             % frequency band for filter
    'err',      0,...                       % 0 for no error bars
    'trialave', 0);                         % 0 for no average across trial/channels

clear TW K fMin fMax window windstep

%% Calculate spectrum
% Spectrogram Parameters
for iCh = 1:size(y,1)
   %% Data
    data2anal = (y(iCh,2000:end));
    % Spectrum using tapers
    [SpectrumVals,freqVals] = mtspectrumc(detrend(data2anal),specParams.params);
    % Plot
    subplot(2,1,1), plot(freqVals,SpectrumVals),xlabel('Freq.'), ylabel('Power')
    subplot(2,1,2), plot(freqVals,log(SpectrumVals)),xlabel('Freq.'), ylabel('log(Power)')
    title(sprintf('Spectrum for ch %i',iCh))
    pause
end

end

