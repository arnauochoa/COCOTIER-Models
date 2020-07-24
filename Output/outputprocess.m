function outputprocess(satdata,usrdata,wrsdata,igpdata,inv_igp_mask,...
                       sat_xyz,udrei,givei,usrvpl,usrhpl,latgrid,...
					   longrid,outputs,percent,vhal,pa_mode,udre_hist,give_hist,...
					   udrei_hist,givei_hist, Uire, avg_iono_mean_enu, avg_iono_sig2_enu)
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
        GUI_OUT_UDREHIST GUI_OUT_GIVEHIST GUI_OUT_VHPL GUI_OUT_COVAVAIL

global GRAPH_AVAIL_FIGNO GRAPH_VPL_FIGNO GRAPH_HPL_FIGNO
global GRAPH_UDREMAP_FIGNO GRAPH_GIVEMAP_FIGNO
global GRAPH_GIVEBIASMAP_FIGNO GRAPH_GIVESTDMAP_FIGNO
global GRAPH_UIREBIASMAP_FIGNO GRAPH_UIRESTDMAP_FIGNO
global GRAPH_UDREHIST_FIGNO GRAPH_GIVEHIST_FIGNO GRAPH_COV_AVAIL_FIGNO
global GRAPH_IONOMEANENUMAP_FIGNO GRAPH_IONOSIG2ENUMAP_FIGNO
global OUTPUT_BIAS_LABEL OUTPUT_STD_LABEL OUTPUT_VAR_LABEL
global COL_USR_BIASUIRE_ENU COL_USR_SIG2UIRE_ENU

init_graph;

usrlat = usrdata(:,COL_USR_LL(1));
usrlon = usrdata(:,COL_USR_LL(2));
idx = find(usrlon>=180);
usrlon(idx) = usrlon(idx)-360;

inbnd = usrdata(:,COL_USR_INBND);
inbndidx=find(inbnd);
igp_mask = igpdata(:,COL_IGP_LL);

nt = size(usrvpl,2);

