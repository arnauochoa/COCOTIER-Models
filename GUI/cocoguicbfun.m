function guicbfun(hndl)
%*************************************************************************
%*     Copyright c 2009 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
% BUGS: screws up when you open another figure because figure handle is lost
% hndl - handle of button pressed
% Modified 

global GUI_GIVE_MENU
global GUI_UDREGPS_ALGO GUI_UDREGEO_ALGO GUI_GIVE_ALGO GUI_IGPMASK_DAT ...
        GUI_WRSCNMP_ALGO GUI_USRCNMP_ALGO GUI_GPS_SV ...
        GUI_GALILEO_SV
global GUI_UDREGPS_INIT GUI_UDREGEO_INIT GUI_GIVE_INIT  ...
         GUI_WRSCNMP_INIT GUI_USRCNMP_INIT 
global GUI_WRS_DAT GUI_USR_DAT  GUI_GEOPOS_DAT 
global GUI_UDREGPS_HNDL GUI_UDREGEO_HNDL GUI_GIVE_HNDL GUI_IGPMASK_HNDL ...
        GUI_WRSCNMP_HNDL GUI_USRCNMP_HNDL ...
        GUI_WRS_HNDL GUI_WRSPB_HNDL GUI_USR_HNDL GUI_SV_HNDL GUI_GEO_HNDL ...
        GUI_OUT_HNDL GUI_GPS_HNDL GUI_GALILEO_HNDL
global  GUI_PAMODE_HNDL GUI_HAL_HNDL GUI_VAL_HNDL
global GUI_RUN_HNDL GUI_PLOT_HNDL GUI_SETTINGS_HNDL GUI_PERCENT_HNDL ...
        GUI_UDRECONST_HNDL GUI_GEOCONST_HNDL GUI_GIVECONST_HNDL ...
        GUI_LATSTEP_HNDL GUI_LONSTEP_HNDL GUI_WEEKNUM_HNDL GUI_TSTART_HNDL ...
        GUI_TEND_HNDL GUI_TSTEP_HNDL
global UDREI_CONST GEOUDREI_CONST GIVEI_CONST;
global SETTINGS_TR_HNDL SETTINGS_TR_DAT SETTINGS_CLOSE_HNDL SETTINGS_WIND_HNDL SETTINGS_FIRST
global TRUTH_FLAG TRUTH_FILE SETTINGS_TR_FILE
global SETTINGS_BR_HNDL SETTINGS_BR_FILE SETTINGS_BR_DAT
global GUISET_RUN_HNDL BRAZPARAMS RTR_FLAG IPP_SPREAD_FLAG
global MOPS_VAL MOPS_HAL MOPS_NPA_HAL
global IONO_NSE_RESULTSFILE IONO_NSE_STATIONSFILE
global GIVE_MODE_DEFAULT GIVE_MODE_DUALFREQ GIVE_MODE_NSEMODEL

if ismember(hndl,GUI_OUT_HNDL)
       % do nothing
