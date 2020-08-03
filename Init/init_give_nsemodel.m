function [] = init_give_nsemodel()
%INIT_GIVE_NSEMODEL Initializes some parameters for the NSE model

    global IONO_NSE_RESULTSFILE IONO_NSE_STATIONSFILE IONO_NSE_HISTOGRAMFILE
    
    IONO_NSE_RESULTSFILE = 'Allstations_IONO_results_full2014.mat';
    IONO_NSE_STATIONSFILE = 'ECAC_stations_position.mat';
    
    IONO_NSE_HISTOGRAMFILE = 'iono_histogram_positions.txt';
end

