function [] = plotIonoStatHistograms(userLL, iono_mean_enub, iono_sig2_enub)

% global GRAPH_IONOHIST_FIGNO;
global GIVE_NSE_HISTOGRAMFILE;

% Obtain positions used to plot the histograms
pos = load(GIVE_NSE_HISTOGRAMFILE);
posIdx = find(ismember(userLL, pos ,'rows'));

% Initializations
nPos = length(posIdx);
nBinsDiv = 5;

% colNames = {'lat', 'lon', 'meanEast', 'meanNorth', 'meanUp', 'meanClock', ...
%                 'stdEast', 'stdNorth', 'stdUp', 'stdClock'};
% ionoErrorStats = nan(nPos, 10);

for iPos = 1:nPos
%     S.f = figure(GRAPH_IONOHIST_FIGNO(iPos));
    S.f = figure;
    %% MEAN
    pos_iono_mean_enub = permute(iono_mean_enub(posIdx(iPos), :, :), [3 2 1]);
    nSamples = size(pos_iono_mean_enub, 1);
    % Mean East
    subplot(2, 4, 1); 
    S.h(1) = histogram(pos_iono_mean_enub(:, 1), floor(nSamples/nBinsDiv)); xlabel('\mu_E');
    % Mean North
    subplot(2, 4, 2); 
    S.h(2) = histogram(pos_iono_mean_enub(:, 2), floor(nSamples/nBinsDiv)); xlabel('\mu_N');
    % Mean Up
    subplot(2, 4, 3); 
    S.h(3) = histogram(pos_iono_mean_enub(:, 3), floor(nSamples/nBinsDiv)); xlabel('\mu_U');
    % Mean Clock Offset
    subplot(2, 4, 4); 
    S.h(4) = histogram(pos_iono_mean_enub(:, 4), floor(nSamples/nBinsDiv)); xlabel('\mu_C');
    
    %% Standard deviation
    pos_iono_sig2_enub = permute(iono_sig2_enub(posIdx(iPos), :, :), [3 2 1]);
    pos_iono_std_enub = sqrt(abs(pos_iono_sig2_enub));
    % Sigma East
    subplot(2, 4, 5); 
    S.h(5) = histogram(pos_iono_std_enub(:, 1), floor(nSamples/nBinsDiv)); xlabel('\sigma_E');
    % Sigma North
    subplot(2, 4, 6); 
    S.h(6) = histogram(pos_iono_std_enub(:, 2), floor(nSamples/nBinsDiv)); xlabel('\sigma_N');
    % Sigma Up
    subplot(2, 4, 7); 
    S.h(7) = histogram(pos_iono_std_enub(:, 3), floor(nSamples/nBinsDiv)); xlabel('\sigma_U');
    % Sigma Clock Offset
    subplot(2, 4, 8); 
    S.h(8) = histogram(pos_iono_std_enub(:, 4), floor(nSamples/nBinsDiv)); xlabel('\sigma_C');
    
    %% Figure config
    % Buttons to change nbins
    S.pb = uicontrol('style','push',...
                    'units','pix',...
                    'position',[10 10 30 30],...
                    'fontsize',14,...
                    'string','+',...
                    'callback',{@incbins,S.h});

    S.nb = uicontrol('style','push',...
                        'units','pix',...
                        'position',[50 10 30 30],...
                        'fontsize',14,...
                        'string','-',...
                        'callback',{@decbins,S.h});
    
    titleTxt = {sprintf('Distributions of \\mu_{ENUC} and \\sigma_{ENUC} at %d N, %d E', pos(iPos, :)); ...
                sprintf('Size: %d', nSamples)};
    sgtitle(titleTxt);
    figName = sprintf('Distributions at %d N, %d E', pos(iPos, :));
    set(S.f, 'Name', figName);
    set(S.f, 'Position', get(0, 'Screensize'));
    
    %% 3D histograms
    % East
    f = figure;
    dimensions = {'EAST', 'NORTH', 'UP', 'CLOCK'};
    
    for iDim = 1:length(dimensions)
        subplot(2,2,iDim);
        statsDim = [pos_iono_mean_enub(:,iDim), pos_iono_std_enub(:,iDim)];
        hist3(statsDim, 'CDataMode','auto','FaceColor','interp'); 
        xlabel(['\mu_{' dimensions{iDim} '}']);
        ylabel(['\sigma_{' dimensions{iDim} '}']);
        
    end

    
    titleTxt = {sprintf('3D Distributions of coupled \\mu_{ENUC} and \\sigma_{ENUC} at %d N, %d E', pos(iPos, :)); ...
                sprintf('Size: %d', nSamples)};
    sgtitle(titleTxt);
    figName = sprintf('3D distributions at %d N, %d E', pos(iPos, :));
    set(f, 'Name', figName); 
    set(f, 'Position', get(0, 'Screensize'));
end

end

function incbins(varargin)
    morebins(varargin{3});
end

function decbins(varargin)
    fewerbins(varargin{3});
end