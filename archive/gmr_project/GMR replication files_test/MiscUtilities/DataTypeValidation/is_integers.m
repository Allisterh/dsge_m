function isInts = is_integers(data)
% This helper validates if the input is numeric integers or not.
%
% INPUTS:
%   -> data: input data
%
% OUTPUTS
%   -> isInts: true/false
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
% Note the use of int64 here to allow for greater precision on 64 bit 
% machines. Please see the MATLAB help on integer types for more details.
isInts = (isnumeric(data)&&isequal(int64(data),data));

end