function [evnt] = bin2event(evnt,bitDepth)

% function [evnt] = bin2event(evnt)
% convert all event code numbers that are in binary (usually 8-bit) to decimal integers 
%
% IN:
% evnt      : struct w/ fields that contain binary event codes for different events
% bitDepth  : (optional) bit depth of binary event codes intput (defaults to 8-bit)
% 
% OUT:
% evnt      : struct w/ fields that contain decimal integer event codes for each event.
%
% Based on code from Jonas -> [evnt] = event2bin(evnt,bitDepth)
% Author:   Jonas
% Version:  1.0
% 1.1 : Scott : Removed from setBhvParams.m into separate function (otherwise same)
% 2.1 : Andres: Changed code to move from binary to decimal integers  

if (nargin < 2) || isempty(bitDepth), bitDepth = 8; end

% Step thru all sub-field names in bci.event.xxx struct
nme = fieldnames(evnt);
for iField = 1:length(nme)
    tmp = [];
    % Step thru all event codes listed w/in each sub-field
    for jRow = 1:size(evnt.(nme{iField}),1)
        binCode   = evnt.(nme{iField})(jRow,:);
        if length(binCode) > bitDepth, 
          error('Code ''bci.event.%s'' exceeds max number of bits (%d).', nme{iField}, bitDepth);  
        end
        tmp(jRow,:) = bin2dec(num2str(fliplr(binCode)));            % Must flip vector to match order
    end
    evnt.(nme{iField}) = tmp;
end