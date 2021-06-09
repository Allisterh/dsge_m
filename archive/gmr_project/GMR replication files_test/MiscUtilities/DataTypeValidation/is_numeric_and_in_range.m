function isWithinRange = is_numeric_and_in_range(data,min,max,exclusive)
% Validates whether the input is all numeric and within a specified range.
% INPUTS:
%   -> data: --DESCRIPTION HERE
%   -> min: minimum permitted value for all entries in data
%   -> max: maximum permitted value for all entries in data
%   -> exclusive (optional): boolean indicating whether the check should be
%   inclusive or exclusive of the min / max bounds. Defaults to false (ie
%   inclusive of bounds)
% OUTPUTS:
%   -> isWithinRange: true if all entries of data are numeric values
%   between min and max.
% DETAILS:
%   -> 
% NOTES:
%   -> 

% This version: 05/02/2013
% Author(s): David Bradnum

%% CHECK INPUT
if nargin < 3
    errId = 'MAPS:data_validation_family_of_functions:BadNargin';
    errArgs = {mfilename};
    generate_and_throw_MAPS_exception(errId,errArgs);
elseif ~is_real_numeric_scalar(min)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_real_numeric_scalar(max)
        errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin >= 4 && ~is_logical_scalar(exclusive)
    errId = ['MAPS:',mfilename,':BadInput4'];
    generate_and_throw_MAPS_exception(errId);    
end

%% HANDLE OPTIONAL INPUT
if nargin < 4
    exclusive = false;
end

%% CHECK DATA
if exclusive
    inRange = isequal(data>min & data<max,true(size(data)));
else 
    inRange = isequal(data>=min & data<=max,true(size(data)));
end

isWithinRange = (isnumeric(data) & inRange);

end