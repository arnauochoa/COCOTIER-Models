function outputprocess(satdata,usrdata,wrsdata,igpdata,inv_igp_mask,...
                       sat_xyz,udrei,givei,usrvpl,usrhpl,latgrid,...
					   longrid,outputs,percent,vhal,pa_mode,udre_hist,give_hist,...
					   udrei_hist,givei_hist, IonoError, iono_mean_enub, iono_sig_enub,...
                       ClockEphError, clkeph_mean_enub, clkeph_sig_enub, ...
                       total_mean_enub, total_sig_enub)
%*************************************************************************
%*     Copyright c 2007 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%

%Modified Todd Walter June 28, 2007 to include VAL, HAL and PA vs. NPA mode
global COL_USR_LL COL_USR_INBND COL_IGP_LL COL_IGP_GIVEI COL_SAT_UDREI ...
        COL_IGP_BIAS COL_IGP_STD
global GUI_OUT_AVAIL GUI_OUT_UDREMAP GUI_OUT_GIVEMAP ...
        GUI_OUT_UDREHIST GUI_OUT_GIVEHIST GUI_OUT_VHPL GUI_OUT_COVAVAIL ...
        GUI_OUT_UIPESTATS
global GRAPH_AVAIL_FIGNO GRAPH_VPL_FIGNO GRAPH_HPL_FIGNO
global GRAPH_UDREMAP_FIGNO GRAPH_GIVEMAP_FIGNO
global GRAPH_GIVEBIASMAP_FIGNO GRAPH_GIVESTDMAP_FIGNO
global GRAPH_IONOBIASMAP_FIGNO GRAPH_IONOSTDMAP_FIGNO
global GRAPH_UDREHIST_FIGNO GRAPH_GIVEHIST_FIGNO GRAPH_COV_AVAIL_FIGNO
global GRAPH_IONOMEANENUMAP_FIGNO GRAPH_IONOSTDENUMAP_FIGNO
global GRAPH_CLKEPHBIASMAP_FIGNO GRAPH_CLKEPHSTDMAP_FIGNO
global GRAPH_CLKEPHMEANENUMAP_FIGNO GRAPH_CLKEPHSTDENUMAP_FIGNO
global GRAPH_TOTALMEANENUMAP_FIGNO GRAPH_TOTALSTDENUMAP_FIGNO
global OUTPUT_BIAS_LABEL OUTPUT_STD_LABEL
global OUTPUT_IONO_LABEL OUTPUT_CLKEPH_LABEL OUTPUT_TOTAL_LABEL
% global COL_USR_BIASUIRE_ENU COL_USR_SIG2UIRE_ENU

init_graph;

usrlat = usrdata(:,COL_USR_LL(1));
usrlon = usrdata(:,COL_USR_LL(2));
idx = find(usrlon>=180);
usrlon(idx) = usrlon(idx)-360;

inbnd = usrdata(:,COL_USR_INBND);
inbndidx=find(inbnd);
igp_mask = igpdata(:,COL_IGP_LL);

nt = size(usrvpl,2);

if outputs(GUI_OUT_GIVEMAP)
    % sort gives for each user and determine gives at given percentage
    if isempty(IonoError)
        if sum(sum(~isnan(givei)))
            nigp = size(givei,1);
            sortgive = zeros(size(givei));
            percentidx = ceil(percent*nt);
            for i = 1:nigp
                sortgive(i,:) = sort(givei(i,:));
            end
            give_i = sortgive(:,percentidx);
            h=figure(GRAPH_GIVEMAP_FIGNO);
            give_contour(igp_mask, inv_igp_mask, give_i, percent);
            set(h,'name','GIVE MAP');
    %        text(longrid(1)+1,latgrid(1)+1,'o -  USER');
        else
            fprintf('No GIVEs were calculated\n');
        end
    else
        % Iono range error maps
        if sum(~isnan(IonoError.mean), 'all') && sum(~isnan(IonoError.std), 'all')
            for iEl = 1:length(IonoError.elBins)-1
                % Iono range error bias
                h=figure(GRAPH_IONOBIASMAP_FIGNO(iEl));
                titleText = sprintf('IONO RANGE ERROR BIAS MAP: %d < el < %d', IonoError.elBins(iEl), IonoError.elBins(iEl+1));
                error_stat_contour(IonoError.mean(:, iEl), usrdata, OUTPUT_BIAS_LABEL, titleText);
                figName = sprintf('IONO RANGE ERROR BIAS MAP: %d < el < %d', IonoError.elBins(iEl), IonoError.elBins(iEl+1));
                set(h, 'name', figName);

                % Iono range error STD
                h=figure(GRAPH_IONOSTDMAP_FIGNO(iEl));
                titleText = sprintf('IONO RANGE ERROR STD MAP: %d < el < %d', IonoError.elBins(iEl), IonoError.elBins(iEl+1));
                error_stat_contour(IonoError.std(:, iEl), usrdata, OUTPUT_STD_LABEL, titleText);
                figName = sprintf('IONO RANGE ERROR STD MAP: %d < el < %d', IonoError.elBins(iEl), IonoError.elBins(iEl+1));
                set(h, 'name', figName);
            end
        end
