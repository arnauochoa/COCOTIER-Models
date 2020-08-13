function [usrdata] = compute_user_stats(G_usr, W_usr, usrdata, usr2satdata)
%COMPUTE_USER_STATS Computes the mean and STD of the position errors
%for each user
%
% =========================================================================
% Created by Arnau Ochoa Bañuelos July 2020 for the COCOTIER project


global COL_U2S_UID COL_U2S_BIASIONO COL_U2S_SIG2IONO ...
        COL_U2S_BIASCLKEPH COL_U2S_SIGCLKEPH ...
        COL_U2S_BIASTOTAL COL_U2S_SIGTOTAL
global COL_USR_UID COL_USR_BIASIONO_ENUB COL_USR_SIGIONO_ENUB ...
        COL_USR_BIASCLKEPH_ENUB COL_USR_SIGCLKEPH_ENUB ...
        COL_USR_BIASTOTAL_ENUB COL_USR_SIGTOTAL_ENUB

nUser = size(usrdata, 1);

% Find LOS with mean and sig2 non NaN
good_los = intersect(find(~isnan(usr2satdata(:, COL_U2S_BIASIONO))), find(~isnan(usr2satdata(:, COL_U2S_SIG2IONO))));

for iUser = 1:nUser
    % Find current user LOS indices
    iLos = find(usr2satdata(:, COL_U2S_UID) == usrdata(iUser, COL_USR_UID));
    iLos = intersect(iLos, good_los);
    
    if ~isempty(iLos)
        % Find weighted pseudoinverse matrix
        S = (G_usr{iUser}' * W_usr{iUser} * G_usr{iUser}) \ G_usr{iUser}' * W_usr{iUser}; % deal with singular matrix **

        % Find rotation matrix to go from XYZB to ENUB
%         Rot = eye(4);
%         Rot(1:3, 1:3) = findxyz2enu(deg2rad(usrdata(iUser, COL_USR_LL(1))), ... % User Latitude in radians
%                                     deg2rad(usrdata(iUser, COL_USR_LL(2))));    % User Longitude in radians

        %% Ionospheric residual error
        % Find mean of iono error in ENUB
        ionoMean_enub = S * usr2satdata(iLos, COL_U2S_BIASIONO);
%         ionoMean_enub = Rot * ionoMean_xyzb;
        usrdata(iUser, COL_USR_BIASIONO_ENUB) = ionoMean_enub';

        % Find Covariance of iono error in ENUB
        R = diag(usr2satdata(iLos, COL_U2S_SIG2IONO).^2);
        ionoCov_enub = S * R * S';
        ionoVar_enub = diag(ionoCov_enub);
        ionoStd_enub = sqrt(ionoVar_enub);
%         ionoStd_enub = Rot * ionoStd_xyzb;
        usrdata(iUser, COL_USR_SIGIONO_ENUB) = ionoStd_enub';
        
        %% Clock+ephemeris residual error
        % Find mean of clk+eph error in ENUB
        clkephMean_enub = S * usr2satdata(iLos, COL_U2S_BIASCLKEPH);
%         clkephMean_enub = Rot * clkephMean_xyzb;
        usrdata(iUser, COL_USR_BIASCLKEPH_ENUB) = clkephMean_enub';

        % Find Covariance of clk+eph error in ENUB
        R = diag(usr2satdata(iLos, COL_U2S_SIGCLKEPH).^2);
        clkephCov_enub = S * R * S';
        clkephVar_enub = diag(clkephCov_enub);
        clkephStd_enub = sqrt(clkephVar_enub);
%         clkephStd_enub = Rot * clkephStd_xyzb;
        usrdata(iUser, COL_USR_SIGCLKEPH_ENUB) = clkephStd_enub';
        
        %% Total residual error
        % Find mean of total error in ENUB
        totalMean_enub = S * usr2satdata(iLos, COL_U2S_BIASTOTAL);
        usrdata(iUser, COL_USR_BIASTOTAL_ENUB) = totalMean_enub';

        % Find Covariance of total error in ENUB
        R = diag(usr2satdata(iLos, COL_U2S_SIGTOTAL).^2);
        totalCov_enub = S * R * S';
        totalVar_enub = diag(totalCov_enub);
        totalStd_enub = sqrt(totalVar_enub);
%         clkephStd_enub = Rot * clkephStd_xyzb;
        usrdata(iUser, COL_USR_SIGTOTAL_ENUB) = totalStd_enub';
    end
end


%% TESTS
% figure; imagesc(usrdata(:, COL_USR_SIGCLKEPH_ENUB)); colorbar; title('mean');
% figure; imagesc(usrdata(:, COL_USR_BIASCLKEPH_ENUB)); colorbar; title('STD');
end

