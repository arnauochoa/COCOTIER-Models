function [G_usr, W_usr] = findGW(usr2satdata, usridx, sig2)
% FINDGW Computes the G and W matrices
%   This function computes the G matrix in ENU and the W matrix
%
% =========================================================================
% Created by Arnau Ochoa Bañuelos August 2020 for the COCOTIER project

global COL_U2S_EL COL_U2S_AZ COL_U2S_LOSENU

nUsr = max(usridx);

G_usr = cell(nUsr, 1);
W_usr = cell(nUsr, 1);

[usr2satdata(:,COL_U2S_EL), usr2satdata(:,COL_U2S_AZ)] = ...
                            find_elaz(usr2satdata(:,COL_U2S_LOSENU));

% Find G matrices in ENU coordinates
for iUsr = 1:nUsr
    thisUser = find(usridx == iUsr);
    
    G = nan(length(thisUser), 4);
    
    G(:, 1) =   cos(usr2satdata(thisUser, COL_U2S_EL)) .*   ...
                sin(usr2satdata(thisUser, COL_U2S_AZ));
            
    G(:, 2) =   cos(usr2satdata(thisUser, COL_U2S_EL)) .*   ...
                cos(usr2satdata(thisUser, COL_U2S_AZ));
            
    G(:, 3) =   sin(usr2satdata(thisUser, COL_U2S_EL));
    
    G(:, 4) =   1;
    
    G_usr{iUsr} = G;
    
    W_usr{iUsr} = diag( 1 ./ sig2(thisUser) ); 
end

end