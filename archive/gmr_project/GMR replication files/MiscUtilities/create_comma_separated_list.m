function commaSepList = create_comma_separated_list(strs)
% This helper creates a function argument list from a cell string array.
%
% INPUTS:
%   -> strs: row cell string array of strings
%
% OUTPUTS:  
%   -> commaSepList: comma separated list string
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> is_row_cell_string_array
%
% DETAILS:  
%   -> This helper creates a comma separated list string from a row cell 
%      string array of function argument names.
%   -> For example, it can be udes to create an input or output string for 
%      a function call. suppose a function takes 2 inputs called 'in1' & 
%      'in2'. The input to this function would be a cell array naming the 
%      inputs: {'in1' 'in2'}. The output would be a list separating the 2 
%      strings with commas: 'in1,in2'. This output can be used in an 'eval' 
%      function call. 
%
% NOTES:
%   -> See MAPS' linear model symbolics creater function for example usage.
%
% This version: 09/03/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(strs) && ...
        ~is_row_cell_string_array(strs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% CREATE COMMA SEPARATED LIST LIST 
% Create the comma separated list by appending the appropriate number of
% commas on to the cell string array as a new row, then collapse the entire
% cell array into one string.
strs = strs(:)';
commaSepListCell = [strs;[repmat({', '},[1 size(strs,2)-1]) {''}]];
commaSepList = [commaSepListCell{:}];

end