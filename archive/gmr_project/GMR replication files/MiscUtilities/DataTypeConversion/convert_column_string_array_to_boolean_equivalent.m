function logicalVec = ...
    convert_column_string_array_to_boolean_equivalent(strLogicals)
% This helper converts a column string array to a boolean equivalent.
%
% INPUTS:
%   -> strLogicals: string array (of booleans)
%
% OUTPUTS:  
%   -> logicalVec: logical (boolean) vector equivalent
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> get_valid_boolean_strings_config
%   -> generate_MAPS_exception_add_causes_and_throw
%
% DETAILS:  
%   -> This function converts a column cell string array or a single string 
%      to a boolean column vector equivalent. It can be used to parse
%      boolean info from a text file to a logical format.
%
% NOTES:
%   -> This function allows for various string representations of booleans
%      as defined in the configurations below.
%   -> In order to complete the conversion, the function must check that
%      the string input is a valid (MAPS) representation of booleans. 
%
% This version: 13/08/2012
% Author(s): Matt Waldron

%% CHECK INPUT
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(strLogicals) ...
        && ~ischar(strLogicals)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
end

%% TRIM STRING ARRAY
strLogicalsTr = strtrim(strLogicals);

%% ENSURE STRING ARRAY IS IN CELL FORMAT
% This allows us to treat string inputs in exactly the same way as cell
% string array inputs in the code that follows.
if ischar(strLogicalsTr)
    strLogicalsTr = {strLogicalsTr};
end

%% GET VALID BOOLEAN STRINGS
[validTrueStrings,validFalseStrings] = get_valid_boolean_strings_config;
validBooleanStrings = [validTrueStrings;validFalseStrings];

%% CHECK STRING CONTENT IS MAPS BOOLEAN
% Search for invalid string logicals given the MAPS configuration from 
% above. If there are any then throw an exception with the invalid strings
% listed as error cases.
invalidStrLogicalCell = cellfun(@(x) ~any(strcmp(...
    x,validBooleanStrings)),strLogicalsTr,'UniformOutput',false);
invalidStrLogicals = [invalidStrLogicalCell{:}]';
if any(invalidStrLogicals)
    errId = ['MAPS:',mfilename,':InvalidBooleanStrs'];
    errArgs = validBooleanStrings';
    generate_MAPS_exception_add_causes_and_throw(...
        errId,strLogicalsTr,invalidStrLogicals,errArgs);
end

%% CONVERT STRING BOOLEAN TO LOGICALS
% Given that the cell string array is a valid MAPS representation of
% Boolean, the logical equivalent can be constructed by finding those
% elements of the cell string array that match the valid representations of
% boolean true.
trueStrLogicalCell = cellfun(@(x) any(strcmp(...
    x,validTrueStrings)),strLogicalsTr,'UniformOutput',false);
logicalVec = [trueStrLogicalCell{:}]';

end