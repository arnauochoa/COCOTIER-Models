function [prctile_iono_mean_enub, prctile_iono_std_enub] = findStatPrctiles(iono_mean_enub, iono_sig_enub, percent)

[nUser, nDim, nTstep] = size(iono_mean_enub);

prctile_iono_mean_enub = nan(nUser, nDim);
prctile_iono_std_enub = nan(nUser, nDim);

% Indices of diagonal in reshaped cov matrix

for iUser = 1:nUser
    % Find mean percentile for each dimension
    user_means = permute(iono_mean_enub(iUser, :, :), [3 2 1]);
    prctile_iono_mean_enub(iUser, :) = prctile(user_means, percent, 1);
    
    % Find std percentile for each  dimension
    user_stds = permute(iono_sig_enub(iUser, :, :), [3 2 1]);
    prctile_iono_std_enub(iUser, :) = prctile(user_stds, percent, 1);
end


end