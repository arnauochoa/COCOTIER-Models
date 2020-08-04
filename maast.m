%*************************************************************************
%*     Copyright c 2001 The board of trustees of the Leland Stanford     *
%*                      Junior University. All rights reserved.          *
%*     This script file may be distributed and used freely, provided     *
%*     this copyright notice is always kept with it.                     *
%*                                                                       *
%*     Questions and comments should be directed to Todd Walter at:      *
%*     twalter@stanford.edu                                              *
%*************************************************************************
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MATLAB ALGORITHM AVAILABILITY SIMULTATION TOOL %%
%%                    (MAAST)                     %%
%%                  EXE PROGRAM                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version: 1.0
% 2001 Sept
% Stanford University WADGPS Lab

clear;
close all;

addpath(genpath('Data'));
addpath(genpath('GUI'));
addpath(genpath('Init'));
addpath(genpath('Output'));
addpath(genpath('SVM'));
addpath(genpath('Tools'));

init_const;      % global physical and gps constants
init_col_labels; % column indices 
init_mops;       % MOPS constants
init_labels
%init_hist;       % histogram parameters

% launch GUI Control Panel
cocogui;
init_gui;    % read algorithm .m files in directory and form menu (global)
