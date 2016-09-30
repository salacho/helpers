function newTopofile = getNewTopofile(topoplotFile,typeElectSelect,mainParams) %#ok<INUSD>
% function newTopofile = getNewTopofile(topoplotFile,typeElectSelect,mainParams)
%
%
% topoplotFile = mainParams.layout.topoplotFile;
% typeElectSelect
%
% Andres    :       v1     : init. 3 July 2016


% % Load file
% fileID = fopen(topoplotFile);
% formatSpec = '%n %n %n %n %s';
% origCoord = textscan(fileID,formatSpec,'Delimiter',{'\t','\t'});
% fclose(fileID); 
% 
% % Extract channel list
% origChs = origCoord{5}';
% [subChs,subChsList] = eegSelectChannels(mainParams,typeElectSelect);
% 
% % Remove extra spaces
% for iCh=1:length(origChs), origChs(iCh) = strtrim(origChs(iCh)); end
% 
% % New coordinate file 
% fileCoord{1} = origCoord{1}(subChs);
% fileCoord{2} = origCoord{2}(subChs);
% fileCoord{3} = origCoord{3}(subChs);
% fileCoord{4} = origCoord{4}(subChs);
% fileCoord{5} = subChsList';
% 
% % Single 
% for iCol = 1:5
%     for iRow = 1:length(fileCoord{:,iCol})
%         newCoord{iRow,iCol} = fileCoord{iCol}(iRow);
%     end
% end

if isempty(strfind(topoplotFile,typeElectSelect))
    newTopofile = sprintf('%s_%s.xyz',topoplotFile(1:end-4),typeElectSelect);
    %newTopofile = sprintf('%s_%s.xyz','electrode2015',typeElectSelect);
else
    newTopofile = topoplotFile;
end

% % Save new topoplot file
% newTopofile = sprintf('%s.xyz',typeElectSelect);
% currfolder = pwd;
% cd(mainParams.dirs.helpers)
% 
% newfileID = fopen(newTopofile,'wt');
% formatSpec = '%s %s\n';
% 
% fprintf(newfileID,formatSpec,newCoord{:,:});
% fclose(newfileID)
% 
% cd(currfolder)
% 
% dlmwrite(newTopofile,newCoord,'delimiter','\t')
% %writetable(newCoord,newTopofile)
% %xlswrite(newTopofile,newCoord) 

end