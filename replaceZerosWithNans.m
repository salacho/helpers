function varOut = replaceZerosWithNans(varIn)
% function varOut = replaceZerosWithNans(varIn)
%
% Replaces zero with nans, so can get average and st.dev/
%
% INPUT
% varIn
%
% OUTPUT
% varOut
%
% Andres    :   v1      : init. 29 Sep 2016

varOut = varIn; 
varOut(varOut == 0) = nan;

end