% rearrange usrvpl, usrhpl to be lat-wise first then lon-wise
%nlat = length(latgrid);
%nlon = length(longrid);
%for i=1:nt,
%    usrvpl(:,i)=reshape(reshape(usrvpl(:,i),nlon,nlat)',nlat*nlon,1);
%    usrhpl(:,i)=reshape(reshape(usrhpl(:,i),nlon,nlat)',nlat*nlon,1);
%end

if outputs(GUI_OUT_AVAIL)
    h=figure(GRAPH_AVAIL_FIGNO);
    avail_contour(latgrid,longrid,usrvpl,usrhpl,inbnd,percent,vhal,pa_mode);
    set(h,'name','AVAILABLITY CONTOUR');
%    plot(wrsdata(:,COL_USR_LL(2)),wrsdata(:,COL_USR_LL(1)),'m*');
%    plot(usrdata(inbndidx,COL_USR_LL(2)),usrdata(inbndidx,COL_USR_LL(1)),'ko');
%    text(longrid(1)+1,latgrid(1)+2,'* - WRS');
%    text(longrid(1)+1,latgrid(1)+1,'o -  USER');
end

if outputs(GUI_OUT_VHPL)
    % sort v/hpl for each user and determine vpl at given percentage
    nusr = size(usrdata,1);
    sortvpl = zeros(size(usrvpl));
    sorthpl = zeros(size(usrhpl));
    percentidx = ceil(percent*nt);
    for i = 1:nusr
        sortvpl(i,:) = sort(usrvpl(i,:));
        sorthpl(i,:) = sort(usrhpl(i,:));
    end
    vpl = sortvpl(:,percentidx);
    hpl = sorthpl(:,percentidx);
    %VAL specific plot
    if(pa_mode)
        h=figure(GRAPH_VPL_FIGNO);
        vpl_contour(latgrid,longrid,vpl,percent);
        set(h,'name','VPL CONTOUR');
%        plot(wrsdata(:,COL_USR_LL(2)),wrsdata(:,COL_USR_LL(1)),'m*');
%        plot(usrdata(inbndidx,COL_USR_LL(2)),usrdata(inbndidx,COL_USR_LL(1)),'ko');
%        text(longrid(1)+1,latgrid(1)+2,'* - WRS');
%        text(longrid(1)+1,latgrid(1)+1,'o -  USER');
    end
    h=figure(GRAPH_HPL_FIGNO);
    hpl_contour(latgrid,longrid,hpl,percent);
    set(h,'name','HPL CONTOUR');
%    plot(wrsdata(:,COL_USR_LL(2)),wrsdata(:,COL_USR_LL(1)),'m*');
%    plot(usrdata(inbndidx,COL_USR_LL(2)),usrdata(inbndidx,COL_USR_LL(1)),'ko');
%    text(longrid(1)+1,latgrid(1)+2,'* - WRS');
%    text(longrid(1)+1,latgrid(1)+1,'o -  USER');
end

if outputs(GUI_OUT_GIVEMAP)
    % sort gives for each user and determine gives at given percentage
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
    
    % UIRE MAPS
    if sum(~isnan(Uire.mean), 'all') && sum(~isnan(Uire.std), 'all')
        for iEl = 1:length(Uire.elBins)-1
            % UIRE bias
            h=figure(GRAPH_UIREBIASMAP_FIGNO(iEl));
            titleText = sprintf('UIRE BIAS MAP: %d < el < %d', Uire.elBins(iEl), Uire.elBins(iEl+1));
            uire_stat_contour(Uire.mean(:, iEl), usrdata, OUTPUT_BIAS_LABEL, titleText);
            figName = sprintf('UIRE BIAS MAP: %d < el < %d', Uire.elBins(iEl), Uire.elBins(iEl+1));
            set(h, 'name', figName);
            
            % UIRE STD
            h=figure(GRAPH_UIRESTDMAP_FIGNO(iEl));
            titleText = sprintf('UIRE STD MAP: %d < el < %d', Uire.elBins(iEl), Uire.elBins(iEl+1));
            uire_stat_contour(Uire.std(:, iEl), usrdata, OUTPUT_STD_LABEL, titleText);
            figName = sprintf('UIRE STD MAP: %d < el < %d', Uire.elBins(iEl), Uire.elBins(iEl+1));
            set(h, 'name', figName);
        end
    end
    % Iono ENU error maps
    if sum(~isnan(avg_iono_mean_enu), 'all') && sum(~isnan(avg_iono_sig2_enu), 'all')
        axis = {'EAST', 'NORTH', 'UP'};
        for iAxis = 1:length(axis)
            % Mean
            h = figure(GRAPH_IONOMEANENUMAP_FIGNO(iAxis));
            titleText = ['Averaged Mean iono position error along ' axis{iAxis} ' axis'];
            uire_stat_contour(usrdata(:, COL_USR_BIASUIRE_ENU(iAxis)), usrdata, OUTPUT_BIAS_LABEL, titleText);
            figName = [axis{iAxis} ' ERROR MEAN'];
            set(h, 'name', figName);
            % Variance
            h = figure(GRAPH_IONOSIG2ENUMAP_FIGNO(iAxis));
            titleText = ['Averaged Variance of iono position error along ' axis{iAxis} ' axis'];
            uire_stat_contour(usrdata(:, COL_USR_SIG2UIRE_ENU(iAxis)), usrdata, OUTPUT_VAR_LABEL, titleText);
            figName = [axis{iAxis} ' ERROR VARIANCE'];
            set(h, 'name', figName);
        end
    end
    
    
%     % Bias and STD plots
%     if sum(~isnan(igpdata(:, COL_IGP_BIAS))) && all(igpdata(:, COL_IGP_BIAS)) % check NaN and 0
%         h=figure(GRAPH_GIVEBIASMAP_FIGNO);
%         give_stat_contour(igp_mask, inv_igp_mask, igpdata(:, COL_IGP_BIAS), OUTPUT_BIAS_LABEL);
%         set(h,'name','GIVE BIAS MAP');
%     end
%     if sum(~isnan(igpdata(:, COL_IGP_STD))) && all(igpdata(:, COL_IGP_STD)) % check NaN and 0
%         h=figure(GRAPH_GIVESTDMAP_FIGNO);
%         give_stat_contour(igp_mask, inv_igp_mask, igpdata(:, COL_IGP_STD), OUTPUT_STD_LABEL);
%         set(h,'name','GIVE STD MAP');
%     end
    
        
end

if outputs(GUI_OUT_UDREMAP),
    sat_llh = xyz2llh(sat_xyz);
    h=figure(GRAPH_UDREMAP_FIGNO);
    mapudre(udrei,sat_llh,wrsdata(:,COL_USR_LL));
    set(h,'name','UDRE MAP');
end

if outputs(GUI_OUT_UDREHIST)
	h=figure(GRAPH_UDREHIST_FIGNO);
    udre_histogram(udre_hist, udrei_hist);
    set(h,'name','UDRE HISTOGRAM');
end

if outputs(GUI_OUT_GIVEHIST)
    if sum(sum(~isnan(givei)))    
        h=figure(GRAPH_GIVEHIST_FIGNO);
        give_histogram(give_hist, givei_hist);
        set(h,'name','GIVE HISTOGRAM');
    else
        fprintf('No GIVEs were calculated\n');
    end        
end

if outputs(GUI_OUT_COVAVAIL)
    h = figure(GRAPH_COV_AVAIL_FIGNO);
    cov_avail(usrdata, usrvpl, usrhpl, vhal, pa_mode);
    set(h, 'name', 'COVERAGE VS AVAILABILITY');
end;


