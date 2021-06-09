function colCellStr = ...
    convert_string_or_vector_string_array_to_column_array(strOrVecCellStr)
% This utility converts a string or vector of strings to a col cell string.
%
% INPUTS:
%   -> strOrVecCellStr: string, 
%
% OUTPUTS
%   -> colCellStr: column cell string array
%
% DETAILS: 
%   -> This function converts a string or row cell string array to a column
%      cell string array. It also permist a column cell string array input
%      in which case output is the same as the input.
%
% NOTES:   
%   -> This utility is useful in the management of inputs in functions 
%      designed to allow for some flexibility over the precise format of
%      inputs passed in.
%
% This version: 20/11/2012
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId);
end

%% CONVERT STRING OR VECTOR CELL STRING INPUT TO COLUMN CELL STRING ARRAY
if ischar(strOrVecCellStr)
    colCellStr = {strOrVecCellStr};
elseif is_row_cell_string_array(strOrVecCellStr)
    colCellStr = strOrVecCellStr';
elseif is_column_cell_string_array(strOrVecCellStr)
    colCellStr = strOrVecCellStr;
else
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

end