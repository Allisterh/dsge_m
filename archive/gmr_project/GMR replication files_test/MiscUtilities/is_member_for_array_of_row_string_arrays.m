function lookupLogicals = is_member_for_array_of_row_string_arrays(...
    refStrArrays,lookupStrArrays)
% Returns logicals indicating if rows of lookup string array are in ref set.
% It operates on the rows of the lookup array and checks whether it is
% matched by any rows in the reference array.
%
% INPUTS:
%   -> refStrArrays: reference array of strings
%   -> lookupStrArrays: multiple arrays of strings to lookup in ref set
%
% OUTPUTS:
%   -> strLogicals: logical indicating whether row of lookup array exists
%   in the reference array
%
% DETAILS
%   -> This helper returns logicals indicating whether a row of the lookup
%   array appears anywhere in the reference array.
%   -> For example, if refStrArrays is {'a' 'b';'a' 'c'} & lookupStrArrays
%   is {'b' 'd';'a' 'b'}, lookupLogicals is [false;true].
%
% This version: 28/02/2013
% Author(s): Kate Reinold

%% CHECK INPUTS
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_two_dimensional_cell_string_array(refStrArrays)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_two_dimensional_cell_string_array(lookupStrArrays)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK COMPATIBILITY OF LOOKUP & REFERENCE STRING ARRAYS
nLookupStrsToMatchByRow = size(lookupStrArrays,2);
if size(refStrArrays,2) ~= nLookupStrsToMatchByRow
    errId = ['MAPS:',mfilename,':IncompatibleRefAndLookupArrays'];
    generate_and_throw_MAPS_exception(errId);
end

%% GENERATE LOGICALS
nLookupStrArrays = size(lookupStrArrays,1);
lookupLogicals = false(nLookupStrArrays,1);
for iLookupArray = 1:nLookupStrArrays
    iLookupsStrArray = lookupStrArrays(iLookupArray,:);
    refArrayLogicals = lookup_string_array_in_row_string_arrays(...
        refStrArrays,iLookupsStrArray);
    if any(refArrayLogicals)        
        lookupLogicals(iLookupArray) = true;
    end
end

end