function igpdata = af_give_nsemodel(t, igpdata, wrsdata, satdata, wrs2satdata,truth_data)
% AF_GIVENSEMODEL: Returns the GIVE variances for each IGP
%   AF_GIVENSEMODEL Returns the GIVE variances for each IGP, computed from
%   from the mean and STD that have been obtained in real life
%
% Inputs:
%       t:          current time
%       igpdata:    matrix with the data of the IGP (see MAAST doc)
%       wrsdata:    matrix with the data of the WRS (see MAAST doc)
%       satdata:    matrix with the data of the Satellites (see MAAST doc)
%
% 
% $Revision: R2020a$ 
% $Author: Arnau Ochoa Banuelos$
% $Date: July 6, 2020$
%---------------------------------------------------------

global COL_IGP_LL COL_IGP_BIAS COL_IGP_STD COL_IGP_MINMON 
global COL_IGP_GIVEI COL_IGP_UPMGIVEI
global MOPS_GIVE MOPS_GIVEI_NM MOPS_MU_GIVE MOPS_SIG_GIVE
global GIVE_NSE_RESULTSFILE GIVE_NSE_STATIONSFILE

n_igp = size(igpdata,1);

% Load files - TODO: generalize
load(GIVE_NSE_RESULTSFILE, 'Result_MeanMat', 'Result_SizeMat', 'Result_StdMat');
load(GIVE_NSE_STATIONSFILE, 'ECAC_pos');

% Adjust IGP longitude to -180 to 180
ll_igp=igpdata(:, COL_IGP_LL); 
idx=find(ll_igp(:,2)>=180);
ll_igp(idx,2)=ll_igp(idx,2)-360;

% Generate grid of IGP
% [LatGrid, LonGrid] = meshgrid(ll_igp(:, 1), ll_igp(:, 2));

% Mean and STD generalize to any elevation
giveBias = nansum((Result_MeanMat.*Result_SizeMat), 2)./nansum(Result_SizeMat, 2);
giveSTD = nansum((Result_StdMat.*Result_SizeMat), 2)./nansum(Result_SizeMat, 2);

% Interpolate Mean and STD. * ECAC_pos is Lon, Lat
biasInterpolant = scatteredInterpolant(ECAC_pos(:,2), ECAC_pos(:,1), giveBias,'linear','none');
stdInterpolant = scatteredInterpolant(ECAC_pos(:,2), ECAC_pos(:,1), giveSTD,'linear','none');

% Save interpolated Mean and STD to **NEW** columns of igpdata
giveBias = biasInterpolant(ll_igp(:, 1), ll_igp(:, 2));
giveStd = stdInterpolant(ll_igp(:, 1), ll_igp(:, 2));

% Generate error from bias and std
giveErr = abs(normrnd(giveBias, giveStd));
% giveErr = giveBias + 2.*giveStd;

% Find MOPS_GIVE intervals corresponding to GIVE values and assign index
indBias = find(giveBias <= MOPS_MU_GIVE(1));
indStd = find(giveStd <= MOPS_SIG_GIVE(1));
indErr = find(giveErr > 0 & giveErr <= MOPS_GIVE(1));

if ~isempty(indBias), igpdata(indBias, COL_IGP_BIAS) = 1; end
if ~isempty(indStd), igpdata(indStd, COL_IGP_STD) = 1; end
if ~isempty(indErr)
    igpdata(indErr, [COL_IGP_GIVEI COL_IGP_UPMGIVEI]) = 1;
end

for iMOPS = 2:length(MOPS_GIVE)-1
    indBias = find(giveBias > MOPS_MU_GIVE(iMOPS-1) & giveBias <= MOPS_MU_GIVE(iMOPS));
    indStd = find(giveStd > MOPS_SIG_GIVE(iMOPS-1) & giveStd <= MOPS_SIG_GIVE(iMOPS));
    indErr = find(giveErr > MOPS_GIVE(iMOPS-1) & giveErr <= MOPS_GIVE(iMOPS));
    if ~isempty(indBias), igpdata(indBias, COL_IGP_BIAS) = iMOPS; end
    if ~isempty(indStd), igpdata(indStd, COL_IGP_STD) = iMOPS; end
    if ~isempty(indErr)
        igpdata(indErr, [COL_IGP_GIVEI COL_IGP_UPMGIVEI]) = iMOPS;
    end
end

indBias = find(giveBias > MOPS_MU_GIVE(iMOPS));
indStd = find(giveStd > MOPS_SIG_GIVE(iMOPS));
if ~isempty(indBias), igpdata(indBias, COL_IGP_BIAS) = iMOPS; end
if ~isempty(indStd), igpdata(indStd, COL_IGP_STD) = iMOPS; end

% Assign MOPS_GIVEI_NM to NaN values
indBias = isnan(giveBias);
indStd = isnan(giveStd);
indErr = isnan(giveErr);
igpdata(indBias, COL_IGP_BIAS) = MOPS_GIVEI_NM;
igpdata(indStd, COL_IGP_STD) = MOPS_GIVEI_NM;
igpdata(indErr, [COL_IGP_GIVEI COL_IGP_UPMGIVEI]) = MOPS_GIVEI_NM;

%return values
%all IGPs meet the minimum monitoring requirements (used for histogram)
igpdata(:,COL_IGP_MINMON)=ones(n_igp,1);

% figure; scatter(ll_igp(:, 2), ll_igp(:, 1)); % For testing
% hold on
% scatter(ll_igp(isnan(igpdata(:, COL_IGP_BIAS)), 2), ll_igp(isnan(igpdata(:, COL_IGP_BIAS)), 1), 'r');
% scatter(ECAC_pos(:,1), ECAC_pos(:,2), 'x', 'k');
% legend('IGP', 'NaN IGP', 'ECAC stations');
end

