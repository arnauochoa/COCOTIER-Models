function satdata = af_udreconst(satdata,wrsdata,wrs2satdata,do_mt28)

% AF_UDRE_NSEMODEL: 
%   AF_UDRE_NSEMODEL 
%
% Inputs:
%       satdata:    matrix with the data of the satellites (see MAAST doc)
%       wrsdata:    matrix with the data of the WRS (see MAAST doc)
%
% 
% $Revision: R2020a$ 
% $Author: Arnau Ochoa Banuelos$
% $Date: July 6, 2020$
%---------------------------------------------------------

global UDREI_CONST
global COL_SAT_UDREI COL_SAT_COV COL_SAT_SCALEF COL_SAT_MINMON
global UDRE_NSE_RESULTSFILE

% Load files - TODO: generalize
load(UDRE_NSE_RESULTSFILE, 'latlon', 'udreBias', 'udreStd');

%all satellite meet the minimum monitoring criteria (used for hisogram)
satdata(:,COL_SAT_MINMON)=repmat(1,nsat,1);

% %all satellites have the same UDREI value
% satdata(:,COL_SAT_UDREI) = repmat(UDREI_CONST,nsat,1);
% 
% %if using MT 28 put in the identity matrix for XYZ and 0 for clock
% if do_mt28
%   a=eye(4);
%   a(4,4)=0;
%   a=a(:)';
%   satdata(:,COL_SAT_COV)=repmat(a,nsat,1);
%   satdata(:,COL_SAT_SCALEF)=repmat(0,nsat,1);
end

