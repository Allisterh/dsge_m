function isColVecOfUniquePosRealInts = ...
    is_column_vector_of_unique_positive_real_integers(data)
% This helper validates if the input is a col vec of unique pos real ints.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isColVecOfUniquePosRealInts: true/false
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
if nargin < 1
    errId = 'MAPS:data_validation_family_of_functions:BadNargin';
    errArgs = {mfilename};
    generate_and_throw_MAPS_exception(errId,errArgs);
end

%% CHECK DATA IS COLUMN VECTOR OF POSITIVE REAL INTEGERS
isPosRealIntsColVec = (is_column_vector_of_real_integers(data)&&...
    is_numeric_and_all_positive(data));

%% ADD CHECK FOR UNIQUENESS
isUnique = (size(unique(data),1)==size(data,1));
isColVecOfUniquePosRealInts = (isPosRealIntsColVec&&isUnique);

end