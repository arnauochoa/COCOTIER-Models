function igpdata = af_givensemodel(t, igpdata, wrsdata, satdata, wrs2satdata,truth_data)
% AF_GIVENSEMODEL: Computes Iono error bias and STD for IGP over ECAC from
% IGS data
%
% Inputs:
%     
%
% 
% $Revision: R2020a$ 
% $Author: Arnau Ochoa Banuelos$
% $Date: July 6, 2020$
%---------------------------------------------------------

global COL_IGP_LL

% Load files
load('Allstations_IONO_results_full2014.mat');  % TODO: generalize
load('ECAC_stations_position.mat');             % TODO: generalize


% Adjust IGP longitude to -180 to 180
ll_igp=igpdata(:, COL_IGP_LL); 
idx=find(ll_igp(:,2)>=180);
ll_igp(idx,2)=ll_igp(idx,2)-360;
% figure; scatter(ll_igp(:, 2), ll_igp(:, 1)); % For testing

% Generate grid of IGP
[LatGrid, LonGrid] = meshgrid(ll_igp(:, 1), ll_igp(:, 2));

% Mean and STD generalize to any elevation

% Interpolate Mean and STD

% Save interpolated Mean and STD to **NEW** columns of igpdata


end

