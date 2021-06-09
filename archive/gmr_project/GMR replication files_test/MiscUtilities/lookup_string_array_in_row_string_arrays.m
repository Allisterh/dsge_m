function refLogicals = lookup_string_array_in_row_string_arrays(refStrArrays,lookupArray)
% Return logical for row string array in an array of row string arrays.
% Look up a row string array in an array of row string arrays and return
% logicals indicating whether it was found in the reference array.
%
% INPUTS:
%   -> refStrArrays: reference array of strings
%   -> lookupArray: array of strings to lookup in reference set
%
% OUTPUTS:
%   -> refLogicals: logicals indicating where lookup array exists in the
%   reference array
%
% DETAILS:
%   -> This helper returns logicals indicating which rows of the reference
%   array match the lookup array.
%   -> For example, if refStrArrays {'a' 'b';'a' 'c';'b' 'd'} and
%   lookupArray is {'b' 'd'}, refLogicals is [false;false;true].
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
elseif ~is_row_cell_string_array(lookupArray)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK COMPATIBILITY OF LOOKUP & REFERENCE STRING ARRAYS
nLookupStrsToMatchByRow = size(lookupArray,2);
if size(refStrArrays,2) ~= nLookupStrsToMatchByRow
    errId = ['MAPS:',mfilename,':IncompatibleRefAndLookupArrays'];
    generate_and_throw_MAPS_exception(errId);
end

%% GENERATE LOGICALS
nRefStrArrays = size(refStrArrays,1);
refLogicals = true(nRefStrArrays,1);
for iStrToMatch = 1:nLookupStrsToMatchByRow
    refLogicals = refLogicals&ismember(...
        refStrArrays(:,iStrToMatch),lookupArray{iStrToMatch});
end
end