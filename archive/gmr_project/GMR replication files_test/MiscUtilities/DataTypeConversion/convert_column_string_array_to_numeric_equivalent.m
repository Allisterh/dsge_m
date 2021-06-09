function numVec = convert_column_string_array_to_numeric_equivalent(...
    strNums,checkNumsAreValid)
% This helper converts a column string array to a numeric equivalent.
%
% INPUTS:
%   -> strNums: column cell string array (of numerics) or a single string
%   -> checkNumsAreValid (optional): flag for numeric check
%
% OUTPUTS:  
%   -> numVec: numeric column vector equivalent
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> generate_MAPS_exception_add_causes_and_throw
%
% DETAILS:  
%   -> This function converts a column cell string array or a single string 
%      to a numeric column vector equivalent. For example, it can be used
%      to parse numeric info from a text file to a numeric format.
%
% NOTES:
%   -> This function allows for 16 significant figures in the conversion of
%      strings to numerics in the call to the MATLAB str2double function.
%   -> There is a presumption that the strings input are string
%      representations of numbers, but this is only tested for if the 
%      second input is provided and set to boolean true (allowing for some
%      flexibility).  Strings that are not numeric will be represented as
%      NaNs.
%
% This version: 15/10/2012
% Author(s): Matt Waldron

%% CHECK INPUT
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(strNums) && ~ischar(strNums)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId); 
elseif nargin>1 && ~islogical(checkNumsAreValid)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK FOR OPTIONAL INPUT & SET DEFAULT
if nargin < 2
    checkNumsAreValid = false;
end

%% TRIM STRING ARRAY
strNumsTr = strtrim(strNums);

%% CONVERT STRINGS TO NUMERICS 
% Use the MATLAB str2double command to convert the column string array to a
% numeric column vector equivalent (which allows for up to 16 significant 
% figures).
numVec = str2double(strNumsTr);

%% CHECK NUMERICS (IF APPLICABLE)
if checkNumsAreValid
    badStrNumericLogicals = isnan(numVec);
    if any(badStrNumericLogicals)
        if ischar(strNums)
            strNumsTr = {strNumsTr};
        end
        errId = ['MAPS:',mfilename,':BadStringNumerics'];
        generate_MAPS_exception_add_causes_and_throw(...
            errId,strNumsTr,badStrNumericLogicals);
    end
end

end