%         % Bias and STD plots
%         if sum(~isnan(igpdata(:, COL_IGP_BIAS))) && all(igpdata(:, COL_IGP_BIAS)) % check NaN and 0
%             h=figure(GRAPH_GIVEBIASMAP_FIGNO);
%             give_stat_contour(igp_mask, inv_igp_mask, igpdata(:, COL_IGP_BIAS), OUTPUT_BIAS_LABEL);
%             set(h,'name','GIVE BIAS MAP');
%         end
%         if sum(~isnan(igpdata(:, COL_IGP_STD))) && all(igpdata(:, COL_IGP_STD)) % check NaN and 0
%             h=figure(GRAPH_GIVESTDMAP_FIGNO);
%             give_stat_contour(igp_mask, inv_igp_mask, igpdata(:, COL_IGP_STD), OUTPUT_STD_LABEL);
%             set(h,'name','GIVE STD MAP');
%         end
    end
end

if outputs(GUI_OUT_UIPESTATS)
    % Iono ENU error maps
    if sum(~isnan(iono_mean_enub), 'all') && sum(~isnan(iono_sig_enub), 'all')
        dimensions = {'EAST', 'NORTH', 'UP', 'CLOCK'};
        [prctile_iono_mean_enub, prctile_iono_std_enub] = findStatPrctiles(iono_mean_enub, iono_sig_enub, percent);
        for iDim = 1:length(dimensions)
            % Mean
            h = figure(GRAPH_IONOMEANENUMAP_FIGNO(iDim));
            titleText = ['Mean iono position error along ' dimensions{iDim} ' axis at ' num2str(100*percent) '%'];
            error_stat_contour(prctile_iono_mean_enub(:, iDim), usrdata, OUTPUT_BIAS_LABEL, titleText);
            figName = [dimensions{iDim} ' ERROR MEAN ' num2str(percent)];
            set(h, 'name', figName);
            % Variance
            h = figure(GRAPH_IONOSTDENUMAP_FIGNO(iDim));
            titleText = ['STD of iono position error along ' dimensions{iDim} ' axis at ' num2str(100*percent) '%'];
            error_stat_contour(prctile_iono_std_enub(:, iDim), usrdata, OUTPUT_STD_LABEL, titleText);
            figName = [dimensions{iDim} ' ERROR STD ' num2str(percent)];
            set(h, 'name', figName);
        end
        
        % Histograms
        plotStatHistograms(usrdata(:, COL_USR_LL), iono_mean_enub, iono_sig_enub, OUTPUT_IONO_LABEL)
    end
end

