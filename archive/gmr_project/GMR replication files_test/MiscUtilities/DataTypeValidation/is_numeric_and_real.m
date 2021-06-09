function isRealNums = is_numeric_and_real(data)
% This helper validates if the input is real numerics or not.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isRealNums: true/false
%
% DETAILS: 
%   -> The MATLAB isreal function acts on an entire matrix of data (i.e. it
%      returns true only if the entire array is comprised of real numbers). 
%   -> It does not require the input to be numeric. For example, logicals
%      are real despite not being numeric, so this function also checks if
%      the input is numeric.
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
isRealNums = (isreal(data)&&isnumeric(data));

end