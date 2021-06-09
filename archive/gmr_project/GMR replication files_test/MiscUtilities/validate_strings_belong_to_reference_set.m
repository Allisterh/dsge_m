function validate_strings_belong_to_reference_set(strArr,refStrArr,errId)
% This helper validates that strings belong to a reference set.
% It can be used to throw a user-defined exception if not.
%
% INPUTS:
%   -> strArr: string or row cell string array
%   -> refStrArr: row cell string array
%   -> errId (optional): MAPS exception identifier
%
% OUTPUTS:
%   -> none
%
% DETAILS:
%   -> A common task in input validation is to compare a set of strings
%      with a reference set and to report an exception detailing the
%      strings that do not form part of the reference set if there are any.
%      This helper performs that task to avoid the repetition that would 
%      otherwise occur - DRY!      
%
% NOTES:
%   -> Note that if an exception identifier is passed in so that a custom
%      error message is produced, the user must also supply an "Instance"
%      error message within MAPS' error message function - see
%      "generate_MAPS_exception_and_add_causes_from_list" for details.
%
% This version: 22/11/2013
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(strArr) && ~is_row_or_column_cell_string_array(strArr)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);  
elseif ~is_row_or_column_cell_string_array(refStrArr)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin>2 && ~ischar(errId)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);    
end

%% ENSURE STRING ARRAY INPUTS ARE COLUMN ARRAYS
if ischar(strArr)
    strArr = {strArr};
end
strArr = strArr(:);
refStrArr = refStrArr(:);

%% CREATE EXCEPTION IDENTIFIER IF NONE WERE PROVIDED
if nargin < 3
    errId = ['MAPS:',mfilename,':InvalidStrings'];
end

%% FIND ANY STRINGS THAT DO NOT BELONG TO THE REFERENCE SET
invalidStrLogicals = ~ismember(strArr,refStrArr);

%% THROW AN EXCEPTION DETAILING ANY STRINGS NOT BELONGING TO REFERENCE SET 
if any(invalidStrLogicals)
    generate_MAPS_exception_add_causes_and_throw(...
        errId,strArr,invalidStrLogicals);
end

end