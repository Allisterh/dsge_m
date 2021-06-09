function funHandleMat = convert_expressions_to_function_handle(...
    exprStrs,exprArgs,funHandleArgNames)
% This helper converts a string array of expressions to function handles.
% It converts symbolic expressions (equivalent to symbolic matrices) 
% represented in cell string arrays to an executable anonymous function
% handle for quick evaluation at run-time in MATLAB.
%
% INPUTS:   
%   -> exprStrs: cell string array of expressions
%   -> exprArgs: cell array of mnemonic string cell arrays
%   -> funHandleArgNames: string cell array of vector names for the 
%      function handle arguments
% 
% OUTPUTS:  
%   -> funHandleMat: function handle representation of the string
%      expressions
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> create_function_handle_from_matrix_string
%
% DETAILS:  
%   -> This function can be used to convert symbolic information
%      represented in a cell array of expression strings to an executable 
%      anonymous function handle. 
%   -> The input expressions are a column cell string array whose elements 
%      are executable expressions: eg exprStrs = {'a' 'b/c';'alpha' 'beta'}
%   -> The symbolic information represented in the cell arrays is as in the
%      underlying equations used to generate them. For example, a
%      particular element in the cell array may contain 'alpha*beta'.
%   -> The families that these symbols belong to are described in 
%      exprArgs (eg in the example above the families could be the first 
%      three letters of the English alphabet and the first two letters of 
%      the Greek alphabet, so exprArgs = {{'a';'b';'c'} {'alpha';'beta'}}
%   -> The names for these families are given by funHandleArgNames
%      (eg funHandleArgNames = {'engAlphabet' 'greAlphabet'})
%   -> The resulting function handle can be evaluated with numeric vectors;
%      one for each of the families (eg numMat = funHandleMat(engAlphabet,
%      greAlphabet); if engAlphabet = [1;2;3] & greAlphabet = [4;5] then
%      numMat = [1 2/3;4 5]). This is equivalent to setting each of the
%      symbols to a numeric value in the workspace and then evaluating the
%      original cell string array of expressions one element at a time 
%      (i.e. numMat = zeros(2,2); 
%            numMat(1,1) = eval(exprStrs{1,1});
%            numMat(2,1) = eval(exprStrs{2,1}); 
%            numMat(2,2) = eval(exprStrs{2,2});)
%
% NOTES:
%   -> This function is similar to another function called:
%      convert_symbolic_matrix_to_function_handle, which converts matrices
%      of expressions (equivalent to the cell string array input here) 
%      represented in the MATLAB symbolic toolbox to function handles in an 
%      almost identical way.
%   -> Where possible, this function should be used in preference to the
%      symbolic function equivalent described above because working with 
%      strings is much more performant than working with the symbolic 
%      toolbox.
%   -> This function is useful in the creation of linear model symbolics.
%      See <> for information about the format & construction of MAPS
%      linear models.
%   -> This function only checks the inputs that it uses directly. The 
%      other inputs are checked in the function handle creater called.
%      This avoids checking repetition.
%
% This version: 14/02/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)})
elseif ~is_two_dimensional_cell_string_array(exprStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% CREATE THE MATRIX STRING BLOB
% Create comma and colon spearators to separate the terms in the cell
% string array of expressions in the string. Combine them with the 
% expressions input and flatten the result into a single string with 
% matrix delimiter square brackets either side. 
[nRows,nCols] = size(exprStrs);
charMatDelims = repmat([repmat({','},[1 nCols-1]) {';'}],[nRows 1]);
charMatDelims{nRows,nCols} = '';
exprStrsTr = exprStrs';
charMatDelimsTr = charMatDelims';
charMatTerms = [exprStrsTr(:)';charMatDelimsTr(:)'];
charMat = ['[',charMatTerms{:},']'];

%% CREATE FUNCTION HANDLE
% Call the helper function that creates a vector evluable function handle
% from a string blob representation of a matrix.
funHandleMat = create_function_handle_from_matrix_string(...
    charMat,exprArgs,funHandleArgNames);

end