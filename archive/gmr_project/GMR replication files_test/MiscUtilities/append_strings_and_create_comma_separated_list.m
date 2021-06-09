function commaSepList = append_strings_and_create_comma_separated_list(...
    strs,appendageStr)
% This helper creates a function argument list from a cell string array.
%
% INPUTS:
%   -> strs: two-dimensional cell string array
%   -> appendageStr: string to append all strings with
%
% OUTPUTS:  
%   -> commaSepList: comma separated list string
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> append_strings
%   -> create_comma_separated_list
%
% DETAILS:  
%   -> This helper creates a function argument list string from a row cell 
%      string array of function argument names and a string to append to 
%      those names.
%   -> For example, it can be udes to create an input or output string for 
%      a function call. suppose a function takes 2 inputs called '1in' & 
%      '2in'. The input to this function would be a cell array of strings:
%      {'1' '2'} and a string to append to them: 'in'. The output would be 
%      a list separating the 2 strings with commas: '1in,2in'. This output 
%      can be used in an 'eval' function call. 
%
% NOTES:
%   -> See MAPS' linear model symbolics creater function for example usage.
%   -> This helper is a wrapper which calls to further helper functions. As
%      such, it leaves all error checking to those helper functions
%      (exception that which is needed for this function to work (i.e.
%      input numbers).
%
% This version: 09/03/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number of inputs is as expected.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
end

%% APPEND STRINGS
% Use a helper function to append the cell string array input with the
% string passed in.
strsAppended = append_strings(strs,appendageStr);

%% CREATE THE COMMA SEPARATED LIST 
% Use another helper to convert the cell string array to a comma separated
% list of arguments.
commaSepList = create_comma_separated_list(strsAppended);

end