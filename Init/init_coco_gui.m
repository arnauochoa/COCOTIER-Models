function init_gui()
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
% globals for GUI objects

global GUI_GIVE_MENU
global GUI_UDREGPS_ALGO GUI_UDREGEO_ALGO GUI_GIVE_ALGO GUI_IGPMASK_DAT ...
        GUI_WRSCNMP_ALGO GUI_USRCNMP_ALGO 
global GUI_UDREGPS_INIT GUI_UDREGEO_INIT GUI_GIVE_INIT GUI_WRSTRP_INIT ...
        GUI_USRTRP_INIT GUI_WRSCNMP_INIT GUI_USRCNMP_INIT 
global GUI_WRS_DAT GUI_USR_DAT GUI_SV_DAT GUI_GEOPOS_DAT
global GUI_OUT_CLKEPHMAP GUI_OUT_IONOMAP GUI_OUT_CLKEPHMAPSIM ...
        GUI_OUT_IONOMAPSIM GUI_OUT_TOTALMAPSIM GUI_OUT_CLKEPHHIST ...
        GUI_OUT_IONOHIST GUI_OUT_TOTALHIST
global GUI_OUT_HNDL  
global GUI_RUN_HNDL GUI_PLOT_HNDL GUI_PERCENT_HNDL ...
        GUI_LATSTEP_HNDL GUI_LONSTEP_HNDL GUI_TSTART_HNDL ...
        GUI_TEND_HNDL GUI_TSTEP_HNDL

% init flags from settings menu
global SETTINGS_FIRST TRUTH_FLAG;
SETTINGS_FIRST = 0;
TRUTH_FLAG = 0;

% Algorithms
% Menu items
GUI_GIVE_MENU    = {'ADD','ADDR6/7','Constant','NSE Model','Dual Freq'};

GUI_UDREGPS_ALGO = {'af_udreadd','af_udreadd2','af_udreconst',...
                    'af_udre_nsemodel','af_udrecustom2'};
GUI_UDREGEO_ALGO = {'af_geoadd','af_geoadd2','af_geoconst',...
                    'af_geocustom1','af_geocustom2'};
GUI_GIVE_ALGO    = {'af_giveadd','af_giveadd1','af_giveconst',...
                    'af_give_nsemodel',''};
GUI_IGPMASK_DAT  = {'igpjoint.txt','igpjoint_R6_7.txt', 'igpjoint_R8_9.txt',...
                    'igpegnos.txt', 'igpmsas.txt', 'igpbrazil.txt'};
GUI_WRSCNMP_ALGO = {'af_cnmpadd','af_cnmpagg','af_wrscnmpcustom'};
GUI_USRCNMP_ALGO = {'af_cnmp_mops','af_cnmpaad','af_cnmpaad'};

GUI_UDREGPS_INIT = {'init_udre_osp','init_udre2_osp','','init_udre_nsemodel',''};
GUI_UDREGEO_INIT = {'init_geo_osp','init_geo2_osp','','',''};
GUI_GIVE_INIT = {'init_give_osp','init_giveadd1_osp','','init_give_nsemodel',''};
GUI_WRSTRP_INIT = {'init_trop_osp',''};
GUI_USRTRP_INIT = {'','init_trop_osp'};
GUI_WRSCNMP_INIT = {'init_cnmp','',''};
GUI_USRCNMP_INIT = {'init_cnmp_mops','init_aada','init_aadb'};

% Simulation Configs
% Menu items

GUI_WRS_DAT = {'wrs25.txt','wrs_R6_7.txt','wrs_R8_9.txt','egnos_rims.txt', ...
               'rs_msas.txt','brazil_wrs.txt','wrs_world16.txt','wrs_world30.txt','',''};
GUI_USR_DAT = {'usrconus.txt','usralaska.txt','usrcanada.txt','usrmexico.txt',...
               'usrn_america.txt','usreurope.txt','usrmsas.txt','usrbrazil.txt','usrworld.txt'};
GUI_SV_DAT = {'almmops.txt','almyuma.txt'};

% Outputs
GUI_OUT_CLKEPHMAP = 1;
GUI_OUT_IONOMAP = 2;
GUI_OUT_CLKEPHMAPSIM = 3;
GUI_OUT_IONOMAPSIM = 4;
GUI_OUT_TOTALMAPSIM = 5;
GUI_OUT_CLKEPHHIST = 6;
GUI_OUT_IONOHIST = 7;
GUI_OUT_TOTALHIST = 8;


% tag fields for buttons
GUI_OUT_TAGS = {'cbClkephMapEl','cbIonoMapEl','cbClkephMapSim','cbIonoMapSim'...
                'cbTotalMapSim', 'cbClkephHist','cbIonoHist', 'cbTotalHist'};

load geo.txt;
GUI_GEOPOS_DAT=geo;

% output menu buttons
for i = 1:length(GUI_OUT_TAGS)
    GUI_OUT_HNDL(i) = findobj('Tag',GUI_OUT_TAGS{i});
end
GUI_RUN_HNDL = findobj('Tag','pbRun');
GUI_PLOT_HNDL = findobj('Tag','pbPlot');
GUI_PERCENT_HNDL = findobj('Tag','txtPercent');

% Config handles
GUI_LATSTEP_HNDL = findobj('Tag','txtUsrLatStep');
GUI_LONSTEP_HNDL = findobj('Tag','txtUsrLonStep');
GUI_TSTART_HNDL = findobj('Tag','txtTStart');
GUI_TEND_HNDL = findobj('Tag','txtTEnd');
GUI_TSTEP_HNDL = findobj('Tag','txtTStep');

%% TODO:  Automatic creation of gui menu

% fix text sizing to 10 points

allh = get(gcf,'Children');
n = length(allh);

for i=1:n,
    set(allh(i),'units','normalized');
end
for i=1:n,
    set(allh(i),'fontunits','points');
    set(allh(i),'fontsize',10);
end
