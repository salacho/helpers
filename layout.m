function layoutInfo = layout(goodChs,test)
% function layoutInfo = layout(goodChs,test)
%
% Gets nearest neighbor info, constructs laplacian matrix and subplot
% layout matrix. 
% It is required the '32ArrayNearNeig.txt' file which has the channel 
% numbers of the nearest neighbors electrodes for a 32 BlackRock array 
% (has 36 channels but the corners of the array are not for recording).
%
% INPUT
% goodChs:              vectors [No. Channels x 1]. If no 'goodChs' vector
%                       is available use '1' to denote that all channels
%                       will be taken into account.
% test:                 structure with two fields that can be 1 or 0. If 
%                       you want to plot the locations obtained by 'layout' 
%                       and the distribution in a 32 array, put 1 in the 
%                       field of interest.   
%           NNs:        1 or 0. Nearest neighbors. 
%           lapla:      1 or 0. Laplacians
%
% OUTPUT
% layoutInfo:           structure with fields related to layout, subplot and references.
%           rows:       number of rows for subplot function
%           colms:      number of columns for subplot function
%           subplot:    maps channel to subplot   
%           nearNeigh:  matrix with ones for nearest neighbors (zero
%                       otherwise) of each channle (row) -32 channels-
%           laplacian:  matrix with weighted values for nearest neighbors
%                       for each channels (in row) -96 channels-.
%           NNs:        cell. nearest neighbors channels 
% 

if size(goodChs,1) > 1
else
    goodChs = ones(96,1);    
end
goodNNs = find(goodChs);

% Subplot layout
layoutInfo.rows = 6;
layoutInfo.colms = 6;
layoutInfo.subplot(1:4) = 2:5;
layoutInfo.subplot(5:28) = 7:30;
layoutInfo.subplot(29:32) = 32:35;
 
% Loading Nearest Neighbors (in array layout)
layoutInfo.nearNeighbFile = '32ArrayNearNeig.txt';
fileID = fopen(layoutInfo.nearNeighbFile);
textID = textscan(fileID,'%s');
NNs = textID{1};
fclose(fileID);
% Changing format from 1 array to 3
NNs = [NNs;NNs;NNs];

% Creating nearest neighbors matrix (in array layout) for all 96 chns
for ii = 1:length(NNs)
    rowNs{ii} = eval(['[',NNs{ii},']']) +  32*(floor((ii - 1)/32));
end

% Removing bad channels and creating laplacian and nearNeigh matrices
nearNeigh = zeros(length(rowNs));
laplacian = zeros(length(rowNs));
layoutInfo.numNNs = nan(length(rowNs),1);
for ii = 1:length(rowNs)
    goodNrows  = intersect(rowNs{ii},goodNNs);
    nearNeigh(ii,goodNrows) = 1;
    laplacian(ii,goodNrows) = 1/length(goodNrows);
    layoutInfo.numNNs(ii) = length(goodNrows);
end

% Saving nearest neighbors and laplacian info in structure
layoutInfo.nearNeigh = nearNeigh;
layoutInfo.laplacian = laplacian;
layoutInfo.rowNs = rowNs;

%% Testing laplacian is correct

%% Testing nearest neighbors are properly located
if test.NNs == 1
    for arrayNum = [1 33 65]
        array = floor((arrayNum - 1)/32);
        for ch = (1+32*array):(32+32*array)
            disp(ch)
            for kk = (1+32*array):(32+32*array)
                hk(kk) = subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(kk - 32*array)); imagesc(1) %green
            end
            %plotting target ch
            h = subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(ch - 32*array)); imagesc(1:1000,[0 10]) %red
            %NNs = eval(['[',layoutInfo.NNs{ch},']']);
            NNs = layoutInfo.rowNs{ch};
            %plotting nearest neighbors
            for ii = 1:length(NNs)
                hh(ii) = subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(NNs(ii) - 32*array));  imagesc(1:1000,[1000 50000]);%plot(layoutInfo.laplacian(); %blue
            end
            set(hh,'visible','off'),set(hk,'visible','off')
            set(gcf,'name',sprintf('Channel %i',ch));
            pause(0.2)
        end
    end
end

%% Testing laplacians
if test.lapla == 1
    for arrayNum = [1 33 65]
        array = floor((arrayNum - 1)/32);
        for ch = (1+32*array):(32+32*array)
            disp(sprintf('Ch: %i',ch));
            %show all channels in this array
            for kk = (1+32*array):(32+32*array)
                hk(kk) = subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(kk - 32*array)); imagesc(1) %red
            end
            %plotting target ch
            h = subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(ch - 32*array)); imagesc(1:1000,[0 10]) %red
            %plotting laplacian values
            laplaChs = find(layoutInfo.laplacian(ch,:));
            disp(sprintf('Near.Neig in laplacian: %s',num2str(laplaChs)));
            for ii = 1:length(laplaChs);
                hh(ii) = subplot(layoutInfo.rows,layoutInfo.colms,layoutInfo.subplot(laplaChs(ii) - 32*array));  imagesc(1:1000,[1000 50000]);%plot(layoutInfo.laplacian(); %blue
            end
            set(hh,'visible','off'),set(hk,'visible','off')
            set(gcf,'name',sprintf('Channel %i',ch));
            pause(0.25)
        end
    end
end



