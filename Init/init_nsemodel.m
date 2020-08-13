function [] = init_nsemodel()
%INIT_GIVE_NSEMODEL Initializes some parameters for the NSE model

    global IONO_NSE_RESULTSFILE IONO_NSE_STATIONSFILE 
    global CLKEPH_NSE_RESULTSFILE
    global IONO_NSE_HISTOGRAMFILE CLKEPH_NSE_HISTOGRAMFILE TOTAL_NSE_HISTOGRAMFILE
    global ECAC_CENTRAL_AREA_FILE
    
    IONO_NSE_RESULTSFILE = 'Allstations_IONO_results_full2014.mat';
    IONO_NSE_STATIONSFILE = 'ECAC_stations_position.mat';
    % TODO: set as global and define in another place
    CLKEPH_NSE_RESULTSFILE = 'CLKEPH_results_y2014_NGA.mat';
    
    IONO_NSE_HISTOGRAMFILE = 'iono_histogram_positions.txt';
    CLKEPH_NSE_HISTOGRAMFILE = 'iono_histogram_positions.txt';
    TOTAL_NSE_HISTOGRAMFILE = 'iono_histogram_positions.txt';
    
    ECAC_CENTRAL_AREA_FILE = 'ECAC_central_area.txt';
end

