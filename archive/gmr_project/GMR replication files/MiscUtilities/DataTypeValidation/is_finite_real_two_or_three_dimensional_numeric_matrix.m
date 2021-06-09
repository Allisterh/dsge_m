function isFinRealTwoOrThreeDimMat = ...
    is_finite_real_two_or_three_dimensional_numeric_matrix(data)
% This helper validates if the input is a finite real two-dim matrix.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isFinRealTwoOrThreeDimMat: true/false
%
% DETAILS: 
%   -> none
%
% NOTES:   
%   -> This utility is part of a family of utility functions used for 
%      data type validation throughout MAPS.
%
% This version: 11/03/2013
% Author(s): Matt Waldron

%% CHECK INPUT
if nargin < 1
    errId = 'MAPS:data_validation_family_of_functions:BadNargin';
    errArgs = {mfilename};
    generate_and_throw_MAPS_exception(errId,errArgs);
end

%% CHECK DATA
isFinRealTwoOrThreeDimMat = (...
    is_finite_real_two_dimensional_numeric_matrix(data)||...
    is_finite_real_three_dimensional_numeric_matrix(data));

end