function convStr = convert_string_to_alternative_data_type(...
    str,dataType,checkNumsAreValid)
% This helper converts a string to an alternative, specified data type.
% It is used in the parsing of information from text files into the MAPS
% modelling environment.
%
% INPUTS:
%   -> str: string or cell string array
%   -> dataType: string describing the data type to convert to (consistent
%      with the syntax used in the MATLAB "class" function)
%
% OUTPUTS:
%   -> convStr: equivalent information as alternative data type
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> convert_column_string_array_to_boolean_equivalent
%   -> convert_column_string_array_to_numeric_equivalent
%
% DETAILS:  
%   -> This helper converts a string or cell string array to an equivalent
%      (or underlying) data type, as specified by the dataType input.
%   -> It is useful in the parsing of information from text files into
%      MAPS.
%   -> It makes use of specific helper function to do the conversion, each
%      of which have their own error handling in case of the input strings
%      not being consistent with the class that they are to be converted
%      to. For instance, MAPS permits several string representations of
%      boolean like 'true', 'yes', 'on' etc. Input strings that are being
%      converted to boolean, but which do not meet the MAPS format will
%      result in errors.
%   -> The data type input must be consistent with the syntax using in
%      output to the MATLAB class function - see the MATLAB help for more
%      details. For instance, booleans are of the 'logical' class.
%
% NOTES:
%   -> See <> for MAPS documentation.
%   -> The numeric conversion function permits lazy conversion, whereby
%      strings that are not valid representations of numerics can be 
%      converted to NaNs. This is the default case with the optional 3rd
%      input to this function overriding that if required.
%
% This version: 10/10/2012
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(str) && ~is_column_cell_string_array(str)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);   
elseif ~ischar(dataType)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);  
elseif nargin>2 && ~islogical(checkNumsAreValid)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);    
end

%% CONVERT STRING DATA
switch dataType
    case 'char'
        convStr = str;
    case 'logical'
        convStr = convert_column_string_array_to_boolean_equivalent(str);
    case 'double'
        if nargin < 3
            checkNumsAreValid = false;
        end
        convStr = convert_column_string_array_to_numeric_equivalent(...
            str,checkNumsAreValid);
    otherwise
        errId = ['MAPS:',mfilename,':UnhandledDataType'];
        generate_and_throw_MAPS_exception(errId,{dataType});
end

end