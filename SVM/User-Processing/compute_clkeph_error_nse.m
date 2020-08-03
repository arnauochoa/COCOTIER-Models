function [ClockEphError, usr2satdata] = compute_clkeph_error_nse(usrdata, usr2satdata, good_los)
%COMPUTE_CLOCKEPH_ERROR_NSE Computes the CLOCK+EPHEMERIS ERROR statistics 
%with the NSE model
%   This function computes the CLOCK+EPHEMERIS ERROR statistics (bias and 
%   variance) with the NSE model from real data

global COL_USR_UID COL_USR_LL
global COL_U2S_UID COL_U2S_EL COL_U2S_BIASCLKEPH COL_U2S_SIGCLKEPH

% TODO: set as global and define in another place
CLKEPH_NSE_RESULTSFILE = 'Data/NSE/CLKEPH_results_y2014_NGA.mat';

% Read data
load(CLKEPH_NSE_RESULTSFILE, 'elBins', 'latlon', 'clkephMeanEl', 'clkephStdEl');

nUser = size(usrdata, 1);
nElBins = length(elBins) - 1;
clkephMeanUsr = nan(nUser, nElBins);
clkephStdUsr = nan(nUser, nElBins);

% Find mu and sigma at each user position
for iUser = 1:nUser
    userId = usrdata(iUser, COL_USR_UID);
    
    iUserPos = ismember(latlon, usrdata(iUser, COL_USR_LL), 'rows');
    if any(iUserPos) % If user pos is in results data
        % Save mean and std of current user for all elevations
        clkephMeanUsr(iUser, :) = clkephMeanEl(iUserPos, :);
        clkephStdUsr(iUser, :) = clkephStdEl(iUserPos, :);
        
        userLos = find(usr2satdata(:, COL_U2S_UID) == userId);
        goodUserLos = intersect(good_los, userLos);
        
        for iLos = 1:length(goodUserLos)
            elBin = find(elBins < rad2deg(usr2satdata(goodUserLos(iLos), COL_U2S_EL)), 1, 'last');
            usr2satdata(goodUserLos(iLos), COL_U2S_BIASCLKEPH) = clkephMeanEl(iUserPos, elBin);
            usr2satdata(goodUserLos(iLos), COL_U2S_SIGCLKEPH) = clkephStdEl(iUserPos, elBin);
        end
    end
end

ClockEphError.mean      = clkephMeanUsr;
ClockEphError.std       = clkephStdUsr;
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