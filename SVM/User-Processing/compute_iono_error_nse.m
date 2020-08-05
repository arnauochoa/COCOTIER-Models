function [IonoError, usrdata, usr2satdata] = compute_iono_error_nse(usrdata, usr2satdata, good_los)
%COMPUTE_IONO_ERROR_NSE Computes the IONO ERROR statistics with the NSE
%model
%   This function computes the IONO ERROR statistics (bias and variance) with 
% the NSE model from real data

global IONO_NSE_RESULTSFILE IONO_NSE_STATIONSFILE
global COL_U2S_UID COL_U2S_EL COL_U2S_BIASIONO COL_U2S_SIGIONO COL_U2S_SIG2IONO
global COL_USR_UID COL_USR_LL

% Read data
% Load files - TODO: generalize
load(IONO_NSE_RESULTSFILE, 'Result_MeanMat', 'Result_SizeMat', 'Result_StdMat', 'el_bin');
load(IONO_NSE_STATIONSFILE, 'ECAC_pos');

nUser = size(usrdata, 1);
nElBins = length(el_bin) - 1;
ionoErrMean = nan(nUser, nElBins);
ionoErrStd = nan(nUser, nElBins);

% Find mu and sigma at each user position
for iElev = 1:length(el_bin)-1
    % Find minimum and maximum elevation of current bin in radians
    minElev = deg2rad(el_bin(iElev));
    maxElev = deg2rad(el_bin(iElev+1));

    % Create interpolation object
    meanInterp = scatteredInterpolant(ECAC_pos(:,1),ECAC_pos(:,2),Result_MeanMat(:,iElev),'linear','nearest');
    stdInterp = scatteredInterpolant(ECAC_pos(:,1),ECAC_pos(:,2),Result_StdMat(:,iElev),'linear','nearest');

    % Interpolate over user positions
    ionoErrMean(:, iElev) = meanInterp(usrdata(:, COL_USR_LL(2)), usrdata(:, COL_USR_LL(1)));
    ionoErrStd(:, iElev) = stdInterp(usrdata(:, COL_USR_LL(2)), usrdata(:, COL_USR_LL(1)));
    % Correct for negative STD
    negStdInd = ionoErrStd(:, iElev) < 0;
    ionoErrStd(negStdInd, iElev) = 0;

    % Find LOS in elevation bin
    losInBin = find((usr2satdata(:, COL_U2S_EL)>minElev & usr2satdata(:, COL_U2S_EL)<=maxElev));
    % Find good LOS in elevation bin
    goodLosInBin = intersect(losInBin, good_los);

    if ~isempty(goodLosInBin)
        for i = 1:length(goodLosInBin)
            % Find user position
            aux = find(usrdata(:, COL_USR_UID) == usr2satdata(goodLosInBin(i), COL_U2S_UID));
            userLL = usrdata(usrdata(:, COL_USR_UID) == usr2satdata(goodLosInBin(i), COL_U2S_UID), COL_USR_LL);

            % assign mean and std to los
            usr2satdata(goodLosInBin(i), COL_U2S_BIASIONO) = meanInterp(userLL(2), userLL(1));
            usr2satdata(goodLosInBin(i), COL_U2S_SIGIONO) = stdInterp(userLL(2), userLL(1));
            % Correct for negative STD
            if usr2satdata(goodLosInBin(i), COL_U2S_SIGIONO) < 0
                usr2satdata(goodLosInBin(i), COL_U2S_SIGIONO) = 0;
            end
            usr2satdata(goodLosInBin(i), COL_U2S_SIG2IONO) = usr2satdata(goodLosInBin(i), COL_U2S_SIGIONO)^2;
        end
    end

end

% Return values
IonoError.mean   = ionoErrMean;
IonoError.std    = ionoErrStd;
IonoError.elBins = el_bin;

% TESTS
% ind = all(isnan(ionoErrMean), 2);
% figure;
% scatter(usrdata(:, COL_USR_LL(2)), usrdata(:, COL_USR_LL(1)))
% hold on
% scatter(usrdata(ind, COL_USR_LL(2)), usrdata(ind, COL_USR_LL(1)), 'r')
% figure; imagesc(ionoErrMean); colorbar; title('Mean');
% figure; imagesc(ionoErrStd); colorbar; title('Std');
end
