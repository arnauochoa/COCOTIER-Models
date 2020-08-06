function [] = plotStatHistograms(userLL, error_mean_enub, error_sig_enub, errorType)

global OUTPUT_IONO_LABEL OUTPUT_CLKEPH_LABEL OUTPUT_TOTAL_LABEL
global GRAPH_IONOHIST_FIGNO GRAPH_CLKEPHHIST_FIGNO GRAPH_TOTALHIST_FIGNO;
global IONO_NSE_HISTOGRAMFILE;


switch errorType
    case OUTPUT_IONO_LABEL
        % Obtain positions used to plot the histograms
        pos = load(IONO_NSE_HISTOGRAMFILE);
        figNo = GRAPH_IONOHIST_FIGNO;
    case OUTPUT_CLKEPH_LABEL
        pos = load(IONO_NSE_HISTOGRAMFILE); % TODO define in init
        figNo = GRAPH_CLKEPHHIST_FIGNO;
    case OUTPUT_TOTAL_LABEL
        pos = load(IONO_NSE_HISTOGRAMFILE); % TODO define in init
        figNo = GRAPH_TOTALHIST_FIGNO;
    otherwise
        error('Wrong input argument for errorType');
end
        
posIdx = find(ismember(userLL, pos ,'rows'));

% Initializations
nPos = length(posIdx);

dimensions = {'EAST', 'NORTH', 'UP', 'CLOCK'};
nDim = length(dimensions);

for iPos = 1:nPos
    S.f = figure(figNo(iPos));
    % Mean
    pos_error_mean_enub = permute(error_mean_enub(posIdx(iPos), :, :), [3 2 1]);
    % Standard deviation
    pos_error_std_enub = permute(error_sig_enub(posIdx(iPos), :, :), [3 2 1]);
    
    nSamples = size(pos_error_mean_enub, 1);
    
    for iDim = 1:nDim
        % Mean histogram
        subplot(2, 4, iDim);
        S.h(iDim) = histogram(pos_error_mean_enub(:, iDim)); 
        xlabel(['\mu_{' dimensions(iDim) '}']);
        
        % STD histogram
        subplot(2, 4, iDim+nDim); 
        S.h(iDim+nDim) = histogram(pos_error_std_enub(:, iDim)); 
        xlabel(['\sigma_{' dimensions(iDim) '}']);
    end
    
    %% Standard deviation

    % Sigma East
    subplot(2, 4, 5); 
    S.h(5) = histogram(pos_error_std_enub(:, 1)); xlabel('\sigma_E');
    % Sigma North
    subplot(2, 4, 6); 
    S.h(6) = histogram(pos_error_std_enub(:, 2)); xlabel('\sigma_N');
    % Sigma Up
    subplot(2, 4, 7); 
    S.h(7) = histogram(pos_error_std_enub(:, 3)); xlabel('\sigma_U');
    % Sigma Clock Offset
    subplot(2, 4, 8); 
    S.h(8) = histogram(pos_error_std_enub(:, 4)); xlabel('\sigma_C');
    
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
    
    titleTxt = {errorType; ...
                sprintf('Distributions of \\mu_{ENUC} and \\sigma_{ENUC} at %d N, %d E', pos(iPos, :)); ...
                sprintf('Size: %d', nSamples)};
    sgtitle(titleTxt);
    figName = sprintf('%s error distributions at %d N, %d E', errorType, pos(iPos, :));
    set(S.f, 'Name', figName);
    set(S.f, 'Position', get(0, 'Screensize'));
    
    %% 3D histograms
    % East
    f = figure(figNo(iPos+nPos));
    
    for iDim = 1:nDim
        subplot(2,2,iDim);
        statsDim = [pos_error_mean_enub(:,iDim), pos_error_std_enub(:,iDim)];
        hist3(statsDim, 'CDataMode','auto'); 
        xlabel(['\mu_{' dimensions{iDim} '}']);
        ylabel(['\sigma_{' dimensions{iDim} '}']);
        colorbar
        view(2)
    end

    titleTxt = {errorType; ...
                sprintf('3D Distributions of coupled \\mu_{ENUC} and \\sigma_{ENUC} at %d N, %d E', pos(iPos, :)); ...
                sprintf('Size: %d', nSamples)};
    sgtitle(titleTxt);
    figName = sprintf('%s error 3D distributions at %d N, %d E', errorType, pos(iPos, :));
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