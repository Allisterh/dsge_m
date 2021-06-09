function isFinNums = is_finite_numerics(data)
% This helper validates if the input is finite numerics or not.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isFinNums: true/false
%
% DETAILS: 
%   -> The MATLAB isfinite function acts element by element (i.e. it
%      returns false/true for each element in the array, where finite is 
%      taken to mean not inf, -inf (imaginary equivalents to those) or NaN. 
%   -> The isfinite function will throw an error if the input is not 
%      numeric, so this function works in two steps: a test for numeric, 
%      followed by a test for finite.
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
isFinNums = (isnumeric(data)&&isequal(isfinite(data),true(size(data))));

end