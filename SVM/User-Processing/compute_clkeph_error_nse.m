function [ClockEphError, usr2satdata] = compute_clkeph_error_nse(usrdata, usr2satdata, good_los)
% COMPUTE_CLOCKEPH_ERROR_NSE Computes the CLOCK+EPHEMERIS ERROR statistics
%   This function computes the CLOCK+EPHEMERIS ERROR statistics (bias and 
%   variance) with the NSE model from real data obtained from Quentin
%   Tessier's project.
%   
%   DATA MATRICES:      - elBins:       1xN+1.    Edges of elevation bins. N is num bins
%                       - latlon:       2xM.      Positions of user grid. M is num pos
%                       - clkephMeanEl: MxN.      Mean clock+eph range error.
%                       - clkephStdEl:  MxN.      Mean clock+eph range error.
%
% =========================================================================
% Created by Arnau Ochoa Bañuelos July 2020 for the COCOTIER project

global COL_USR_UID COL_USR_LL
global COL_U2S_UID COL_U2S_EL COL_U2S_BIASCLKEPH COL_U2S_SIGCLKEPH
global CLKEPH_NSE_RESULTSFILE

% Read data
load(CLKEPH_NSE_RESULTSFILE, 'elBins', 'latlon', 'clkephMeanEl', 'clkephStdEl');

nUser = size(usrdata, 1);
nElBins = length(elBins) - 1;
clkephErrMean = nan(nUser, nElBins);
clkephErrStd = nan(nUser, nElBins);

for iElev = 1:length(elBins)-1
    % Find minimum and maximum elevation of current bin in radians
    minElev = deg2rad(elBins(iElev));
    maxElev = deg2rad(elBins(iElev+1));

    % Create interpolation object
    meanInterp = scatteredInterpolant(latlon(:,1),latlon(:,2),clkephMeanEl(:,iElev),'linear','none');
    stdInterp = scatteredInterpolant(latlon(:,1),latlon(:,2),clkephStdEl(:,iElev),'linear','none');

    % Interpolate over user positions
    clkephErrMean(:, iElev) = meanInterp(usrdata(:, COL_USR_LL(1)), usrdata(:, COL_USR_LL(2)));
    clkephErrStd(:, iElev) = stdInterp(usrdata(:, COL_USR_LL(1)), usrdata(:, COL_USR_LL(2)));
    % Correct for negative STD
    negStdInd = clkephErrStd(:, iElev) < 0;
    clkephErrStd(negStdInd, iElev) = 0;

    % Find LOS in elevation bin
    losInBin = find((usr2satdata(:, COL_U2S_EL)>minElev & usr2satdata(:, COL_U2S_EL)<=maxElev));
    % Find good LOS in elevation bin
    goodLosInBin = intersect(losInBin, good_los);

    if ~isempty(goodLosInBin)
        for i = 1:length(goodLosInBin)
            % Find user position
            userLL = usrdata(usrdata(:, COL_USR_UID) == usr2satdata(goodLosInBin(i), COL_U2S_UID), COL_USR_LL);
            
            % assign mean and std to los
            usr2satdata(goodLosInBin(i), COL_U2S_BIASCLKEPH) = meanInterp(userLL(1), userLL(2));
            usr2satdata(goodLosInBin(i), COL_U2S_SIGCLKEPH) = stdInterp(userLL(1), userLL(2));
            % Correct for negative STD
            if usr2satdata(goodLosInBin(i), COL_U2S_SIGCLKEPH) < 0
                usr2satdata(goodLosInBin(i), COL_U2S_SIGCLKEPH) = 0;
            end
        end
    end

end

ClockEphError.mean      = clkephErrMean;
ClockEphError.std       = clkephErrStd;
ClockEphError.elBins    = elBins;

% TESTS
% ind = all(isnan(clkephMeanUsr), 2);
% figure;
% scatter(usrdata(:, COL_USR_LL(2)), usrdata(:, COL_USR_LL(1)))
% hold on
% scatter(usrdata(ind, COL_USR_LL(2)), usrdata(ind, COL_USR_LL(1)), 'r')
% figure; imagesc(elBins, 1:nUser, clkephMeanUsr); colorbar; 
% title('Mean'); xlabel('elevation'); ylabel('user');
% figure; imagesc(elBins, 1:nUser, clkephStdUsr); colorbar; 
% title('Std'); xlabel('elevation'); ylabel('user');
% figure; plot(usr2satdata(:, COL_U2S_BIASCLKEPH)); xlabel('LOS'); ylabel('\mu');
% figure; plot(usr2satdata(:, COL_U2S_SIGCLKEPH)); xlabel('LOS'); ylabel('\sigma');
end