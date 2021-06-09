function isColVecOfUniqueIndsInRange = ...
    is_column_vector_of_unique_indices_in_range(data,maxIndexNumber)
% This helper validates if the input is a unique set of indices in range.
%
% INPUTS:
%   -> data: input data
%   -> maxIndexNumber: scalar integer
%
% OUTPUTS
%   -> isColVecOfUniqueIndsInRange: true/false
%
% DETAILS: 
%   -> none
%
% NOTES:   
%   -> This utility is part of a family of utility functions used for 
%      data type validation throughout MAPS.
%
% This version: 17/10/2013
% Author(s): Matt Waldron

%% CHECK INPUT
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_positive_real_integer(maxIndexNumber)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);    
end

%% CHECK DATA IS COLUMN VECTOR OF UNIQUE POSITIVE REAL INTEGERS
isColVecOfUniquePosRealInts = ...
    is_column_vector_of_unique_positive_real_integers(data);
%% ADD CHECK FOR MAXIMUM VALUE
isColVecOfUniqueIndsInRange = (isColVecOfUniquePosRealInts&&...
    (isempty(data)||max(data)<=maxIndexNumber));

end