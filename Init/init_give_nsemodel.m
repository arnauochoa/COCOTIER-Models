function [] = init_give_nsemodel()
%INIT_GIVE_NSEMODEL Initializes some parameters for the NSE model

    global GIVE_NSE_RESULTSFILE GIVE_NSE_STATIONSFILE GIVE_NSE_HISTOGRAMFILE
    
    GIVE_NSE_RESULTSFILE = 'Allstations_IONO_results_full2014.mat';
    GIVE_NSE_STATIONSFILE = 'ECAC_stations_position.mat';
    
    GIVE_NSE_HISTOGRAMFILE = 'histogram_positions.txt';
end

