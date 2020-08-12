function [usr2satdata, usrdata, IonoError, ClockEphError] =                   ...
                            usrprocess(satdata, usrdata, usr2satdata, usrtrpfun,    ...
                                        usrcnmpfun, time, pa_mode)
                                    
% function [vhpl, usr2satdata, usrdata, IonoError, ClockEphError] =  
%                             usrprocess(satdata, usrdata, igpdata,               ...
%                                         inv_igp_mask, usr2satdata, usrtrpfun,   ...
%                                         usrcnmpfun, time, pa_mode, give_mode,   ...
%                                         rss_udre, rss_iono)
%*************************************************************************
%*     Copyright c 2020 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% User Processing

%Modified Todd Walter June 28, 2007 to include PA vs. NPA mode
%Modified by Todd Walter Sept. 4, 2013 to include MT27 & other constellations
%Modified by Todd Walter Mar. 26, 2020 to change MT27 format and outputs now included in usr2satdata
%Modified by Todd Walter Apr. 10, 2020 to include MOPS degradation terms

global MOPS_SIN_USRMASK 
global COL_SAT_XYZ COL_USR_XYZ COL_USR_LL COL_SAT_UDREI ...
        COL_USR_EHAT COL_USR_NHAT COL_USR_UHAT  ...
        COL_U2S_PRN COL_U2S_GXYZB COL_U2S_SIGFLT COL_U2S_BIASIONO COL_U2S_SIGIONO COL_U2S_SIG2IONO ...
        COL_U2S_OB2PP COL_U2S_SIG2TRP COL_U2S_SIG2L1MP  ...
        COL_U2S_LOSENU COL_U2S_GENUB COL_U2S_EL COL_U2S_AZ ...
        COL_U2S_IPPLL COL_U2S_TTRACK0 COL_U2S_INITNAN COL_U2S_BIASCLKEPH ...
        COL_U2S_SIGCLKEPH COL_U2S_BIASTOTAL COL_U2S_SIGTOTAL
global MOPS_SIG_UDRE MOPS_UDREI_NM MOPS_UDREI_DNU 
global MOPS_MIN_GEOPRN MOPS_MAX_GEOPRN
global GIVE_MODE_NSEMODEL

nsat = size(satdata,1);
nusr = size(usrdata,1);
nlos = nsat*nusr;

% initialize some values to NaN
usr2satdata(:,COL_U2S_INITNAN) = NaN;

% form los data from usr to satellites
usr2satdata(:,COL_U2S_GXYZB) = find_los_xyzb(usrdata(:,COL_USR_XYZ), ...
                                            satdata(:,COL_SAT_XYZ));
usr2satdata(:,COL_U2S_GENUB) = find_los_enub(usr2satdata(:,COL_U2S_GXYZB),...
   usrdata(:,COL_USR_EHAT),usrdata(:,COL_USR_NHAT),usrdata(:,COL_USR_UHAT));
% find inexes of satellites above mask
abv_mask = find(-usr2satdata(:,COL_U2S_GENUB(3)) >= MOPS_SIN_USRMASK);

if(~isempty(abv_mask))
  % find elevation and azimuth of satellites above mask
  [usr2satdata(abv_mask,COL_U2S_EL),usr2satdata(abv_mask,COL_U2S_AZ)] = ...
        find_elaz(usr2satdata(abv_mask,COL_U2S_LOSENU));
  % find IPP from user positions, elevation and azimuth for satellites above mask
  usr2satdata(abv_mask,COL_U2S_IPPLL) = find_ll_ipp(usrdata(:,COL_USR_LL),...
                                usr2satdata(:,COL_U2S_EL),...
                                usr2satdata(:,COL_U2S_AZ), abv_mask);
end

idxold = find(~isnan(usr2satdata(:,COL_U2S_TTRACK0)));
idxnew = setdiff(abv_mask,idxold);

% set start time of track for lost los's to NaN
usr2satdata(setdiff(idxold,abv_mask),COL_U2S_TTRACK0) = NaN; % lost los
usr2satdata(idxnew,COL_U2S_TTRACK0) = time; % new los

% tropo    
sig2_trop = feval(usrtrpfun,usr2satdata(:,COL_U2S_EL));
usr2satdata(:, COL_U2S_SIG2TRP) = sig2_trop;

