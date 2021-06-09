function matEquiv = convert_cell_array_of_vectors_to_matrix_equivalent(...
    cellVectors,nMatCols)
% This helper converts a column cell array of row vectors to a matrix. 
% It is similar to the MATLAB cell2mat function but allows for unequal row
% vector lengths and for a user specified number of columns in the output
% matrix.
% 
% 
% INPUTS:   
%   -> cellVectors: column cell array of numerical row vectors
%   -> nMatCols (optional): number of columns for the matrix output
%
% OUTPUTS:  
%   -> matEquiv: numerical matrix equivalent of the cell of row vectors
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_array
%   -> is_positive_real_integer
%
% DETAILS:  
%   -> This helper converts a column cell array of row vectors to a matrix
%      equivalent with an optional user specified number of columns.
%   -> If the row vectors are of equal length and nMatCols is not input (or 
%      is set equal the row length), then this function replicates the
%      MATLAB function cell2mat.
%   -> If the row vectors are of unequal length, then this function fills
%      in any gaps in the matrix with NaN values.
%   -> The optional number of matrix columns input can be used to expand
%      the number of columns in the matrix relative to the maximum row 
%      length in the cells. It cannot be used to reduce the number of
%      columns in the matrix (because the result could not be described as
%      being equivalent to the row vectors input).
%           
% NOTES:    
%   -> See <> for a description of MAPS utility functions.
%           
% This version: 04/03/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of the inputs is as expected. All inputs
% are compulsory.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_column_cell_array(cellVectors) || ...
        ~all(cellfun(@isnumeric,cellVectors)|...
        cellfun(@islogical,cellVectors)) || ...
        any(cellfun(@ndims,cellVectors)-2) || ...
        any(cellfun('size',cellVectors,1)-1)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
elseif nargin==2 && ~is_positive_real_integer(nMatCols)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% DETERMINE THE DIMENSIONALITY OF THE CELL
% Determine the number of row vectors in the cell. Determine the length of 
% each of those vectors. 
nVectors = size(cellVectors,1);
nColsInEachVec = cellfun('size',cellVectors,2);

%% SET THE COLUMN NUMBERS IN THE MATRIX 
% Compute the maximum number of columns found in the cell array of vectors
% input. If the optional matrix column number was input, check that it is
% at least as large as the maximum vector lenegth. If not, throw an
% exception. If the optional matrix column number was not input, set the
% number of columns in the matrix equal to the maximum row vector length.
maxnColsInVecs = max(nColsInEachVec);
if nargin == 2
    if nMatCols < maxnColsInVecs
        errId = ['MAPS:',mfilename,':IncompatibleColNums'];
        generate_and_throw_MAPS_exception(errId);
    end
else
    nMatCols = maxnColsInVecs;
end

%% HETEROGENOUS VECTOR LENGTH CASE
% Compute the matrix for the case in which the row vectors in the cell are
% heterogenous in length.
if any(nColsInEachVec-nMatCols)
    matEquiv = NaN*ones(nVectors,nMatCols);
    for iVec = 1:nVectors
        matEquiv(iVec,1:nColsInEachVec(iVec)) = cellVectors{iVec};
    end
end

%% HOMOGENOUS VECTOR LENGTH CASE
% Compute the matrix for the case in which the row vectors in the cell are
% homogenous in length. The purpose of setting the two cases is to allow
% quicker computation of the matrix in the homogenous lengths case.
if ~any(nColsInEachVec-nMatCols)
    matEquiv = [cell2mat(cellVectors) ...
        ones(nVectors,nMatCols-maxnColsInVecs)*NaN];
end

end
