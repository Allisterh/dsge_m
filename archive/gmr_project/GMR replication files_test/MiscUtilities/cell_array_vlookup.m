function varargout = cell_array_vlookup(strsToMatch,cellStrArr,varargin)
% This function performs an array vlookup on a cell string array.
% It tries to match a row cell array of strings on a row-wise basis in a 
% (larger) cell string array input. It returns elements of the cells in 
% varargin that correspond to those index numbers.
%
% INPUTS:   
%   -> strsToMatch: row cell string array of strings to match in cellStrArr
%   -> cellStrArr: cell string array
%   -> varargin: column cell arrays of data to lookup
%
% OUTPUTS:  
%   -> varargout: column cell arays of values matched by row
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> is_two_dimensional_cell_string_array
%   -> is_column_cell_array
%
% DETAILS:  
%   -> This function attempts to find matches to all of the strings in
%      strsToMatch to stings in the corresponding columns of cellStrArr. 
%   -> It does this on a row-wise basis, computing the logical indices of 
%      each of the rows that matches strsToMatch. It then returns the 
%      elements in each of the column cell vectors in varargin that 
%      correspond to those indices.
%   -> If there are no matches, then this function will return empty cell
%      arrays as outputs in varargout. 
%   -> It throws an error if the dimensions of any of the inputs are
%      consistent with each other.
%           
% NOTES:    
%   -> See <> for a description of MAPS helpers.
%   -> Note that the string match step is not case sensitive.
%           
% This version: 18/05/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Perform routine checks on the inputs to check that they are of the right
% shape.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_row_cell_string_array(strsToMatch)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_two_dimensional_cell_string_array(cellStrArr)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif ~all(cellfun(@is_column_cell_array,varargin))
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
end

%% COMPUTE LOGICAL INDICES
% Compute the logical index matches for the rows in cellStrArr that have
% columns that match the strings in strsToMatch.
nRowsInCell = size(cellStrArr,1);
nStrsToMatch = size(strsToMatch,2);
if size(cellStrArr,2) ~= nStrsToMatch
    errId = ['MAPS:',mfilename,':Input1InconsistentInput2'];
    generate_and_throw_MAPS_exception(errId);
else
    cellStrArrToMatch = strsToMatch(ones(nRowsInCell,1)*(1:nStrsToMatch));
    logicalIndsOfMatch = all(strcmpi(cellStrArrToMatch,cellStrArr),2);
end

%% EXTRACT CELL ARRAYS
% Extract the elements of the varargin cells that have the same index
% numbers as matched in the cellStrArr.
nArg = size(varargin,2);
varargout = cell(1,nArg);
for iArg = 1:nArg
    if size(varargin{iArg},1) ~= nRowsInCell
        errId = ['MAPS:',mfilename,':DimsMatchCellInconsistentLookupCell'];
        generate_and_throw_MAPS_exception(errId);
    else
        varargout{iArg} = varargin{iArg}(logicalIndsOfMatch);
    end
end

end