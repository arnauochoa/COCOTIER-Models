function [indices] = assign_indices(values, mops, mopsNm)
% ASSIGN_INDICES: finds the indexes of mops corresponding to the values
%
% Inputs:
%       values:     vector of the values to which assign the indices
%       mops:       vector of reference value
%       mopsNm:    	value for 'Non monitored' option
%
% 
% $Revision: R2020a$ 
% $Author: Arnau Ochoa Banuelos$
% $Date: July 21, 2020$
%---------------------------------------------------------

    indices = nan(size(values));
    
    for iMops = 2:length(mops)-1
        indBin = find(values > mops(iMops-1) & values <= mops(iMops));
        if ~isempty(indBin), indices(indBin) = iMops; end
    end

    indBin = find(values > mops(iMops));
    if ~isempty(indBin), indices(indBin) = iMops; end

    % Assign MOPS_GIVEI_NM to NaN values
    indBin = isnan(values);
    indices(indBin) = mopsNm;

end