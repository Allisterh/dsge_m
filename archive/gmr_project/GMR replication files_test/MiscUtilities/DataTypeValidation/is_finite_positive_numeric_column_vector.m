function isFinPosColVec = is_finite_positive_numeric_column_vector(data)
% This helper validates if the input is a finite non-negative column vector.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isFinPosColVec: true/false
%
% DETAILS: 
%   -> none
%
% NOTES:   
%   -> This utility is part of a family of utility functions used for 
%      data type validation throughout MAPS.
%
% This version: 11/10/2013
% Author(s): David Bradnum

%% CHECK INPUT
if nargin < 1
    errId = 'MAPS:data_validation_family_of_functions:BadNargin';
    errArgs = {mfilename};
    generate_and_throw_MAPS_exception(errId,errArgs);
end

%% CHECK DATA
isFinPosColVec = (is_real_numeric_column_vector(data)&&...
    is_numeric_and_all_positive(data));

end