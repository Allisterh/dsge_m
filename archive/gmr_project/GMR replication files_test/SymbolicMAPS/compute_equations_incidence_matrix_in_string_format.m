function incStr = compute_equations_incidence_matrix_in_string_format(...
    eqStrs,varMnems,eqNames,takeAccountOfTimeSubs)
% This utility extracts index numbers from an incidence matrix.
% It computes the index numbers of the variables and equations
% corresponding to the non-zero (true) entries in the input incidence 
% matrix.
%
% INPUTS:   
%   -> eqStrs: string cell array of equations
%   -> varMnems: string cell array of variable mnemonics
%   -> eqNames: equation names
%   -> takeAccountOfTimeSubs (optional): true or false
%
% OUTPUTS:  
%   -> incStr: cell string array of equation names and variable mnemonics
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> compute_equations_incidence_matrix
%   -> extract_index_numbers_from_incidence_matrix
%
% DETAILS:  
%   -> This utility computes an incidence matrix of a set of equations with
%      respect to a set of variables in cell string array format.
%   -> For example, suppose the equation shave the following incidence
%      matrix with respect to the varaibles input: [0 0 1; 1 0 1; 0 1 0], 
%      where the equations are indexed by rows and the variables by 
%      columns. In that case, the output to this function would be a 4*2
%      cell array with {'eqName1' 'varName3';
%                       'eqName2' 'varName1';
%                       'eqName2' 'varName3';
%                       'eqName3' 'varName2'}
%           
% NOTES:    
%   -> See <> for a description of MAPS symbolic functionality.
%           
% This version: 09/08/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number of inputs is as expected. Check also that the
% equation names input is the correct shape. Checking of the other two
% inputs is left to the function called below.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(eqNames)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);   
end

%% COMPUTE INCIDENCE MATRIX
% Use the symbolic MAPS incidence matrix function to compute the logical
% matrix of incidence.
if nargin < 4
    takeAccountOfTimeSubs = false;
end
incMat = compute_equations_incidence_matrix(...
    eqStrs,varMnems,takeAccountOfTimeSubs);

%% COMPUTE INDEX NUMBERS OF VARIABLES & EQUATIONS
% Use another symbolic MAPS helper to compute the index numbers of the
% equations in the incidence matrix and the corresponding index of
% variables. For example, the example in the details above would yield
% index vectors of [1;2;2;3] and [3;1;3;2] for the equations & variables
% respectively.
[varInds,eqInds] = extract_index_numbers_from_incidence_matrix(incMat);

%% CONVERT INDEX NUMBERS TO STRING INFO
% Compute the cell string array incidence matrix by picking out the strings
% associated with the index numbers in the equation names and variable
% mnemonics respectively.
incStr = [eqNames(eqInds) varMnems(varInds)];

end