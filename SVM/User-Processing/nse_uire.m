function [mu_uire, sig2_uire, Uire] = nse_uire(usrdata, usr2satdata, good_los)
%NSE_UIRE Computes the UIRE statistics with the NSE
%model
%   This function computes the UIRE statistics (bias and variance) with the
%   NSE model from real data

global GIVE_NSE_RESULTSFILE GIVE_NSE_STATIONSFILE
global COL_U2S_EL
global COL_USR_UID COL_USR_LL

% Read data
% Load files - TODO: generalize
load(GIVE_NSE_RESULTSFILE, 'Result_MeanMat', 'Result_SizeMat', 'Result_StdMat', 'el_bin');
load(GIVE_NSE_STATIONSFILE, 'ECAC_pos');

nlos = size(usr2satdata, 1);
sig2_uire = nan(nlos,1);    % User Ionospheric Range Error variance
mu_uire = nan(nlos,1);    % User Ionospheric Range Error variance

nUser = size(usrdata, 1);
nElBins = length(el_bin) - 1;
uireMean = nan(nUser, nElBins);
uireStd = nan(nUser, nElBins);

% Find mu and sigma at each user position
for iElev = 1:length(el_bin)-1
    % Find minimum and maximum elevation of current bin in radians
    minElev = deg2rad(el_bin(iElev));
    maxElev = deg2rad(el_bin(iElev+1));
    
    % Create interpolation object
    meanInterp = scatteredInterpolant(ECAC_pos(:,1),ECAC_pos(:,2),Result_MeanMat(:,iElev),'linear','none');
    stdInterp = scatteredInterpolant(ECAC_pos(:,1),ECAC_pos(:,2),Result_StdMat(:,iElev),'linear','none');
    
    % Interpolate over user positions
    uireMean(:, iElev) = meanInterp(usrdata(:, COL_USR_LL(2)), usrdata(:, COL_USR_LL(1)));
    uireStd(:, iElev) = stdInterp(usrdata(:, COL_USR_LL(2)), usrdata(:, COL_USR_LL(1)));
    
    % Find LOS in elevation bin
    losInBin = find((usr2satdata(:, COL_U2S_EL)>minElev & usr2satdata(:, COL_U2S_EL)<=maxElev));
    % Find good LOS in elevation bin
    goodLosInBin = intersect(losInBin, good_los);
    
    %% TODO: Test this:
%     userInd = find(usrdata(:, COL_USR_UID) == usr2satdata(binIndx, COL_USR_UID));
%     userLL = usrdata(userInd, COL_USR_LL);
%     usr2satdata(binIndx, COL_U2S_BIASUIRE) = Mean(usr2satdata(binIndx,)
    if ~isempty(goodLosInBin)
        for i = 1:length(goodLosInBin)
            % Find user position
            userLL = usrdata(usrdata(:, COL_USR_UID) == usr2satdata(goodLosInBin(i), COL_USR_UID), COL_USR_LL);

            % assign mean and std to los
            mu_uire(goodLosInBin(i)) = meanInterp(userLL(2), userLL(1));
            sig2_uire(goodLosInBin(i)) = stdInterp(userLL(2), userLL(1))^2;
        end
    end 
    
end

% Return values
Uire.mean   = uireMean;
Uire.std    = uireStd;
Uire.elBins = el_bin;

% TESTS
% ind = all(isnan(uireMean), 2);
% figure;
% scatter(usrdata(:, COL_USR_LL(2)), usrdata(:, COL_USR_LL(1)))
% hold on
% scatter(usrdata(ind, COL_USR_LL(2)), usrdata(ind, COL_USR_LL(1)), 'r')
% figure; imagesc(uireMean); colorbar; title('Mean');
% figure; imagesc(uireStd); colorbar; title('Std');
end

