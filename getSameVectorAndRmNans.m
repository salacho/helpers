function vectorVals = getSameVectorAndRmNans(vectorVals)
% function vectorVals = getSameVectorAndRmNans(vectorVals)
%
% If a vector has Nan values these must be removed before using the vector
% for analysis since Nans are found as real values by some function (e.g. find(''))
%
%
% Andres    :   v1  : init. 18 Oct 2017.

vectorVals = vectorVals.*(~isnan(vectorVals));

end
