function [prctile_err_mean_enub, prctile_err_std_enub] = findStatPrctiles(error_mean_enub, error_sig_enub, percent)
% FINDSTATPRCTILES Finds the percentiles of the given error statistic
%
% =========================================================================
% Created by Arnau Ochoa Bañuelos August 2020 for the COCOTIER project

[nUser, nDim, nTstep] = size(error_mean_enub);

prctile_err_mean_enub = nan(nUser, nDim);
prctile_err_std_enub = nan(nUser, nDim);

% Indices of diagonal in reshaped cov matrix

for iUser = 1:nUser
    % Find mean percentile for each dimension
    user_means = permute(error_mean_enub(iUser, :, :), [3 2 1]);
    prctile_err_mean_enub(iUser, :) = prctile(user_means, 100*percent, 1);
    
    % Find std percentile for each  dimension
    user_stds = permute(error_sig_enub(iUser, :, :), [3 2 1]);
    prctile_err_std_enub(iUser, :) = prctile(user_stds, 100*percent, 1);
end


end