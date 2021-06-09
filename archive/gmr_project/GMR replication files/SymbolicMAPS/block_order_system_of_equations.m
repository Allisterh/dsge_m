function [orderedEqStrs,orderedAssignVarMnems] = ...
    block_order_system_of_equations(eqStrs,assignVarMnems)
% This helper block orders a (recursive) system of equations.
% It reorders the equations and endogenous variables (which must be
% pre-assigned as outputs) such that the equations could be evaluated one-
% by-one in a loop from the 1st equation in the reorderd set to the final
% equation.
%
% INPUTS:
%   -> eqStrs: cell string array of equations
%   -> assignVarMnems: cell string array of endogenous variable mnemonics
%
% OUTPUTS:
%   -> orderedEqStrs: cell string array of block ordered equations
%   -> orderedAssignVarMnems: cell string array of block ordered endogenous
%      variable mnemonics
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> compute_equations_incidence_matrix
%   -> examine_incidence_matrix_and_swap_rows (sub-function)
%   -> generate_MAPS_exception
%   -> generate_MAPS_exception_and_add_as_cause
%
% DETAILS:
%   -> This function block orders a system of equations and its endogenous
%      variable mnemonics.
%   -> There are two limitations in its usage: (i) the system of equations
%      must be recursive; (ii) the endogenous variables must represent an
%      ordered output assignment set in the sense that the 1st endogenous
%      variable is assigned to (determined by) equation 1, the 2nd is 
%      assigned to equation 2 etc. This function will throw an exception if
%      neither of these conditions are met. 
%   -> It operates on the incidence matrix of the equation system with
%      respect to the endogenous variables using a variant of Duff's
%      algorithm. It works by iteratively exhanging rows (and columns) in 
%      the incidence matrix until the incidence matrix associated with a
%      reordered set of equations and variables is lower triangular.
%   -> In the reordering process, it moves all simultaneous blocks to the
%      bottom of the incidence matrix and would throw an exception
%      detailing the equations that form part of this block or blocks.
%   -> Note that Duff's algroithm is more complex and general than the 
%      algorithm used here because it does not require either of the
%      assumptions stated above.  In fact, its main purpose is to search
%      for an output assignment set.
%
% NOTES:
%   -> This symbolic MAPS helper is used in the evaluation of inversions in
%      NLBL model forecast run execution.

%% CHECK INPUTS
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});  
elseif ~is_column_cell_string_array(eqStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId); 
elseif ~is_column_cell_string_array(assignVarMnems)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% COMPUTE INCIDENCE MATRIX
incMat = compute_equations_incidence_matrix(eqStrs,assignVarMnems);

%% CHECK SUITABILITY OF INCIDENCE FOR THIS FUNCTION
% Throw an exception if the incidence matrix is not square (number of
% variables does not equal number of equations) or if the endogenous
% variable set does not represent an output assignment set - the diagaonal
% of the incidence matrix is not a vector of 1s.
[nRows,nCols] = size(incMat);
if nRows ~= nCols
    errId = ['MAPS:',mfilename,':EqVarNumberMismatch'];
    generate_and_throw_MAPS_exception(errId);    
end
assignVarIncEntries = diag(incMat);
if ~all(assignVarIncEntries)
    errId = ['MAPS:',mfilename,':BadAssignVarIncEntries'];
    generate_and_throw_MAPS_exception(errId);
end

%% SETUP INDICES TO REORDER EQUATIONS & VARIABLES FOR OUTPUT
% This vector is used below to keep track of the reordering of the 
% incidence matrix so that the equations and variables can be reordered for
% output.
reorderInds = (1:nRows)';

%% SETUP LOGICALS TO KEEP TRACK OF SIMULTANEOUS BLOCKS
% Setup a vector of logicals to keep track of rows that have been moved to
% the end (because they could not be swapped - simultaneous blocks found).
couldNotSwapRowLogicals = false(nRows,1);

