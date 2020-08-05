function [usrdata] = compute_user_stats(G_usr, W_usr, usrdata, usr2satdata)
%COMPUTE_USER_STATS Computes the mean and covariance of the position error
%for each user

global COL_U2S_UID COL_U2S_BIASIONO COL_U2S_SIG2IONO ...
        COL_U2S_BIASCLKEPH COL_U2S_SIGCLKEPH
global COL_USR_UID COL_USR_LL COL_USR_BIASIONO_ENUB COL_USR_SIG2IONO_ENUB ...
        COL_USR_BIASCLKEPH_ENUB COL_USR_SIGCLKEPH_ENUB

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
        Rot = eye(4);
        Rot(1:3, 1:3) = findxyz2enu(deg2rad(usrdata(iUser, COL_USR_LL(1))), ... % User Latitude in radians
                                    deg2rad(usrdata(iUser, COL_USR_LL(2))));    % User Longitude in radians

        %% Ionospheric error
        % Find mean of iono error in ENUB
        ionoMean_xyzb = S * usr2satdata(iLos, COL_U2S_BIASIONO);
        ionoMean_enub = Rot * ionoMean_xyzb;
        usrdata(iUser, COL_USR_BIASIONO_ENUB) = ionoMean_enub';

        % Find Covariance of iono error in ENUB
        R = diag(usr2satdata(iLos, COL_U2S_SIG2IONO));
        ionoCov_xyzb = S * R * S';
        ionoVar_xyzb = diag(ionoCov_xyzb);
        ionoStd_xyzb = sqrt(ionoVar_xyzb);
        ionoStd_enub = Rot * ionoStd_xyzb;
        usrdata(iUser, COL_USR_SIG2IONO_ENUB) = ionoStd_enub';
        
        %% Clock+ephemeris error
        % Find mean of clk+eph error in ENUB
        clkephMean_xyzb = S * usr2satdata(iLos, COL_U2S_BIASCLKEPH);
        clkephMean_enub = Rot * clkephMean_xyzb;
        usrdata(iUser, COL_USR_BIASCLKEPH_ENUB) = clkephMean_enub';

        % Find Covariance of clk+eph error in ENUB
        R = diag(usr2satdata(iLos, COL_U2S_SIGCLKEPH).^2);
        clkephCov_xyzb = S * R * S';
        clkephVar_xyzb = diag(clkephCov_xyzb);
        clkephStd_xyzb = sqrt(clkephVar_xyzb);
        clkephStd_enub = Rot * clkephStd_xyzb;
        usrdata(iUser, COL_USR_SIGCLKEPH_ENUB) = clkephStd_enub';
    end
end


%% TESTS
% figure; imagesc(usrdata(:, COL_USR_SIGCLKEPH_ENUB)); colorbar; title('mean');
% figure; imagesc(usrdata(:, COL_USR_BIASCLKEPH_ENUB)); colorbar; title('STD');
end

