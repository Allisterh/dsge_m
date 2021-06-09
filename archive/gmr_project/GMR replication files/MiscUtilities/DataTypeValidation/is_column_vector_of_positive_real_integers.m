function isPosRealIntsColVec = ...
    is_column_vector_of_positive_real_integers(data)
% This helper validates if the input is a col vec of positive real ints.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isPosRealIntsColVec: true/false
%
% DETAILS: 
%   -> none
%
% NOTES:   
%   -> This utility is part of a family of utility functions used for 
%      data type validation throughout MAPS.
%
% This version: 18/01/2013
% Author(s): Matt Waldron

%% CHECK INPUT
if nargin < 1
    errId = 'MAPS:data_validation_family_of_functions:BadNargin';
    errArgs = {mfilename};
    generate_and_throw_MAPS_exception(errId,errArgs);
end

%% CHECK DATA
isPosRealIntsColVec = (is_column_vector_of_real_integers(data)&&...
    is_numeric_and_all_positive(data));

end