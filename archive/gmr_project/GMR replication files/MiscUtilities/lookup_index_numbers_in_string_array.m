function strInds = lookup_index_numbers_in_string_array(...
    refStrs,lookupStrs,isUniqueSetOfLookupStrings)
% This helper returns the indices of strings in a cell string array.
% It can be used to lookup the index number of one or more strings in a
% reference cell string array.
%
% INPUTS:
%   -> refStrs: cell array of reference strings
%   -> lookupStrs: cell array of strings to lookup
%   -> isUniqueSetOfLookupStrings (optional): true/false
%
% OUTPUTS:
%   -> strInds: indices of lookupStrs in refStrs
%
% DETAILS:
%   -> This helper returns the index numbers of a set of strings in
%      another, reference set of strings.
%   -> The output is such that: refStrs(strInds) = lookupStrs
%   -> This function will throw an exception if the input strings
%      (reference strings) are not unique or if any of the strings to
%      lookup do not exist among the reference strings (in which case it is
%      clearly not possible to compute an index).
%   -> The function will also optionally test and raise an exception if any
%      of the strings in the lookupStrs set are not unique.
%
% NOTES:
%   -> This is a general string index lookup function but is used within a
%      model index lookup function to find the model indices of a set of
%      mnemonics.
%
% This version: 28/01/2013 (updated for CRd Analytical 6599428 & .......)
% Author(s): Matt Waldron / David Bradnum

%% CHECK INPUTS
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(refStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~ischar(lookupStrs) && ~is_column_cell_string_array(lookupStrs)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin>2 && ~is_logical_scalar(isUniqueSetOfLookupStrings)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
end

%% HANDLE OPTIONAL INPUT FLAG
% The default is that repeats may exist in the strings to lookup such that
% the same index number may appear more than once in the output indices.
if nargin < 3
    isUniqueSetOfLookupStrings = false;
end

%% CONVERT SINGLE STRING TO LOOKUP INTO CELL, IF NECESSARY
if ischar(lookupStrs)
    lookupStrs = {lookupStrs};
end

%% CHECK THAT REFERENCE STRINGS ARE UNIQUE
if size(unique(refStrs),1) ~= size(refStrs,1)
    errId = ['MAPS:',mfilename,':NonUniqueRefStrs'];
    generate_and_throw_MAPS_exception(errId);
end

%% IF APPLICABLE, CHECK THAT LOOKUP STRINGS ARE UNIQUE
if isUniqueSetOfLookupStrings
    if size(unique(lookupStrs),1) ~= size(lookupStrs,1)
        errId = ['MAPS:',mfilename,':NonUniqueLookupStrs'];
        generate_and_throw_MAPS_exception(errId);
    end
end

%% COMPUTE INDEX NUMBERS OF LOOKUP STRINGS
[isLookupInRefLogicals,strInds] = ismember(lookupStrs,refStrs);

%% THROW EXCEPTION FOR UNKNOWN LOOKUP STRINGS
if ~all(isLookupInRefLogicals)
    masterErrId = ['MAPS:',mfilename,':UnknownLookupStrs'];
    generate_MAPS_exception_add_causes_and_throw(...
        masterErrId,lookupStrs,~isLookupInRefLogicals);
end

end