%% INITIALSE ALGORITHM
% Initialse variables required for the algorithm which keep track of the
% incidence matrix, vector of indices for reorder, logicals for inability
% to swap and logicals for rows already swapped on a particular iteration 
% (to avoid infinite loops). Initialise the row to consider for swapping to
% 1.
incMatPrev = incMat;
reorderIndsPrev = reorderInds;
couldNotSwapRowLogicalsPrev = couldNotSwapRowLogicals;
rowSwapLogicals = false(nRows,1);
rowToSwap = 1;

%% DUFF-STYLE ALGORITHM
% The algorithm works in the following way: i) identify non-zero entries in
% the incidence matrix row being considered - rowToSwap; ii) find the
% entries that appear in columns after the row number - if any appear, that
% row needs to be swapped because it does not form part of a lower 
% triangular matrix; iii) if none are found, this row is in lower 
% traingular format and the next row is considered; iv) otherwise, the row
% is either swapped with another or moved to the end (for later 
% consideration) - the logic of that is left to a sub-function. v) set the
% objects that keep track of the previous iteration to their new values
% and move on to the next iteration. The algorithm is terminated if all of
% the rows have been successfully swapped so that the reordered incidence
% matrix is lower triangular or if a set of rows remain at the bottom that 
% cannot be reordered (simultaneous block).
while rowToSwap <= nRows
    entriesInRowToSwap = find(incMat(rowToSwap,:));
    candidateRowsToSwap = entriesInRowToSwap(entriesInRowToSwap>rowToSwap);
    nCandidateRowsToSwap = size(candidateRowsToSwap,2);
    if nCandidateRowsToSwap == 0
        rowToSwap = rowToSwap+1;
        rowSwapLogicals = false(nRows,1);
    else
        [incMat,reorderInds,couldNotSwapRowLogicals,rowSwapLogicals] = ...
            examine_incidence_matrix_and_swap_rows(incMatPrev,...
            reorderIndsPrev,couldNotSwapRowLogicalsPrev,...
            rowToSwap,candidateRowsToSwap,rowSwapLogicals,nRows);
        if all(couldNotSwapRowLogicals(rowToSwap:nRows))
            break
        end
        incMatPrev = incMat;
        reorderIndsPrev = reorderInds;
        couldNotSwapRowLogicalsPrev = couldNotSwapRowLogicals;
    end
end

%% REORDER EQUATIONS & VARIABLES
orderedEqStrs = eqStrs(reorderInds);
orderedAssignVarMnems = assignVarMnems(reorderInds);

%% HANDLE SIMULTANEITY
% If the algorithm above was terminated because a simultaneous block was 
% encountered, throw an exception detailing the equations that form part of
% the simultaneous block.
if rowToSwap <= nRows
    masterErrId = ['MAPS:',mfilename,':NonRecursiveEqSystem'];
    NonRecursiveE = generate_MAPS_exception(masterErrId);
    errId = [masterErrId,':Instance'];
    for iRow = rowToSwap:nRows
        NonRecursiveE = generate_MAPS_exception_and_add_as_cause(...
            NonRecursiveE,errId,orderedEqStrs(iRow));
    end
    throw(NonRecursiveE);
end

end

%% HELPER FUNCTION TO EXAMINE INCIDENCE MATRIX & SWAP ROWS
function [incMat,reorderInds,couldNotSwapRowLogicals,rowSwapLogicals] = ...
    examine_incidence_matrix_and_swap_rows(...
    incMatPrev,reorderIndsPrev,couldNotSwapRowLogicalsPrev,...
    rowToSwap,candidateRowsToSwap,rowSwapLogicals,nRows)
