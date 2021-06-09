function isPosRealScalar = is_positive_real_numeric_scalar(data)
% This helper validates if the input is a positive real numeric scalar.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isPosRealScalar: true/false
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
isPosRealScalar = (is_real_numeric_scalar(data)&&...
    is_numeric_and_all_positive(data));

end