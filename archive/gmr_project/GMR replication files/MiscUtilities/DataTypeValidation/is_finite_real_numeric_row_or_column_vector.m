function isFinRealRowOrColVec = ...
    is_finite_real_numeric_row_or_column_vector(data)
% This helper validates if the input is a finite real row or column vector.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isFinRealRowOrColVec: true/false
%
% DETAILS: 
%   -> none
%
% NOTES:   
%   -> This utility is part of a family of utility functions used for 
%      data type validation throughout MAPS.
%
% This version: 28/03/2013
% Author(s): Matt Waldron

%% CHECK INPUT
if nargin < 1
    errId = 'MAPS:data_validation_family_of_functions:BadNargin';
    errArgs = {mfilename};
    generate_and_throw_MAPS_exception(errId,errArgs);
end

%% CHECK DATA
isFinRealRowOrColVec = (is_finite_real_numeric_row_vector(data)||...
    is_finite_real_numeric_column_vector(data));

end