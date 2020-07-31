function [Uire, usrdata, usr2satdata] = af_nse_uire(usrdata, usr2satdata, good_los)
%NSE_UIRE Computes the UIRE statistics with the NSE
%model
%   This function computes the UIRE statistics (bias and variance) with the
%   NSE model from real data

global GIVE_NSE_RESULTSFILE GIVE_NSE_STATIONSFILE
global COL_U2S_UID COL_U2S_EL COL_U2S_GENUB COL_U2S_BIASUIRE COL_U2S_SIG2UIRE COL_U2S_BIASUIRE_ENU COL_U2S_SIG2UIRE_ENU
global COL_USR_UID COL_USR_LL COL_USR_BIASUIRE_ENU COL_USR_SIG2UIRE_ENU

% Read data
% Load files - TODO: generalize
load(GIVE_NSE_RESULTSFILE, 'Result_MeanMat', 'Result_SizeMat', 'Result_StdMat', 'el_bin');
load(GIVE_NSE_STATIONSFILE, 'ECAC_pos');

% nlos = size(usr2satdata, 1);
% sig2_uire = nan(nlos,1);    % User Ionospheric Range Error variance
% mu_uire = nan(nlos,1);    % User Ionospheric Range Error variance

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
    meanInterp = scatteredInterpolant(ECAC_pos(:,1),ECAC_pos(:,2),Result_MeanMat(:,iElev),'nearest','nearest');
    stdInterp = scatteredInterpolant(ECAC_pos(:,1),ECAC_pos(:,2),Result_StdMat(:,iElev),'nearest','nearest');
    
    % Interpolate over user positions
    uireMean(:, iElev) = meanInterp(usrdata(:, COL_USR_LL(2)), usrdata(:, COL_USR_LL(1)));
    uireStd(:, iElev) = stdInterp(usrdata(:, COL_USR_LL(2)), usrdata(:, COL_USR_LL(1)));

%     % Interpolate over user positions
%     uireMean(:, iElev) = interp2(   ECAC_pos(:,1),              ... % Station's Longitude
%                                     ECAC_pos(:,2),              ... % Station's Latitude
%                                     Result_MeanMat(:,iElev),    ... % Iono range error Mean
%                                     usrdata(:, COL_USR_LL(2)),  ... % User's Longitude
%                                     usrdata(:, COL_USR_LL(1)),  ... % User's Latitude
%                                     'linear' );                     % Interpolation method
%                                        
%     uireStd(:, iElev) = interp2(    ECAC_pos(:,1),              ... % Station's Longitude
%                                     ECAC_pos(:,2),              ... % Station's Latitude
%                                     Result_StdMat(:,iElev),     ... % Iono range error STD
%                                     usrdata(:, COL_USR_LL(2)),  ... % User's Longitude
%                                     usrdata(:, COL_USR_LL(1)),  ... % User's Latitude
%                                     'linear' );                     % Interpolation method
%     
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
            userLL = usrdata(usrdata(:, COL_USR_UID) == usr2satdata(goodLosInBin(i), COL_U2S_UID), COL_USR_LL);

            % assign mean and std to los
            usr2satdata(goodLosInBin(i), COL_U2S_BIASUIRE) = meanInterp(userLL(2), userLL(1));
            usr2satdata(goodLosInBin(i), COL_U2S_SIG2UIRE) = stdInterp(userLL(2), userLL(1))^2;
        end
    end 
    
end

% Project mu and sigma over ENU for each LOS
usr2satdata(:, COL_U2S_BIASUIRE_ENU) = usr2satdata(:, COL_U2S_GENUB(1:3)) .* usr2satdata(:, COL_U2S_BIASUIRE);
usr2satdata(:, COL_U2S_SIG2UIRE_ENU) = usr2satdata(:, COL_U2S_GENUB(1:3)) .* usr2satdata(:, COL_U2S_SIG2UIRE);

% for usr = 1:nUser
%    userLos = usr2satdata(:, COL_U2S_UID) == usrdata(usr, COL_USR_UID);
%    
%    if all(isnan(usr2satdata(userLos, COL_U2S_BIASUIRE_ENU)), 1)
%        usrdata(usr, COL_USR_BIASUIRE_ENU) = nan(1, 3);
%    else
%        usrdata(usr, COL_USR_BIASUIRE_ENU) = nansum(usr2satdata(userLos, COL_U2S_BIASUIRE_ENU), 1);
%    end
%    if all(isnan(usr2satdata(userLos, COL_USR_SIG2UIRE_ENU)), 1)
%        usrdata(usr, COL_USR_SIG2UIRE_ENU) = nan(1, 3);
%    else
%        usrdata(usr, COL_USR_SIG2UIRE_ENU) = abs(nansum(usr2satdata(userLos, COL_U2S_SIG2UIRE_ENU), 1));
%    end
% end

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