else
    switch (hndl)
    %     case {GUI_RUN_HNDL,GUI_PLOT_HNDL,GUI_WRSPB_HNDL(1),GUI_WRSPB_HNDL(2)}
        case {GUI_RUN_HNDL,GUI_PLOT_HNDL}
        % READ SELECTIONS FROM EACH MENU

        % OUTPUT Menu
            init_hist;
            outputs = zeros(length(GUI_OUT_HNDL),1);
            i = gui_readselect(GUI_OUT_HNDL);
            outputs(i) = 1;
            % read percentage
            percent = gui_readnum(GUI_PERCENT_HNDL,0,100,...
                'Please input valid Percent and run again.') / 100;
            if isnan(percent)
                return;
            end

        % UDRE GPS Menu

            i = 3;
            gpsudrefun = GUI_UDREGPS_ALGO{i};
            if(~isempty(GUI_UDREGPS_INIT{i}))
              feval(GUI_UDREGPS_INIT{i});
            end
            % check udre constant
            if strcmp(gpsudrefun,'af_udreconst')
                UDREI_CONST = 1; % not used
            end

        % UDRE GEO Menu

            i = 3;
            geoudrefun = GUI_UDREGEO_ALGO{i};
            if(~isempty(GUI_UDREGEO_INIT{i}))
              feval(GUI_UDREGEO_INIT{i});
            end
            % check udre constant
            if strcmp(geoudrefun,'af_geoconst')
                GEOUDREI_CONST = get(GUI_GEOCONST_HNDL,'Value');
            end
            % see if geo cnmp function needs to be initialized
            if strcmp(geoudrefun,'af_geoadd2')
                init_geo_cnmp;
            end


        % GIVE Menu

            i = 4;
            givefun = GUI_GIVE_ALGO{i};
            if(~isempty(GUI_GIVE_INIT{i}))
              feval(GUI_GIVE_INIT{i});
            end
            % check give constant
            if strcmp(givefun,'af_giveconst')
                GIVEI_CONST = get(GUI_GIVECONST_HNDL,'Value');
            end
            % check give NSE model files
            if strcmp(givefun,'af_give_nsemodel')
                if isempty(IONO_NSE_RESULTSFILE) || isempty(IONO_NSE_STATIONSFILE)
                    error('Iono error files for NSE not defined');
                else
                    if ~exist(IONO_NSE_RESULTSFILE, 'file')
                        error('Iono error results file for NSE does not exist');
                    elseif ~exist(IONO_NSE_STATIONSFILE, 'file')
                        error('Iono error stations file for NSE does not exist');
                    end
                end
            end
            % check dual frequency
            if strcmp(GUI_GIVE_MENU{i},'Dual Freq')
                give_mode = GIVE_MODE_DUALFREQ;
            elseif strcmp(GUI_GIVE_MENU{i},'NSE Model')
                give_mode = GIVE_MODE_NSEMODEL;            
            else
                give_mode = GIVE_MODE_DEFAULT;
            end

        % IGP Mask Menu

            i = 4;
            igpfile = GUI_IGPMASK_DAT{i};

        % CNMP Menu

            i = 2;
            if isempty(i)
                wrsgpscnmpfun = [];
            else
                wrsgpscnmpfun = GUI_WRSCNMP_ALGO{i};
                if(~isempty(GUI_WRSCNMP_INIT{i}))
                  feval(GUI_WRSCNMP_INIT{i});
                end
            end
            i = 1;
            if isempty(i)
                wrsgpscnmpfun = [];
            else
                usrcnmpfun = GUI_USRCNMP_ALGO{i};
                if(~isempty(GUI_USRCNMP_INIT{i}))
                  feval(GUI_USRCNMP_INIT{i});
                end
            end
            wrsgeocnmpfun=[];

        % WRS Menu

            i = 4;
            wrsfile = GUI_WRS_DAT{i};

        % USER Menu

            i = 6;
            usrpolyfile = GUI_USR_DAT{i};

            % check user latitude and longitude steps
            usrlatstep = gui_readnum(GUI_LATSTEP_HNDL,0,360,...
                    'Please input valid Lat Step and run again.');
            if isnan(usrlatstep)
                return;
            end        
            usrlonstep = gui_readnum(GUI_LONSTEP_HNDL,0,180,...
                    'Please input valid Lon Step and run again.');
            if isnan(usrlonstep)
                return;
            end        
            usrlatstep = ceil(usrlatstep*2)/2;  % resolution up to 0.5 degrees
            usrlonstep = ceil(usrlonstep*2)/2;

        % SV Menu
            GUI_GPS_SV = 1; 
            GUI_GALILEO_SV = 0;

            i = 1;        
            % check week number for almanac
            if i==2 % using yuma
                svfile = ['almyuma'  get(GUI_WEEKNUM_HNDL,'String')  '.txt']; 
            else
                if GUI_GPS_SV
                    if GUI_GALILEO_SV
                      svfile = {'almmops.txt', 'almgalileo.txt'};
                    else
                      svfile = 'almmops.txt';
                    end
                else     
                    svfile =  'almgalileo.txt';
                end
            end
            % check if file(s) exist
            i=1;
            while i<=size(svfile,2)
              if iscell(svfile)
                fid=fopen(svfile{i});
              else
                fid=fopen(svfile);
                i = size(svfile,2);
              end
              if fid==-1
                  fprintf('Almanac file not found.  Please try again.\n');
                  return;
              else
                  fclose(fid);
              end 
              i=i+1;
            end
            %check validity of time steps
            TStart = gui_readnum(GUI_TSTART_HNDL,-604800,604800,...
                    'Please input valid TStart and run again.');
            TEnd = gui_readnum(GUI_TEND_HNDL,TStart,604800,...
                    'Please input valid TEnd and run again.');
            %if TEnd>=86400,
            %    TEnd = 86399;
            %end
            TStep = gui_readnum(GUI_TSTEP_HNDL,1,inf,...
                'Please input valid TStep and run again.');
            if isnan(TStart) || isnan(TEnd) || isnan(TStep) 
                return;
            end

        % GEO Position Menu
            ngeo=0;
            geodata = [];
        % Mode / Alert limit
            pa_mode = 1;
            vhal = [MOPS_VAL, MOPS_HAL];
            vhal(1) = 40;
            vhal(2) = 50;            


        % RUN Simulation

            if hndl==GUI_RUN_HNDL

                svmrun(gpsudrefun, geoudrefun, givefun, usrcnmpfun, wrsgpscnmpfun, ...
                       wrsgeocnmpfun, wrsfile,usrpolyfile, igpfile, svfile, ...
                       geodata, TStart, TEnd, TStep, usrlatstep, usrlonstep, ...
                       outputs, percent, vhal, pa_mode, give_mode);
            elseif hndl==GUI_PLOT_HNDL
                % plots only
                load 'outputs';
                outputprocess(usrdata,igpdata,inv_igp_mask,givei,outputs,percent,...
                              IonoError, iono_mean_enub, iono_sig_enub, ClockEphError, ...
                              clkeph_mean_enub, clkeph_sig_enub, total_mean_enub, total_sig_enub);

            end      

        otherwise
            disp('Function not yet operational.');
    end
    
end


end

