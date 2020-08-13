% function [Hist_usr, Hist_usr_el, Hist_usr_sv, latlon, sv_latlon] = COMP_ORBCLK_SBAS_IGS_vUSRhist(hlatlon,sbas_flag,data_dir_load,data_dir_save,edges_err,edges_sig,edges_rat)
function [Hist_usr, Hist_usr_el, stat, latlon, elBins] = COMP_ORBCLK_SBAS_IGS_vUSRhist_2(hlatlon,sbas_flag,data_dir_load,data_dir_save,edges_err,edges_sig,edges_rat,stat, elBins)
%**************************** FUNCTION DESCRIPTION ***********************************
% This routine determines the SREW and the UDRE values by comparing SBAS data with
% IGS data. The routine uses the input from a routine called CALC_ENT_INT which
% computes the ENT-INT
%*********************************** INPUT *******************************************
% *** FILES
% Through load command:
%
% sbasfcdata          Fast correction file read by READ_SBAS_FC
% sbasfc (ixjxk)     SBAS Fast correction data: PRNs supported, PRC+RRC and UDRE
%  i                 Time index
%  j                 Parameter index
%                      1 PRN number of satellite
%                      2 PRC + RRC*(t-tof) term in (m)
%                      3 UDRE (1 sig) in (m) after degradation with tlat and ai
%  k                 Satellite sequential index
% time_fc (nx1)      vector with matlab serial times
%
% sbasscdata          Slow correction file read by READ_SBAS_SC
% vc                 Velocity code
% sbassc (ixjxk)     SBAS Fast correction data: PRNs supported, PRC+RRC and UDRE
%  i                 Time index
%  j                 Parameter index (depends on velocity code)
%    if vc=0
%                      1 PRN number of satellite
%                      2 delta x (m)
%                      3 delta y (m)
%                      4 delta z (m)
%                      5 delta a0 (sec)
%                      6 IOD
%    if vc=1
%                      1 PRN number of satellite
%                      2 delta x (m)
%                      3 delta y (m)
%                      4 delta z (m)
%                      5 delta a0 (sec)
%                      6 delta xr (m)
%                      7 delta yr (m)
%                      8 delta zr (m)
%                      9 delta a1 (sec)
%                      10 toa (sec of day!!!)
%                      11 IOD
%  k                 Satellite sequential index with holes for unsupported satellites
% time_sc (1xn)      Vector with matlab serial times
%
% igscdata            Interpolated IGS values at required times
% igsc (ixjxk)        IGS Correction Vectors to satellites
%  i                  Time index
%  j                  Parameter index
%                      1 PRN number of satellite
%                      2 x of pseudorange (m)
%                      3 y of pseudorange (m)
%                      4 z of pseudorange (m)
%  k                  Satellite sequential index
% timedata (nx1)      vector with matlab serial times
%
% entintdata          ENT-INT offset values computed by CALC_ENT_INT
% entint (ix1)        Vector with time offsets in seconds
%  i                  Time index
%
% satposdata          Satellite positions
%
% Trough the command line:
% navfile             RINEX 2 Navigation file
% *** PARAMETERS
% hlatlon             Latitude and longitude spacing for simulation to find WUL
% sbas_flag           Flag to indicate which system is computed for:
%                     1 = ESTB or EGNOS (ECAC)
%                     2 = WAAS (CONUS)
%                     3 = MSAS
% *** OPTIONAL PARAMETERS
% data_dir_load       Name of directory where data should be loaded (default: current directory)
% data_dir_save       Name of directory where data should be saved (default: current directory)  
%*********************************** OUTPUT ******************************************
% *** FILES
% *** PARAMETERS
% Compute statistics (minimal values require special treatment)
% compdata(ixjxk)    i number of time at times same as in sbasdata file
%                    j number of satellite in the map m
%                    k parameter for a certain time at a certain satellite
%                      1 Satellite PRN Number
%                      2 SBAS Correction (m)
%                      3 IGS Correction (m)
%                      4 SREW (m)
%                      5 Sigma_flt*k
%                      6 Overbound (m)
% stats (ixj)        Statistics for the analysed data, which can be all maps for all points
%                    or just one location for all epochs
%                    i type of statistic
%                      1 Minimum
%                      2 Maximum
%                      3 Mean
%                      4 Standard deviation
%                    j data type analysed
%                      1 SBAS Correction (m)
%                      2 IGS Correction (m)
%                      3 SREW (m)
%                      4 Sigma_flt*k
%                      5 Overbound (m)
% mi(ixj)            Matrix with the locations/epochs at which mi occurred
%                    The criterium for mi is that overbound < -igsacc
%                    i sequential number of mi point
%                    j parameter for a certain point
%                      1 Time 
%                      2 Time index number
%                      3 PRN Number
%                      4 Overbound (m) (will be negative)
%*********************************** HISTORY *****************************************
% Michel Tossaint     January 2001
%                     First Programmed
% Michel Tossaint     September 2002
%                     Added processing of velocity code 1
% Michel Tossaint     October 2003
%                     Increased speed and decreased storage space
%************************************* TEST ******************************************
% TBD
%************************************* TBD *******************************************
% Unit testing
%*************************************************************************************
if nargin==3, %if no directories defined for loading and saving
    data_dir_load='';
    data_dir_save='';
