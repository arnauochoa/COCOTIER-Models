FolderName = '../Fig/meeting_8-11/totalPosErrHist/';   % Your destination folder
if ~exist(FolderName, 'dir')
       mkdir(FolderName)
end
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = sprintf('Fig_%d', iFig);
  saveas(FigHandle, fullfile(FolderName, [FigName, '.png']));
%   saveas(FigHandle, fullfile(FolderName, [FigName, '.fig']));
end
close all