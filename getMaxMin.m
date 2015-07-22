function maxMinVals = getMaxMin(tracesVals,isDetrend)
%
% All the traces to plot must have the same size.
%
%
% Author    :   Andres
%
% Andres    : v1.0      :  init. 20 Aug 2014

% Get the fields
tracesFields = fields(tracesVals);
dim1 = 0;
dim2 = 0;
dim3 = 1;

for iField = 1:length(tracesFields)
    eval(sprintf('checkSz = tracesVals.%s;',char(tracesFields(iField))))
    dim1 = max(dim1,size(checkSz,1));
    dim2 = max(dim2,size(checkSz,2));
    if ndims(checkSz) == 3
    dim3 = max(dim3,size(checkSz,3));
    end
end
Vals = nan(length(tracesFields),dim1,dim2,dim3);

% Extract min. and max. values
for iField = 1:length(tracesFields)
    eval(sprintf('checkSz = tracesVals.%s;',char(tracesFields(iField))))
    if size(checkSz,1) == 1             % One channel only
        if isDetrend, Vals(iField,:,1:size(checkSz,2)) = detrend(checkSz);
        else Vals(iField,:) = checkSz;
        end
    else
        % all the channels
        if isDetrend, Vals(iField,:,1:size(checkSz,2)) = detrend(checkSz')';
        else Vals(iField,:,:) = checkSz;
        end
    end
end

maxMinVals.yMax = 1.1*nanmax(nanmax(nanmax(Vals)));
maxMinVals.yMin = 1.1*nanmin(nanmin(nanmin(Vals)));

