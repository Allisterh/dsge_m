function isNonInfNums = is_numeric_and_all_non_inf(data)
% This helper validates if the input is non infinite numerics or not.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isNonInfNums: true/false
%
% DETAILS: 
%   -> The MATLAB isinf function acts element by element (i.e. it
%      returns false/true for each element in the array. 
%   -> The isinf function will throw an error if the input is not 
%      numeric, so this function works in two steps: a test for numeric, 
%      followed by a test for inf.
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
isNonInfNums = (isnumeric(data)&&isequal(isinf(data),false(size(data))));

end