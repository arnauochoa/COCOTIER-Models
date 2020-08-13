function error_stat_contour(ionoErrStat, usrdata, statType, titleText)
% ERROR_STAT_CONTOUR: Plots residual error statistic as contour over map
%
% =========================================================================
% Created by Arnau Ochoa Bañuelos August 2020 for the COCOTIER project

%---------------------------------------------------------

global MOPS_SIG2_GIVE MOPS_GIVE MOPS_GIVEI_NM
global MOPS_MU_GIVE MOPS_SIG_GIVE
global GRAPH_GIVEI_COLORS
global GRAPH_LL_WORLD GRAPH_LL_STATE
global OUTPUT_BIAS_LABEL OUTPUT_STD_LABEL OUTPUT_VAR_LABEL
global COL_USR_LL
global IONO_NSE_STATIONSFILE

% Load ECAC stations positions
load(IONO_NSE_STATIONSFILE, 'ECAC_pos');

% Set variables specific to each statistic
switch statType
    case OUTPUT_BIAS_LABEL
        mopsStat = MOPS_MU_GIVE;
        units = 'm';
    case OUTPUT_STD_LABEL
        mopsStat = MOPS_SIG_GIVE;
        units = 'm';
    case OUTPUT_VAR_LABEL
        mopsStat = MOPS_SIG2_GIVE;
        units = 'm^2';
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
errorStat_map=repmat(MOPS_GIVEI_NM,n_map,1);

% Find UIRE stat indices
uireStatInd = assign_indices(ionoErrStat, mopsStat, MOPS_GIVEI_NM);

%interpolate onto the mesh
interp = scatteredInterpolant(ll_user(:, 1), ll_user(:, 2), ionoErrStat,'linear','none'); % Lat, Lon
errorStat = interp(ll_map(:,1), ll_map(:,2)); % Lat, Lon

%determine the index values
errorStat_map = assign_indices(errorStat, mopsStat, MOPS_GIVEI_NM);

ticklabels=num2str(mopsStat', '%1.2f');
ticklabels(MOPS_GIVEI_NM,:)=pad('NM', size(ticklabels, 2), 'both'); % Add spaces to fill

clf
bartext = [statType ' (' units ')'];

svm_contour(lx,ly,reshape(errorStat_map,length(ly),length(lx)), ...
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


%% Indicate positions of user and stations
% Radius of marker
r_lon = (ax(2)-ax(1))/100; 
r_lat=(ax(4)-ax(3))/100;
% Circle dots
circDots = (.1:.1:2);
lon_circ = r_lon * cos( circDots * pi)';
lat_circ = r_lat * sin( circDots * pi)';
% Triangle dots
lon_trian = [0 2*r_lon/sqrt(3) -2*r_lon/sqrt(3)];
lat_trian = [r_lat -r_lat -r_lat];

n_igp=size(ll_user,1);
for idx=1:n_igp
  patch(lon_circ+ll_user(idx,2), lat_circ+ll_user(idx,1), uireStatInd(idx));
end
n_stat = size(ECAC_pos, 1);
for iStat = 1:n_stat
    patch(lon_trian+ECAC_pos(iStat,1), lat_trian+ECAC_pos(iStat,2), 'k');
end

axis(ax);

title(titleText);