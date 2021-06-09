function repeatedStrs = find_repeated_strings(...
    strs,isCaseInsensitive,excludeEmptyStringRepeats)
% This helper finds all string repetitions in a cell string array.
% If returns all strings that were found twice or more in the cell string
% array input.
%
% INPUTS:   
%   -> strs: cell string array
%   -> isCaseInsensitive: boolean true for a case insensitive search
%   -> excludeEmptyStringRepeats: boolean true to exclude '' from repeats
%
% OUTPUTS:  
%   -> repeatedStrs: column cell string array of repeated strings
%
% DETAILS:  
%   -> This helper finds all strings that appear more than once in the cell
%      string array input either regardless of case or case insensitive.
%   -> It returns a column cell string array with all the repeated strings.
%   -> Optionally, empty ('') string repeats can be excluded from the list
%      returned as output.
%
% NOTES:
%   -> This function is used in model file syntax checking.
%
% This version: 27/05/2014
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~iscellstr(strs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin>1 && ~is_logical_scalar(isCaseInsensitive)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin>2 && ~is_logical_scalar(excludeEmptyStringRepeats)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);    
end

%% SET DEAFULTS FOR SEARCH
% Default is for a case sensistive search with empty strings included.
if nargin < 2
    isCaseInsensitive = false;
end
if nargin < 3
    excludeEmptyStringRepeats = false;
end

%% COMPUTE INDEX NUMBERS OF THE UNIQUE STRINGS
% Compute the index numbers of the unique strings in the column cell string
% array equivalent to the input using the MATLAB unique function.
strs = strs(:);
if isCaseInsensitive
    [~,uniqueStrInds] = unique(lower(strs));
else
    [~,uniqueStrInds] = unique(strs);
end

%% COMPUTE REPEATED STRING LOGICALS
% Find the index numbers that do not appear in the unique string index
% number set as logicals.
nStrs = size(strs,1);
repeatedStrLogicals = ~ismember((1:nStrs)',uniqueStrInds);

%% EXTRACT REPEATED STRINGS
% Extract the repeated strings using rge logicals from above. Note also
% that if a string is repeated more than once, it will appear more than
% once in the list, so take the unique set of those selected.
if isCaseInsensitive
    repeatedStrs = unique(lower(strs(repeatedStrLogicals)));
else
    repeatedStrs = unique(strs(repeatedStrLogicals));
end

%% REMOVE EMPTY STRINGS IF REQUIRED
if excludeEmptyStringRepeats
    repeatedStrs = repeatedStrs(~strcmp('',repeatedStrs));
end
    
end