% This helper examines the incidence matrix and swaps rows.
% It asseses whether or not a row can be swapped and either swaps one or
% moves the row to the end.
%
% INPUTS:
%   -> incMatPrev: incidence matrix on the previous iteration
%   -> reorderIndsPrev: index numbers for reordering on the previous
%      iteration
%   -> couldNotSwapRowLogicalsPrev: logicals for rows that could not be
%      swapped on the previous iteration
%   -> rowToSwap: row number to be swapped
%   -> candidateRowsToSwap: possible rows to swap with
%   -> rowSwapLogicals: logical vector to indicate rows that have already
%      been swapped on this iteration
%   -> nRows: number of rows in the incidence matrix
%
% OUTPUTS:
%   -> incMat: updated incidence matrix
%   -> reorderInds: updated vector of reordering indices
%   -> couldNotSwapRowLogicals: updated vector of logicals for rows that
%      could not be swapped
%   -> rowSwapLogicals: updated vector of logicals for rows that have been
%      swapped
%
% CALLS:
%   -> swap_rows_in_incidence_matrix (sub-function)
%   -> move_row_to_end_in_incidence_matrix (sub-function)

%% DETERMINE KEY PROPERTIES OF CANDIDATE ROWS
% Determine if any of the candidate rows are simultaneous with respect to
% the base row; have already been moved to the end because they could not
% be swapped; have already been swapped on the current iteration.
rowSimultaenousLogicals = incMatPrev(candidateRowsToSwap,rowToSwap);
rowCouldNotBeSwappedLogicals = couldNotSwapRowLogicalsPrev(...
    candidateRowsToSwap);
rowAlreadySwappedLogicals = rowSwapLogicals(candidateRowsToSwap);

%% ELIMINATE CANDIDATE ROWS THAT DO NOT MEET THE CRITERIA
% Eliminate any of the candidate rows that do not meet the criteria set out
% above.
rowCannotBeSwappedLogicals = (rowSimultaenousLogicals|...
    rowCouldNotBeSwappedLogicals|rowAlreadySwappedLogicals);
rowsThatCanBeSwapped = candidateRowsToSwap(~rowCannotBeSwappedLogicals);

%% SWAP ROW OR MOVE TO THE END
% Count the remaining candidate rows. If there are none, the base row
% cannot be swapped and it is moved to the end. If there is one or more,
% choose the last one (which is guranteed to move the mnemonic assigned as
% output in that equation the biggest distance) and swap it with the base
% row.
nRowsThatCanBeSwapped = size(rowsThatCanBeSwapped,2);
if nRowsThatCanBeSwapped == 0
    [incMat,reorderInds,couldNotSwapRowLogicals] = ...
        move_row_to_end_in_incidence_matrix(incMatPrev,...
        reorderIndsPrev,couldNotSwapRowLogicalsPrev,rowToSwap,nRows);
    rowSwapLogicals = false(nRows,1);
else
    rowToSwapWith = rowsThatCanBeSwapped(nRowsThatCanBeSwapped);
    [incMat,reorderInds,couldNotSwapRowLogicals] = ...
        swap_rows_in_incidence_matrix(...
        incMatPrev,reorderIndsPrev,couldNotSwapRowLogicalsPrev,...
        rowToSwap,rowToSwapWith);
    rowSwapLogicals(rowToSwapWith) = true;
end

end

%% HELPER FUNCTION TO SWAP ROWS IN INCIDENCE MATRIX
function [incMat,reorderInds,couldNotSwapRowLogicals] = ...
    swap_rows_in_incidence_matrix(incMatPrev,reorderIndsPrev,...
    couldNotSwapRowLogicalsPrev,rowToSwap,rowToSwapWith)
% This helper swaps rows in the incidence matrix.
% It swaps the rows and associated columns (for the output assigment 
% variables) in the incidence matrix. It updates the vector of indices for
% reorder and the logicals for rows that could not be sapped accordingly.
%
% INPUTS:
%   -> incMatPrev: incidence matrix on the previous iteration
%   -> reorderIndsPrev: index numbers for reordering on the previous
%      iteration
%   -> couldNotSwapRowLogicalsPrev: logicals for rows that could not be
%      swapped on the previous iteration
%   -> rowToSwap: row number to be swapped
%   -> rowToSwapWith: number of the row to swap it with 
%
% OUTPUTS:
%   -> incMat: updated incidence matrix
%   -> reorderInds: updated vector of reordering indices
%   -> couldNotSwapRowLogicals: updated vector of logicals for rows that
%      could not be swapped
%
% CALLS:
%   -> none