if outputs(GUI_OUT_UDREMAP)

    % CLOCK+EPH range error maps
    if sum(~isnan(ClockEphError.mean), 'all') && sum(~isnan(ClockEphError.std), 'all')
        for iEl = 1:length(ClockEphError.elBins)-1
            % Iono range error bias
            h=figure(GRAPH_CLKEPHBIASMAP_FIGNO(iEl));
            titleText = sprintf('CLOCK+EPH RANGE ERROR BIAS MAP: %d < el < %d', ClockEphError.elBins(iEl), ClockEphError.elBins(iEl+1));
            error_stat_contour(ClockEphError.mean(:, iEl), usrdata, OUTPUT_BIAS_LABEL, titleText);
            figName = sprintf('CLOCK+EPH RANGE ERROR BIAS MAP: %d < el < %d', ClockEphError.elBins(iEl), ClockEphError.elBins(iEl+1));
            set(h, 'name', figName);

            % Iono range error STD
            h=figure(GRAPH_CLKEPHSTDMAP_FIGNO(iEl));
            titleText = sprintf('CLOCK+EPH RANGE ERROR STD MAP: %d < el < %d', ClockEphError.elBins(iEl), ClockEphError.elBins(iEl+1));
            error_stat_contour(ClockEphError.std(:, iEl), usrdata, OUTPUT_STD_LABEL, titleText);
            figName = sprintf('CLOCK+EPH RANGE ERROR STD MAP: %d < el < %d', ClockEphError.elBins(iEl), ClockEphError.elBins(iEl+1));
            set(h, 'name', figName);
        end
    end
end

if outputs(GUI_OUT_UDREHIST)

    if sum(~isnan(clkeph_mean_enub), 'all') && sum(~isnan(clkeph_sig_enub), 'all')
        dimensions = {'EAST', 'NORTH', 'UP', 'CLOCK'};
        [prctile_clkeph_mean_enub, prctile_clkeph_std_enub] = findStatPrctiles(clkeph_mean_enub, clkeph_sig_enub, percent);
        for iDim = 1:length(dimensions)
            % Mean
            h = figure(GRAPH_CLKEPHMEANENUMAP_FIGNO(iDim));
            titleText = ['Mean clock+eph position error along ' dimensions{iDim} ' axis at ' num2str(100*percent) '%'];
            error_stat_contour(prctile_clkeph_mean_enub(:, iDim), usrdata, OUTPUT_BIAS_LABEL, titleText);
            figName = [dimensions{iDim} ' ERROR MEAN ' num2str(percent)];
            set(h, 'name', figName);
            % Variance
            h = figure(GRAPH_CLKEPHSTDENUMAP_FIGNO(iDim));
            titleText = ['STD of clock+eph position error along ' dimensions{iDim} ' axis at ' num2str(percent) '%'];
            error_stat_contour(prctile_clkeph_std_enub(:, iDim), usrdata, OUTPUT_STD_LABEL, titleText);
            figName = [dimensions{iDim} ' ERROR STD ' num2str(percent)];
            set(h, 'name', figName);
        end
        
        % Histograms
        plotStatHistograms(usrdata(:, COL_USR_LL), clkeph_mean_enub, clkeph_sig_enub, OUTPUT_CLKEPH_LABEL)
    end
end

if true
    if sum(~isnan(total_mean_enub), 'all') && sum(~isnan(total_sig_enub), 'all')
        dimensions = {'EAST', 'NORTH', 'UP', 'CLOCK'};
        [prctile_total_mean_enub, prctile_total_std_enub] = findStatPrctiles(total_mean_enub, total_sig_enub, percent);
        for iDim = 1:length(dimensions)
            % Mean
            h = figure(GRAPH_TOTALMEANENUMAP_FIGNO(iDim));
            titleText = ['Mean total position error along ' dimensions{iDim} ' axis at ' num2str(100*percent) '%'];
            error_stat_contour(prctile_total_mean_enub(:, iDim), usrdata, OUTPUT_BIAS_LABEL, titleText);
            figName = [dimensions{iDim} ' ERROR MEAN ' num2str(percent)];
            set(h, 'name', figName);
            % Variance
            h = figure(GRAPH_TOTALSTDENUMAP_FIGNO(iDim));
            titleText = ['STD of total position error along ' dimensions{iDim} ' axis at ' num2str(percent) '%'];
            error_stat_contour(prctile_total_std_enub(:, iDim), usrdata, OUTPUT_STD_LABEL, titleText);
            figName = [dimensions{iDim} ' ERROR STD ' num2str(percent)];
            set(h, 'name', figName);
        end
        
        % Histograms
        plotStatHistograms(usrdata(:, COL_USR_LL), total_mean_enub, total_sig_enub, OUTPUT_TOTAL_LABEL)
    end
end
    

end



