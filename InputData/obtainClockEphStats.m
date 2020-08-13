% function obtainClockEphStats()

REF_EPH = 'NGA';
year = 2012; YEAR_str = num2str(year);
DayMax = 365;

elBins = 0:5:90;
nElBins = length(elBins)-1;

edges_err = -10  : 0.05 :10;
edges_sig =   0  : 0.1 :10;
edges_rat =  -5.5: 0.1 : 5.5;

lonmin=-40;lonmax=40;latmin=20;latmax=70; % EGNOS in SRD
hlatlon = 5;
lon = lonmin:hlatlon:lonmax;
lat = latmin:hlatlon:latmax;
GridSize = length(lat)*length(lon);

pathHeader = ['../RESULT_' YEAR_str '_' REF_EPH '_CODE/'];

maastPath = '../MAAST/';

stat.mat_usr = zeros(GridSize, 3, 5);
stat.mat_usr_el = zeros(GridSize, 3, nElBins, 5);

hist_err_usr = zeros(GridSize, length(edges_err)-1);

hist_err_usr_el = zeros(GridSize, length(edges_err)-1, nElBins);

for y=1:length(year)
    for d=1:DayMax
        % Determine the path
        day = num2str(d + 1000); %+1000 for 3-digits
        path=[pathHeader 'd' day(2:4) '/'];

        % Check existence
        if ~exist([path 'compdata.mat'],'file')
            continue
        end

        [Hist_usr, Hist_usr_el, stat, latlon] = ...
            COMP_ORBCLK_SBAS_IGS_vUSRhist_2(hlatlon,1,path,path,edges_err,edges_sig,edges_rat,stat, elBins);

%         hist_err_usr = hist_err_usr + Hist_usr.err;
        hist_err_usr_el = hist_err_usr_el + permute(Hist_usr_el.err, [1 3 2]);
    end
end

if ~exist('Hist_usr_el', 'var')
    error('There is no data for the selected configuration');
end

% Get CLOCK+EPH range from edges_err
clkephRange = (edges_err(1:end-1) + edges_err(2:end)) / 2;

clkephMeanEl = zeros(size(latlon,1), nElBins);
clkephStdEl =  zeros(size(latlon,1), nElBins);
for iPos=1:size(latlon,1)
    for iEl = 1:nElBins
        % Get CLOCK+EPH values from CLOCK+EPH range and hist counts for current position
        clkephVals = repelem(clkephRange, hist_err_usr_el(iPos, :, iEl));
        
        % Compute mean and std
        clkephMeanEl(iPos, iEl) = mean(clkephVals);
        clkephStdEl(iPos, iEl) = std(clkephVals);
    end
end

% Save data to use in MAAST
if ~exist(maastPath, 'dir'), mkdir(maastPath); end
save([maastPath 'CLKEPH_results_y' YEAR_str '_' REF_EPH '.mat'], 'latlon', 'elBins', 'clkephMeanEl', 'clkephStdEl');

meanMap = nan(length(lat), length(lon), nElBins);
stdMap = nan(length(lat), length(lon), nElBins);
for iEl = 1:nElBins
    for i = 1:size(latlon, 1)
        latInd = find(lat==latlon(i, 1));
        lonInd = find(lon==latlon(i, 2));
        meanMap(latInd, lonInd, iEl) = clkephMeanEl(i, iEl);
        stdMap(latInd, lonInd, iEl) = clkephStdEl(i, iEl);
    end
    figure
    imagesc(lat, lon, meanMap(:, :, iEl));
    title(sprintf('Bias for %dº < el < %dº', elBins(iEl), elBins(iEl+1)));
    colorbar

    figure
    imagesc(lat, lon, stdMap(:, :, iEl));
    title(sprintf('STD for %dº < el < %dº', elBins(iEl), elBins(iEl+1)));
    colorbar
end

% end