%% SWAP ROWS
incMat = incMatPrev;
incMat(rowToSwap,:) = incMatPrev(rowToSwapWith,:);
incMat(rowToSwapWith,:) = incMatPrev(rowToSwap,:);

%% SWAP COLUMNS
% Note that the input incidence matrix from the previous iteration is reset
% to include the row swaps in the cell above.
incMatPrev = incMat;
incMat(:,rowToSwap) = incMatPrev(:,rowToSwapWith);
incMat(:,rowToSwapWith) = incMatPrev(:,rowToSwap);

%% UPDATE REORDER INDICES
reorderInds = reorderIndsPrev;
reorderInds(rowToSwap) = reorderIndsPrev(rowToSwapWith);
reorderInds(rowToSwapWith) = reorderIndsPrev(rowToSwap);

%% UPDATE LOGICALS
couldNotSwapRowLogicals = couldNotSwapRowLogicalsPrev;
couldNotSwapRowLogicals(rowToSwap) = false;
couldNotSwapRowLogicals(rowToSwapWith) = false;

end

%% HELPER FUNCTION TO MOVE ROW TO END IN INCIDENCE MATRIX
function [incMat,reorderInds,couldNotSwapRowLogicals] = ...
    move_row_to_end_in_incidence_matrix(incMatPrev,reorderIndsPrev,...
    couldNotSwapRowLogicalsPrev,rowToSwap,nRows)
% This helper moves a row in the incidence matrix to the end.
% If a row cannot be swapped, it is moved to become the last row in the
% incidence matrix. It updates the vector of indices for reorder and the 
% logicals for rows that could not be sapped accordingly.
%
% INPUTS:
%   -> incMatPrev: incidence matrix on the previous iteration
%   -> reorderIndsPrev: index numbers for reordering on the previous
%      iteration
%   -> couldNotSwapRowLogicalsPrev: logicals for rows that could not be
%      swapped on the previous iteration
%   -> rowToSwap: row number to be swapped
%   -> nRows: number of rows
%
% OUTPUTS:
%   -> incMat: updated incidence matrix
%   -> reorderInds: updated vector of reordering indices
%   -> couldNotSwapRowLogicals: updated vector of logicals for rows that
%      could not be swapped
%
% CALLS:
%   -> none

%% MOVE ROW TO END
incMat = incMatPrev;
incMat(rowToSwap:nRows-1,:) = incMatPrev(rowToSwap+1:nRows,:);
incMat(nRows,:) = incMatPrev(rowToSwap,:);

%% MOVE COLUMN TO END
% Note that the input incidence matrix from the previous iteration is reset
% to include the row swaps in the cell above.
incMatPrev = incMat;
incMat(:,rowToSwap:nRows-1) = incMatPrev(:,rowToSwap+1:nRows);
incMat(:,nRows) = incMatPrev(:,rowToSwap);

%% UPDATE REORDER INDICES
reorderInds = reorderIndsPrev;
reorderInds(rowToSwap:nRows-1) = reorderIndsPrev(rowToSwap+1:nRows);
reorderInds(nRows) = reorderIndsPrev(rowToSwap);

%% UPDATE LOGICALS
couldNotSwapRowLogicals = couldNotSwapRowLogicalsPrev;
couldNotSwapRowLogicals(rowToSwap:nRows-1) = ...
    couldNotSwapRowLogicalsPrev(rowToSwap+1:nRows);
couldNotSwapRowLogicals(nRows) = true;

end