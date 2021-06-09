function [varInds,eqInds] = extract_index_numbers_from_incidence_matrix(...
    incMat)
% This utility extracts index numbers from an incidence matrix.
% It computes the index numbers of the variables and equations
% corresponding to the non-zero (true) entries in the input incidence 
% matrix.
%
% INPUTS:   
%   -> incMat: two-dimensional logical incidence matrix
%
% OUTPUTS:  
%   -> varInds: index numbers of variables
%   -> eqInds: corresponding index numbers of equations
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%
% DETAILS:  
%   -> This utility computes the index numbers of the non-zero (true) 
%      entries in the input incidence matrix.
%   -> For example, suppose the input incidence matrix is 
%      [0 0 1; 1 0 1; 0 1 0], where the equations are indexed by rows and 
%      the variables by columns. In that case, the output to this function
%      would be varInds = [3;1;3;2] & eqInds = [1;2;2;3]
%           
% NOTES:    
%   -> See <> for a description of MAPS symbolic functionality.
%           
% This version: 04/03/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_two_dimensional_logical_matrix(incMat)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% FIND NON-ZERO ENTRIES
% Compute the row and column index numbers of the non-zero entries in the
% incidence matrix.
[indRow,indCol] = find(incMat);

%% SORT INDICES
% Sort these non-zero index numbers os that they are in an equation-sorted 
% order.
[eqInds,indSort] = sort(indRow);
varInds = indCol(indSort);
eqInds = eqInds(:);
varInds = varInds(:);

end