function [] = plotIonoStatHistograms(userLL, pos, iono_mean_enub, iono_sig2_enub)

global GRAPH_IONOHIST_FIGNO;

posIdx = find(ismember(userLL, pos ,'rows'));
nPos = length(posIdx);

% colNames = {'lat', 'lon', 'meanEast', 'meanNorth', 'meanUp', 'meanClock', ...
%                 'stdEast', 'stdNorth', 'stdUp', 'stdClock'};
% ionoErrorStats = nan(nPos, 10);

for iPos = 1:nPos
    h = figure(GRAPH_IONOHIST_FIGNO(iPos));
    %% MEAN
    pos_iono_mean_enub = permute(iono_mean_enub(posIdx(iPos), :, :), [3 2 1]);
    % Mean East
    subplot(2, 4, 1); 
    histogram(pos_iono_mean_enub(:, 1)); xlabel('\mu_E');
    % Mean North
    subplot(2, 4, 2); 
    histogram(pos_iono_mean_enub(:, 2)); xlabel('\mu_N');
    % Mean Up
    subplot(2, 4, 3); 
    histogram(pos_iono_mean_enub(:, 3)); xlabel('\mu_U');
    % Mean Clock Offset
    subplot(2, 4, 4); 
    histogram(pos_iono_mean_enub(:, 4)); xlabel('\mu_B');
    
    %% Standard deviation
    pos_iono_sig2_enub = permute(iono_sig2_enub(posIdx(iPos), :, :), [3 2 1]);
    pos_iono_std_enub = sqrt(abs(pos_iono_sig2_enub));
    % Sigma East
    subplot(2, 4, 5); 
    histogram(pos_iono_std_enub(:, 1)); xlabel('\sigma_E');
    % Sigma North
    subplot(2, 4, 6); 
    histogram(pos_iono_std_enub(:, 2)); xlabel('\sigma_N');
    % Sigma Up
    subplot(2, 4, 7); 
    histogram(pos_iono_std_enub(:, 3)); xlabel('\sigma_U');
    % Sigma Clock Offset
    subplot(2, 4, 8); 
    histogram(pos_iono_std_enub(:, 4)); xlabel('\sigma_B');
    
    nSamples = size(pos_iono_mean_enub, 1);
    titleTxt = {sprintf('Distributions of \\mu_{ENU} and \\sigma_{ENU} at %d N, %d E', pos(iPos, :)); ...
                sprintf('Size: %d', nSamples)};
    sgtitle(titleTxt);
    figName = sprintf('Distributions at %d N, %d E', pos(iPos, :));
    set(h, 'Name', figName);
    set(h, 'Position', get(0, 'Screensize'));
end

end