% cnmp
if ~isempty(usrcnmpfun)
    sig2_cnmp = feval(usrcnmpfun,time-usr2satdata(:,COL_U2S_TTRACK0),...
                                usr2satdata(:,COL_U2S_EL));
    usr2satdata(:, COL_U2S_SIG2L1MP) = sig2_cnmp;                            
end

% initialize outputs
sig_flt = NaN(nlos,1);      % Fast/Long-term variance
obl2 = NaN(nlos,1);         % Square of iono obliquity factor
vhpl = NaN(nusr,2);         % Vertical and Horizontal Protection Level
IonoError = [];             % Structure to save Uire statistics in NSE model

[t1, t2]=meshgrid(1:nusr,1:nsat);
usridx=reshape(t1,nlos,1);
satidx=reshape(t2,nlos,1);
los_enub = usr2satdata(:,COL_U2S_GENUB);
el = usr2satdata(:,COL_U2S_EL);

% check for valid UDRE
if (pa_mode)
    mops_sig_udre = MOPS_SIG_UDRE;
    mops_sig_udre(13:end) = NaN;
    sig_udre = mops_sig_udre(satdata(:,COL_SAT_UDREI))';
else
    mops_sig_udre = MOPS_SIG_UDRE;
    mops_sig_udre([MOPS_UDREI_NM MOPS_UDREI_DNU]) = NaN;
    sig_udre = mops_sig_udre(satdata(:,COL_SAT_UDREI))';
end

% look for above the elevation mask with a valid udre or if it is a GEO
good_udre = find((sig_udre(satidx(abv_mask)) > 0) | ...
     ((usr2satdata(satidx(abv_mask),COL_U2S_PRN) >= MOPS_MIN_GEOPRN) & ...
      (usr2satdata(satidx(abv_mask),COL_U2S_PRN) <= MOPS_MAX_GEOPRN)));
  
if(~isempty(good_udre))
    good_sat=abv_mask(good_udre);
            
            % IONO ERROR
            good_los = good_sat;
            obl2(good_sat) = obliquity2(el(good_sat));
            
            % IONO residual error statistics
            [IonoError, usrdata, usr2satdata] = compute_iono_error_nse(usrdata, usr2satdata, good_los);
            
            % CLOCK+EPH residual error statistics
            [ClockEphError, usr2satdata] = compute_clkeph_error_nse(usrdata, usr2satdata, good_los);
            
            good_los = intersect(good_los, find(~isnan(usr2satdata(:, COL_U2S_SIGIONO))));
            % variance for each los
            if(~isempty(good_los))
   
                sig2 =  nansum([    usr2satdata(good_los, COL_U2S_SIG2IONO)     ...
                                    usr2satdata(good_los, COL_U2S_SIGCLKEPH).^2 ...
                                    sig2_trop(good_los)                         ...
                                    sig2_cnmp(good_los)                         ], 2);
                usr2satdata(good_los, COL_U2S_SIGTOTAL) = sqrt(sig2);
                                
                mean =  nansum([    usr2satdata(good_los, COL_U2S_BIASIONO)     ...
                                    usr2satdata(good_los, COL_U2S_BIASCLKEPH).^2 ], 2);
                usr2satdata(good_los, COL_U2S_BIASTOTAL) = mean;           
            end
    
    if(~isempty(good_los))
        usr2satdata(good_los, COL_U2S_SIGFLT) = sig_flt(good_los);
        usr2satdata(good_los, COL_U2S_OB2PP) = obl2(good_los);

%         % calculate VPL and HPL
%         [vhpl(1:max(usridx(good_los)),:), ~, ~] = usr_vhpl(los_enub(good_los,:), ...
%                                                  usridx(good_los), sig2, ...
%                                                  usr2satdata(good_los,COL_U2S_PRN),...
%                                                  pa_mode);
% 
%         bad_usr=find(vhpl(:,1) <= 0 | vhpl(:,2) <= 0);
%         if(~isempty(bad_usr))
%           vhpl(bad_usr,:)=NaN;
%         end
        
        % Compute G and W matrices (G is in ENU)
        [G_usr, W_usr] = findGW(usr2satdata(good_los, :), usridx(good_los), sig2);
        % Compute mean and std of each user pos error due to iono
        usrdata = compute_user_stats(G_usr, W_usr, usrdata, usr2satdata);
    end
end

end

    




