function strsAppended = append_strings(strs,appendageStr)
% This helper appends all strings in a cell string array with any string.
%
% INPUTS:
%   -> strs: two-dimensional cell string array
%   -> appendageStr: string to append all strings with
%
% OUTPUTS:  
%   -> strsAppended: cell string array of appended strings
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_two_dimensional_cell_string_array
%
% DETAILS:  
%   -> This helper appends a set of strings consistently with a single 
%      string. 
%   -> For example, it can be used to change the names of a set of strings 
%      in a MAPS model: if the mnemonic signifying output in the model is
%      'y' and the appendage string is 'old' then the appended output 
%      mnemonic would be 'y_old'.
%
% NOTES:
%   -> This helper is used in the creation of lead and lag mnemonics during 
%      the creation of MAPS models. See <> for details.
%
% This version: 13/02/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_two_dimensional_cell_string_array(strs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~ischar(appendageStr)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% ADD APPENDAGE TO THE MNEMONICS
% Add the input string on to the end of each of the strings in the cell 
% string array using the MATLAB strcat command to create the appended 
% strings.
strsAppended = strcat(strs,repmat({appendageStr},size(strs)));

end