end

deg2rad=pi/180;
c = 299792458.0; % WGS-84 speed of light
% K-factor for evaluation of the UDRE
kfactor=5.33;
% Accuracy of IGS information (5 sigma)
igsacc=0.05;

nElBins = length(elBins)-1;

% Load the data prepared by: READ_SBAS_FC, READ_SBAS_SC, CALC_ORBCLK_CORR_IGS, CALC_ENT_INT
load([data_dir_load,'sbasfcdata']);
load([data_dir_load,'sbasscdata']);
load([data_dir_save,'igscdata']);
load([data_dir_save,'satposdata']);
load([data_dir_save,'entintdata']);
starttime=time_fc(1);stoptime=time_fc(end);
timeint=round((time_fc(2)-time_fc(1))*86400);
number_of_times=length(time_fc);
dum=datevec(time_entint(1));doy1=datenum(dum(1),1,1)-1;

% disp(' ');
% disp('COMP_ORBCLK_SBAS_IGS: Reading RINEX Navigation file(s) ');

% we consider that the information are from the right time, the check will
% slow the process

% % Read navigation file
% [navmes,ionpar] = CAT_RIN_NAV(navfile);
% % Check that requested epochs are present in the sp3 and nav file(s)
% % Possible Y2K bug, because of RINEX format
% time_start_nav=datenum(navmes(2,1)+2000,navmes(3,1),navmes(4,1),navmes(5,1),navmes(6,1),navmes(7,1));
% time_stop_nav=datenum(navmes(2,end)+2000,navmes(3,end),navmes(4,end),navmes(5,end),navmes(6,end),navmes(7,end));
% if time_start_nav>starttime | time_stop_nav<stoptime
%     error('Requested epochs not fully covered by nav file(s)');
% end

% Determine the borders of the SBAS system
if sbas_flag==1,
    % lonmin=-30;lonmax=50;latmin=25;latmax=75; % EGNOS (old)
    lonmin=-40;lonmax=40;latmin=20;latmax=70; % EGNOS in SRD
elseif sbas_flag==2, % WAAS
    lonmin=-160;lonmax=-60;latmin=15;latmax=65;
end    



% Nb of sample - Mean - STD - Min - Max => for each hist
col_nb = 1; col_mean = 2; col_std = 3; col_min = 4; col_max = 5;
lin_err = 1; lin_sig = 2; lin_rat = 3;

% Prepare the latitude, longitude matrix of SBAS
cnt=0;
lon=lonmin:hlatlon:lonmax;
lat=latmin:hlatlon:latmax;
for i=1:size(lon,2),
    for j=1:size(lat,2),
        cnt=cnt+1;
        latlon(cnt,1)=lat(j);
        latlon(cnt,2)=lon(i);
        usr_xyz(cnt,1:3) = llh2xyz([latlon(cnt,1)*deg2rad,latlon(cnt,2)*deg2rad,0]);
    end
end
gridsize=size(latlon,1);

disp(' ');
disp('COMP_ORBCLK_SBAS_IGS: Comparing IGS data to SBAS data ');

%*************************************************************************************
% Comparing the data

% Speed up the process
igs_cor_pr(1:gridsize)=0;
sbas_cor_pr(1:gridsize)=0;

cnt=0;
sv_lat  = -90:5:90;
sv_lon = -180:5:175;
for i=1:size(sv_lon,2),
    for j=1:size(sv_lat,2),
        cnt=cnt+1;
        sv_latlon(cnt,1)=sv_lat(j);
        sv_latlon(cnt,2)=sv_lon(i);
        sv_xyz(cnt,1:3) = llh2xyz([sv_latlon(cnt,1)*deg2rad,sv_latlon(cnt,2)*deg2rad,0]); %replace 0 with sv altitude
    end
end

% Histo_SVpos_USR=zeros(cnt,gridsize,length(edges)-1);
% Histo_SVpos_WUL=zeros(cnt,length(edges)-1);
Hist_err = zeros(gridsize,length(edges_err)-1);
Hist_sig = zeros(gridsize,length(edges_sig)-1);
Hist_rat = zeros(gridsize,length(edges_rat)-1);

