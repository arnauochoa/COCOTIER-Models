function init_aadb()
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
%SIG2_AAD calculate airborne psueudorange confidence (variance) per LAAS MASPS
% initializes AAD-B constants
%   per LAAS MASPS DO-245
% SEE ALSO: SIG2_AAD

%created 24 April, 2001 by Todd Walter

global AAD_A0 AAD_A1 AAD_THETA0

AAD_A0     = 0.11;  % meters
AAD_A1     = 0.13;    % meters
AAD_THETA0 = 4*pi/180.0;   % radians

   
