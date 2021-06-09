function [rowsAreUnique,uniqueRowLogicals] = ...
    are_rows_in_string_array_unique(strArray)
% This helper checks if the rows in a cell string array are unique.
%
% INPUTS:   
%   -> strArray: two-dimensional cell string array
%
% OUTPUTS:  
%   -> rowsAreUnique: true/false
%   -> uniqueRowLogicals: nRows*1 vector of logicals
%
% DETAILS:  
%   -> This helper checks if the rows in an array of row string arrays are
%      unique, returning true or false.
%   -> It also returns a true/false logical for each row in the array. Note
%      that the this logical set will include a single instance of each 
%      repeat row.
%   -> For example, if strArray = {'a' 'z';'b' 'z';'a' 'z';'a' 'y';'b' 'y'}
%      then rowsAreUnique = false & uniqueRowLogicals = [0;1;1;1;1] 
%           
% NOTES:    
%   -> This function is part of a family of string array helpers in MAPS.
%           
% This version: 28/01/2013
% Author(s): Matt Waldron

%% CHECK INPUT
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_two_dimensional_cell_string_array(strArray)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% SORT THE ROWS ALPHABETICALLY
% Note that this is the crucial step because it guarantees that the repeat 
% rows will appear consecutively. Store the index numbers of the sort so
% that the unique rows can be computed on the input array below.
[sortedStrArray,sortInds] = sortrows(strArray);

%% CREATE AN OFFSET SORTED STRING ARRAY
% Create an offset sorted string array by appending an array comprised of
% the 2nd to the final row of the sorted array with a row of empty strings.
% Note that the logic of the implementation below will still hold even if
% the string array contained an entire row of empty strings because the
% sort in the cell above sorts the empty strings to the top of the array.
[nRowsInStrArray,nColsInStrArray] = size(sortedStrArray);
offSetSortedStrArray = [sortedStrArray(2:nRowsInStrArray,:); ...
    repmat({''},[1 nColsInStrArray])];

%% COMPUTE UNIQUE ROWS
% Compare the elements of the sorted array with the offset version. Any
% rows in which each element is true are guaranteed to be non-unique by the
% sort above (so rows will be unique where that is not the case). 
sortedUniqueRowLogicals = ~all(...
    strcmp(sortedStrArray,offSetSortedStrArray),2);

%% REORDER UNIQUE ROWS
% This uses the sort index numbers from above to compute the row-wise 
% unique logicals for output.
uniqueRowLogicals = sortedUniqueRowLogicals;
uniqueRowLogicals(sortInds) = sortedUniqueRowLogicals;

%% COMPUTE LOGICAL
if all(uniqueRowLogicals)
    rowsAreUnique = true;    
else
    rowsAreUnique = false;
end

end