Hist_err_el = zeros(gridsize,nElBins,length(edges_err)-1);
Hist_sig_el = zeros(gridsize,nElBins,length(edges_sig)-1);
Hist_rat_el = zeros(gridsize,nElBins,length(edges_rat)-1);

Hist_err_sv = zeros(gridsize,cnt,length(edges_err)-1);
Hist_sig_sv = zeros(gridsize,cnt,length(edges_sig)-1);
Hist_rat_sv = zeros(gridsize,cnt,length(edges_rat)-1);

% Loop over the requested times, it is assumed that all the files contain the same
% time tags
ind=0;
for time_idx=1:10:number_of_times,
    % Determine all active sats from fast correction file (exlude GEO satellites)
    dum1=max(find(sbasfc(time_idx,1,:)~=0 & sbasfc(time_idx,1,:)<100));
    for sat_idx=1:dum1,
        prn=sbasfc(time_idx,1,sat_idx);
        if prn==0
            disp(['PRN=0 on day ' data_dir_load(end-3:end-1)]);
            continue
        end
        prn_idx_sc=find(sbassc(time_idx,1,:)==prn);
        if ~isempty(prn_idx_sc),
            if vc(1)==0,
                sc_vec=sbassc(time_idx,2:4,prn_idx_sc);
                sc_tim=sbassc(time_idx,5,prn_idx_sc);
            else,
                % First find the tk-t0 from time of day (is a little bit ambiguous)
                t0serial=floor(time_entint(time_idx))+sbassc(time_idx,10,prn_idx_sc)/86400;
                deltatime=(time_entint(time_idx)-t0serial)*86400;
                if deltatime>43200, % Half a day difference is too big there must be a day rollover
                    deltatime=deltatime-86400;
                    disp('Day rollover detected');
                elseif deltatime<-43200, % Half a day difference is too big there must be a day rollover
                    deltatime=deltatime+86400;
                    disp('Day rollover detected');
                end
                sc_vec=sbassc(time_idx,2:4,prn_idx_sc)+deltatime*sbassc(time_idx,6:8,prn_idx_sc);
                sc_tim=sbassc(time_idx,5,prn_idx_sc)+deltatime*sbassc(time_idx,9,prn_idx_sc);
            end
        else
            sc_vec=[0,0,0];
            sc_tim=0;
        end
        prn_idx_igs=find(igsc(time_idx,1,:)==prn);        
        % Loop over all the locations in ECAC
        if ~isempty(prn_idx_igs),
            igs_vec=igsc(time_idx,2:4,prn_idx_igs);
            igs_tim=igsc(time_idx,5,prn_idx_igs);
            for loc_idx=1:gridsize,
                % Determine position vector and elevation                
                [az,el,st]=c_calcAzEl(satp_brd(time_idx,prn,:),usr_xyz(loc_idx,:)); % In radians...
                % Determine if satellite is visible then compute the difference IGS2SBAS
                if rad2deg(el)>5
                    i_el = find(elBins < rad2deg(el), 1, 'last');
                    % Determine normalized vector between satellite and user position
                    dum3=[satp_brd(time_idx,prn,1) satp_brd(time_idx,prn,2) satp_brd(time_idx,prn,3)]-usr_xyz(loc_idx,:);
                    range=(dum3)/norm(dum3);
                    % Determine IGS correction along LOS + ENT-INT offset value
                    igs_cor_pr(loc_idx)=-igs_vec*range' + igs_tim*c + entintfilt(time_idx);
                    % Combine fast and slow SBAS corrections along LOS 
                    sbas_cor_pr(loc_idx)=-sc_vec*range' + sc_tim*c + sbasfc(time_idx,2,sat_idx) ;
                    % Compute the difference between SBAS and IGS
                    
                    Err = sbas_cor_pr(loc_idx)-igs_cor_pr(loc_idx);
                    if ~isnan(Err)
                        iErr = find(Err>edges_err,1,'last');
                        if isempty(iErr) | iErr==1
                            iErr=2;
                        end
                        Hist_err(loc_idx,iErr-1) = Hist_err(loc_idx,iErr-1)+1;
                        Hist_err_el(loc_idx,i_el,iErr-1) = Hist_err_el(loc_idx,i_el,iErr-1)+1;

                        [nb, moy, st_dev] = update_stat(Err,stat.mat_usr(loc_idx,lin_err,col_nb),...
                            stat.mat_usr(loc_idx,lin_err,col_mean),stat.mat_usr(loc_idx,lin_err,col_std));
                        stat.mat_usr(loc_idx,lin_err,col_nb) = nb;
                        stat.mat_usr(loc_idx,lin_err,col_mean) = moy;
                        stat.mat_usr(loc_idx,lin_err,col_std) = st_dev;

                        [nb, moy, st_dev] = update_stat(Err,stat.mat_usr_el(loc_idx,lin_err,i_el,col_nb),...
                            stat.mat_usr_el(loc_idx,lin_err,i_el,col_mean),stat.mat_usr_el(loc_idx,lin_err,i_el,col_std));
                        stat.mat_usr_el(loc_idx,lin_err,i_el,col_nb) = nb;
                        stat.mat_usr_el(loc_idx,lin_err,i_el,col_mean) = moy;
                        stat.mat_usr_el(loc_idx,lin_err,i_el,col_std) = st_dev;

                        Sig = sbasfc(time_idx,3,sat_idx);
                        iSig = find(Sig>edges_sig,1,'last');
                        if isempty(iSig) | iSig==1
                            iSig=2;
                        end
                        Hist_sig(loc_idx,iSig-1) = Hist_sig(loc_idx,iSig-1)+1;
                        Hist_sig_el(loc_idx,i_el,iSig-1) = Hist_sig_el(loc_idx,i_el,iSig-1)+1;

                        [nb, moy, st_dev] = update_stat(Sig,stat.mat_usr(loc_idx,lin_sig,col_nb),...
                            stat.mat_usr(loc_idx,lin_sig,col_mean),stat.mat_usr(loc_idx,lin_sig,col_std));
                        stat.mat_usr(loc_idx,lin_sig,col_nb) = nb;
                        stat.mat_usr(loc_idx,lin_sig,col_mean) = moy;
                        stat.mat_usr(loc_idx,lin_sig,col_std) = st_dev;

                        [nb, moy, st_dev] = update_stat(Sig,stat.mat_usr_el(loc_idx,lin_sig,i_el,col_nb),...
                            stat.mat_usr_el(loc_idx,lin_sig,i_el,col_mean),stat.mat_usr_el(loc_idx,lin_sig,i_el,col_std));
                        stat.mat_usr_el(loc_idx,lin_sig,i_el,col_nb) = nb;
                        stat.mat_usr_el(loc_idx,lin_sig,i_el,col_mean) = moy;
                        stat.mat_usr_el(loc_idx,lin_sig,i_el,col_std) = st_dev;

                        ErrNorm = Err/Sig;
                        iNor = find(ErrNorm>edges_rat,1,'last');
                        if isempty(iNor) | iNor==1
                            iNor=2;
                        end
                        Hist_rat(loc_idx,iNor-1) = Hist_rat(loc_idx,iNor-1)+1;
                        Hist_rat_el(loc_idx,i_el,iNor-1) = Hist_rat_el(loc_idx,i_el,iNor-1)+1;

                        [nb, moy, st_dev] = update_stat(ErrNorm,stat.mat_usr(loc_idx,lin_rat,col_nb),...
                            stat.mat_usr(loc_idx,lin_rat,col_mean),stat.mat_usr(loc_idx,lin_rat,col_std));
                        stat.mat_usr(loc_idx,lin_rat,col_nb) = nb;
                        stat.mat_usr(loc_idx,lin_rat,col_mean) = moy;
                        stat.mat_usr(loc_idx,lin_rat,col_std) = st_dev;

                        [nb, moy, st_dev] = update_stat(ErrNorm,stat.mat_usr_el(loc_idx,lin_rat,i_el,col_nb),...
                            stat.mat_usr_el(loc_idx,lin_rat,i_el,col_mean),stat.mat_usr_el(loc_idx,lin_rat,i_el,col_std));
                        stat.mat_usr_el(loc_idx,lin_rat,i_el,col_nb) = nb;
                        stat.mat_usr_el(loc_idx,lin_rat,i_el,col_mean) = moy;
                        stat.mat_usr_el(loc_idx,lin_rat,i_el,col_std) = st_dev;
                    end
                end
            end
        end
    end
    if ind==0; disp(['DOY: ',num2str(time_entint(time_idx)-doy1)]); end
    ind=ind+1;        
end

Hist_usr.err = Hist_err;
Hist_usr.sig = Hist_sig;
Hist_usr.rat = Hist_rat;

Hist_usr_el.err = Hist_err_el;
Hist_usr_el.sig = Hist_sig_el;
Hist_usr_el.rat = Hist_rat_el;

disp(' ');
disp('COMP_ORBCLK_SBAS_IGS: Ended Successfully ');

