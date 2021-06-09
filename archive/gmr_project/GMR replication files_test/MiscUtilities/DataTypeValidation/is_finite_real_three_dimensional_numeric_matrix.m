function isFinRealThreeDimMat = ...
    is_finite_real_three_dimensional_numeric_matrix(data)
% This helper validates if the input is a finite real three-dim matrix.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isFinRealThreeDimMat: true/false
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
isFinRealThreeDimMat = (is_real_three_dimensional_numeric_matrix(data)&&...
    is_finite_numerics(data));

end