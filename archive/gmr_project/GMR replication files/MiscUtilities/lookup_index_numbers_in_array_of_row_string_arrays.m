function strInds = lookup_index_numbers_in_array_of_row_string_arrays(...
    refStrArrays,lookupStrArrays,isUniqueSetOfLookupStringArrays)
% This returns the indices of an array of row string arrays in a ref set.
% It operates on the rows of the lookup array to compute the index mumber 
% in which that row is matched in the reference array.  
%
% INPUTS:   
%   -> refStrArrays: reference array of strings
%   -> lookupStrArrays: multiple arrays of strings to lookup in ref set
%   -> isUniqueSetOfLookupStringArrays (optional): true/false indicator
%
% OUTPUTS:  
%   -> strInds: indices/rows in the reference set of each row array in the
%      lookup set
%
% DETAILS:  
%   -> This helper returns the index numbers of an array of row string
%      arrays in another, reference set of strings.
%   -> The output is such that: refStrArrays(strInds,:) = lookupStrArrays
%   -> For example, if refStrArrays is {'a' 'b';'a' c'} & lookupStrArrays
%      is {'a' 'c'}, the strInds is a scalar integer equal 2.
%   -> This function will throw an exception if the input strings
%      (reference strings) are not unique on a row-wise basis or if any of
%      the lookup rows of strings do not exist among in the rows of the 
%      reference string array (in which case it is clearly not possible to
%      compute an index).
%   -> The function allows a user choice for whether or not repetition
%      across rows in the lookupStrArrays input is permitted (which is 
%      the default) or not.
%           
% NOTES:    
%   -> This function is part of a family of index lookup functions in MAPS.
%           
% This version: 28/01/2013
% Author(s): Matt Waldron

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
elseif nargin>2 && ~is_logical_scalar(isUniqueSetOfLookupStringArrays)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
end

%% HANDLE OPTIONAL INPUT
% The default for the array of strings to lookup in the reference set is
% that they can contain repeated, non-unique rows.
if nargin < 3
    isUniqueSetOfLookupStringArrays = false;
end

%% CHECK COMPATIBILITY OF LOOKUP & REFERENCE STRING ARRAYS
nLookupStrsToMatchByRow = size(lookupStrArrays,2);
if size(refStrArrays,2) ~= nLookupStrsToMatchByRow
    errId = ['MAPS:',mfilename,':IncompatibleRefAndLookupArrays'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK THAT REFERENCE STRING ARRAYS ARE UNIQUE
refStrArrayRowsAreUnique = are_rows_in_string_array_unique(refStrArrays);
if ~refStrArrayRowsAreUnique
    errId = ['MAPS:',mfilename,':NonUniqueRefStrArrays'];
    generate_and_throw_MAPS_exception(errId);
end    

%% IF APPLICABLE, CHECK THAT LOOKUP STRING ARRAYS ARE UNIQUE
if isUniqueSetOfLookupStringArrays
    lookupStrArrayRowsAreUnique = are_rows_in_string_array_unique(...
        lookupStrArrays);
    if ~lookupStrArrayRowsAreUnique
        errId = ['MAPS:',mfilename,':NonUniqueLookupStrArrays'];
        generate_and_throw_MAPS_exception(errId);
    end
end

%% COMPUTE INDEX NUMBERS
nLookupStrArrays = size(lookupStrArrays,1);
strInds = NaN*ones(nLookupStrArrays,1);
for iLookupArray = 1:nLookupStrArrays
    iLookupsStrArray = lookupStrArrays(iLookupArray,:);
    iLookupArrayLogical = lookup_string_array_in_row_string_arrays(...
        refStrArrays,iLookupsStrArray);
    if any(iLookupArrayLogical)
        strInds(iLookupArray) = find(iLookupArrayLogical);
    end
end

%% THROW EXCEPTION FOR UNKNOWN LOOKUP STRINGS
isLookupArrayInRefLogicals = ~isnan(strInds);
if ~all(isLookupArrayInRefLogicals)
    masterErrId = ['MAPS:',mfilename,':UnknownLookupStrArrays'];
    generate_MAPS_exception_add_causes_and_throw(...
        masterErrId,lookupStrArrays,~isLookupArrayInRefLogicals);
end
    
end