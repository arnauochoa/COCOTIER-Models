function [usrdata] = compute_user_stats(G_usr, W_usr, usrdata, usr2satdata)
%COMPUTE_USER_STATS Computes the mean and covariance of the position error
%for each user

global COL_U2S_UID COL_U2S_BIASUIRE COL_U2S_SIG2UIRE
global COL_USR_UID COL_USR_LL COL_USR_BIASIONO_ENUB COL_USR_SIG2IONO_ENUB

nUser = size(usrdata, 1);

% Find LOS with mean and sig2 non NaN
good_los = intersect(find(~isnan(usr2satdata(:, COL_U2S_BIASUIRE))), find(~isnan(usr2satdata(:, COL_U2S_SIG2UIRE))));

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

        % Find mean of iono error in ENU
        mu_xyzb = S * usr2satdata(iLos, COL_U2S_BIASUIRE);
        mu_enub = Rot * mu_xyzb;
        usrdata(iUser, COL_USR_BIASIONO_ENUB) = mu_enub';

        % Find Covariance of iono error in ENU
        R = diag(usr2satdata(iLos, COL_U2S_SIG2UIRE));
        cov_xyzb = S * R * S';
        var_xyzb = diag(cov_xyzb);
        var_xyzb = max(var_xyzb, 0); % remove negative values due to interpolation
        std_xyzb = sqrt(var_xyzb);
        var_enub = Rot * std_xyzb;
        usrdata(iUser, COL_USR_SIG2IONO_ENUB) = var_enub';
    end
end

end

