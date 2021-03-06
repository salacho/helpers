function FiltParams = setFilterParams(freqRange, filtType, filtOrder, smpRate)
% function FiltParams = setFilterParams(freqRange, filtType, filtOrder, smpRate)
%
% Set parameters to filter data, giving poles and zeros using the sampling
% frequency, type and order of filter. 
%
% INPUTS
% freqRange:        vector with lower and upper filter band.
% filtType:         string. Filter type: 'butter', etc...
% filtOrder:        integer. Filter order. Usually 2-4
% smpRate:          integer. Sampling rate. In Hz.
%
% OUTPUT
% FilterParams:     structure with zeros (a) and poles (b).
%
% Author: Scott Brincat. 2012
% Andres: Modify some parameters to take into account filtering 2012

FNyquist = smpRate/2;
switch filtType
    case 'butter';
        % upper limit must be < Nyquist
        if (freqRange(2) < FNyquist) || (freqRange(2) == inf)
            % Low-pass filtering -- only input high-cutoff frequency
            if (freqRange(1) == 0) && (freqRange(2) ~= inf)
                [FiltParams.b,FiltParams.a] = butter(filtOrder, freqRange(2)/FNyquist, 'low');
                % High-pass filtering -- only input low-cutoff frequency
            elseif (freqRange(2) == inf) && (freqRange(1) < FNyquist)
                [FiltParams.b,FiltParams.a] = butter(filtOrder, freqRange(1)/FNyquist, 'high');
                % Band-pass filtering -- input [low,high] cutoff frequencies
            else
                [FiltParams.b,FiltParams.a] = butter(filtOrder, freqRange(:)/FNyquist);
            end
        else
            % No filter required (Both parameters are 1)
            if (freqRange(2) == FNyquist) && (freqRange(1) == 0)
                FiltParams.b = 1; FiltParams.a = 1;
                % High pass filter
            elseif(freqRange(2) == FNyquist) && (freqRange(1) > 0)
                [FiltParams.b,FiltParams.a] = butter(filtOrder, freqRange(1)/FNyquist, 'high');
            else
                warning('Filter upper limit (%i Hz) is higher than Nyquist frequency (%i Hz) so no filter will be performed!!',freqRange(2),FNyquist);
                FiltParams.b = 0;
                FiltParams.a = 0;
            end
        end
    otherwise;
        error('setFilterParams: Filter type %s unknown',filtType);
end