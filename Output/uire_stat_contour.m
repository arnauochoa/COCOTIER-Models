function uire_stat_contour(uireStat, usrdata, statType)
% GIVE_STAT_CONTOUR: Plots give statistic as contour over map
%
% Inputs:
%     
%
% 
% $Revision: R2020a$ 
% $Author: Arnau Ochoa Banuelos$
% $Date: July 21, 2020$
%---------------------------------------------------------

global MOPS_SIG2_GIVE MOPS_GIVE MOPS_GIVEI_NM
global MOPS_MU_GIVE MOPS_SIG_GIVE
global GRAPH_GIVEI_COLORS
global GRAPH_LL_WORLD GRAPH_LL_STATE
global OUTPUT_BIAS_LABEL OUTPUT_STD_LABEL
global COL_USR_LL

% Set variables specific to each statistic
switch statType
    case OUTPUT_BIAS_LABEL
        mopsStat = MOPS_MU_GIVE;
        units = 'm';
    case OUTPUT_STD_LABEL
        mopsStat = MOPS_SIG_GIVE;
        units = 'm';
    otherwise
        error('Wrong statType');
end

%adjust longitude to -180 to 180
ll_user = usrdata(:, COL_USR_LL);
idx=find(ll_user(:,2)>=180);
ll_user(idx,2)=ll_user(idx,2)-360;
span180 = max(ll_user(:,2)) - min(ll_user(:,2));
span360 = max(usrdata(:, COL_USR_LL(2))) - min(usrdata(:, COL_USR_LL(2)));
if(span360 < span180)
  ll_user=usrdata(:, COL_USR_LL); 
end
if nargin < 5
  ax=[min(ll_user(:,2)) max(ll_user(:,2)) min(ll_user(:,1)) max(ll_user(:,1))];
end

%create a mesh for uire interpolation
lx=ax(1):(ax(2)-ax(1))/75:ax(2);
ly=ax(3):(ax(4)-ax(3))/75:ax(4);
[lons lats]=meshgrid(lx,ly);
[n m]=size(lons);
n_map=n*m;
ll_map=[reshape(lats, n_map, 1) reshape(lons, n_map, 1)];

%initialize the map
uireStat_map=repmat(MOPS_GIVEI_NM,n_map,1);

% Find UIRE stat indices
% uireStatInd = assign_indices(uireStat, mopsStat, MOPS_GIVEI_NM);

%interpolate onto the mesh
interp = scatteredInterpolant(ll_user(:, 2), ll_user(:, 1), uireStat,'linear','none'); % Lon, Lat
temp = interp(ll_map(:,2), ll_map(:,1)); % Lon, Lat

%determine the index values
for idx = 2:length(mopsStat)-1
  i=find(temp > mopsStat(idx-1) & temp <= mopsStat(idx));
  if(~isempty(i))
    uireStat_map(i)=idx;
  end
end
i=find(temp > 0 & temp <= mopsStat(1));
if(~isempty(i))
  uireStat_map(i)=1;
end
i=find(temp > mopsStat(end-1));
if(~isempty(i))
  uireStat_map(i)=length(mopsStat)-1;
end

ticklabels=num2str(mopsStat', '%1.2f');
ticklabels(MOPS_GIVEI_NM,:)=pad('NM', size(ticklabels, 2), 'both'); % Add spaces to fill

clf
bartext = [statType ' (' units ')'];

svm_contour(lx,ly,reshape(uireStat_map,length(ly),length(lx)), ...
            1:MOPS_GIVEI_NM, ticklabels, GRAPH_GIVEI_COLORS, bartext, ...
            'vert')
if(span360 < span180)        
  ax1=axis;
  dx=(ax1(2)-ax1(1))/600;
  dy=(ax1(4)-ax1(3))/600;
  plot(GRAPH_LL_WORLD(:,2)+360+dx,GRAPH_LL_WORLD(:,1)-dy,'k');
  plot(GRAPH_LL_STATE(:,2)+360+dx,GRAPH_LL_STATE(:,1)-dy,'k:');
  plot(GRAPH_LL_WORLD(:,2)+360-dx,GRAPH_LL_WORLD(:,1)+dy,'w');
  plot(GRAPH_LL_STATE(:,2)+360-dx,GRAPH_LL_STATE(:,1)+dy,'w:');
  xticklabel=get(gca,'XTickLabel');
  if iscell(xticklabel)
      xticklabel = cell2mat(xticklabel);
  end
  xticks=str2num(xticklabel);
  idx=find(xticks>=180);
  xticks(idx)=xticks(idx)-360;
  set(gca,'XTickLabel',num2str(xticks));
end
% lon_circ=(ax(2)-ax(1))*cos([.1:.1:2]*pi)'/100;
% lat_circ=(ax(4)-ax(3))*sin([.1:.1:2]*pi)'/100;
% n_igp=size(ll_user,1);
% for idx=1:n_igp
%   patch(lon_circ+ll_user(idx,2),lat_circ+ll_user(idx,1),uireStatInd(idx));
% end

axis(ax);

title(['GIVE ' statType ' values']);