function isNonNegRealInt = is_non_negative_real_integer(data)
% This helper validates if the input is a non negative real integer.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isNonNegRealInt: true/false
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
isNonNegRealInt = (is_real_integer(data)&&...
    is_numeric_and_all_non_negative(data));

end