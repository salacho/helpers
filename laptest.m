function laptest(info,p3,lapla)
%function laptest(info,p3,lapla)
%
% Plots noise in some channels (start-like shape) to show that this layout is working 
%
% info: info: structure containing the data, triggers and data processing, 
%             specially the 'info.layout.layout' and 'info.layout.posvect' structures
% p3: plotting in 3D the electrodes. 1 = 'yes', 0 is no plot at all.
% lapla: channels in original data space X data space with ones where nearest 
%        neighbors are located; use info.layout.layout as transformation matrix: 
%        indices in 'layout' are data space channels, values are the subplot position.
%        also, 'laplacian.m' converts 'lapla' (in data space X subplot space) to 
%        lapladat (data X data space, as it should be). If no lapla matrix is included, 
%        the default is: 'info.laplacian.lapladat' and if this one does not exist 
%        'lapla.layout.lapla' is converted to 'info.laplacian.lapladat' using 'laplacian.m'.
%
% Created 20 May 2011. Andrés F. Salazar-Gómez (salacho). salacho@bu.edu
% Last modified. salacho 19 July 2011.

%Initial vbles
simtime = randn(1,1000);                %time vector to plot
simdata = zeros(info.raw.chs,1000);         %data vble

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Using default lapla matrix
if (nargin == 2) || (nargin == 1) 
    if isfield(info.ref.laplacian,'lapladat')
       lapla = info.ref.laplacian.lapladat;
    else                                                    %laplacians are in subplot space
       [lapla,info] = laplacian(info,info.ref.laplacian.lapla);       %changing lapla to data space (lapladat)
       info.ref.laplacian.lapladat = lapla;
    end
    if (nargin == 1)    
        p3 = 0;
    end
else
    if ~(((size(lapla,1)) == (size(lapla,2))) && ((size(lapla,1)) == info.raw.chs))
        if isfield(info.ref.laplacian,'lapladat')
           lapla = info.ref.laplacian.lapladat;
        else                                                    %laplacians are in subplot space
           [lapla,info] = laplacian(info,info.ref.laplacian.lapla);       %changing lapla to data space (lapladat)
           info.ref.laplacian.lapladat = lapla;
        end
        msgbox('The laplacians matrix ''lapla'' is not square or does not match the number of channels. Using instead the default ''info.laplacian.lapladat'' or ''info.layout.lapla'' matrix.');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting the data
h1 = figure; 
switch info.test.type
  
  % Subplot
  case 'subplotlay'
  % Simulating data
  simch = [4,5,13,22,30,33,35,37,39,43];      %channels simulated
  simdata(simch,:) = randn(length(simch),1000);    %data to plot
  set(h1,'Name',['Montage: ',info.layout.polhemus,'. Simulating data-chs: ',num2str(simch),' to inspect layout.'],'NumberTitle','off');
  % Plotting simulation
  colores = 'b';
  plotest(simdata,simtime,info,colores)%,0);    
  % Laplacian    
  case 'laplalay'
    if p3 == 0     
        for kk = 1:info.raw.chs
            % Plotting the neighbors
            [ind] = find(lapla(kk,:));       %ind are the data space 
            if ~isempty(ind)
                %[ii] = layout2data(ind,info); %Moving from subplot to data space. layout position is the same a posvect position
                simdata = zeros(info.raw.chs,1000);         %data vble
                %simdata(ii,:) = randn(length(ind),1000); 
                simdata(ind,:) = randn(length(ind),1000); 
                % Plotting the electrodes
                simdata(kk,:) = randn(1,1000); 
                plotest(simdata,simtime,info,'b',kk);
                [jj] = data2layout(kk,info);
                set(h1,'Name',['electrode in subplot: ',num2str(jj),' is channel ',num2str(kk)],'NumberTitle','off');
                pause
                clear layoutpos pos 
                %'Using plotest'
            end
        end
    else
        %'Using plotlocs'
        plotlocs(info);      %plot_locs(info,locs,lapla)        
    end
  % Weights
  case 'weightlay'
    newinfo = info;
    newinfo.ref.laplacian.lapladat = newinfo.ref.laplacian.W;
    %'Weights'
    plotlocs(newinfo);  %W used as lapladat to check W is correct
end
clear newinfo