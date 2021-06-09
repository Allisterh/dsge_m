function funHandleMat = create_function_handle_from_matrix_string(...
    charMat,charMatArgs,funHandleArgNames)
% This utility function converts a matrix string blob to a function handle.
% Specifically, it converts a string blob representation of a matrix (with 
% individual symbolic components) to a function handle that can be 
% evaluated using numeric vector(s).
%
% INPUTS:
%   -> charMat: string blob matrix
%   -> charMatArgs: cell array of mnemonic string cell arrays
%   -> funHandleArgNames: string cell array of vector names for the
%      function handle arguments
%
% OUTPUTS:
%   -> funHandleMat: function handle representation of the symbolic matrix
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_row_cell_array
%   -> is_column_cell_string_array
%   -> create_comma_separated_list
%   -> get_valid_mathematical_symbols_for_equations
%
% DETAILS:
%   -> This helper is used in the creation of function handles from both 
%      MATLAB symbolic matrices and from cell arrays of string expressions.
%   -> The input string blob is a matrix whose elements are made up of
%      symbols and functions of symbols (eg charMat = '[a b/c;alpha beta]')
%   -> The families that these symbols belong to are described in
%      charMatArgs (eg in the example above the families could be the first
%      three letters of the English alphabet and the first two letters of
%      the Greek alphabet, charMatArgs = {{'a';'b';'c'} {'alpha';'beta'}}
%   -> The names for these families are given by funHandleArgNames
%      (eg funHandleArgNames = {'engAlphabet' 'greAlphabet'})
%   -> The resulting function handle can be evaluated with numeric vectors;
%      one for each of the families (eg numMat = funHandleMat(engAlphabet,
%      greAlphabet); if engAlphabet = [1;2;3] & greAlphabet = [4;5] then
%      numMat = [1 2/3; 4 5]). This is equivalent to setting each of the
%      symbols to a numeric value in the workspace and then evaluating the
%      string blob.
%
% NOTES:
%   -> This function is useful in the creation of linear model symbolics.
%      See <> for information about the format & construction of MAPS
%      linear models.
%
% This version: 10/02/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_expection(errId,{num2str(nargin)});
elseif ~ischar(charMat)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_expection(errId);
elseif ~is_row_cell_array(charMatArgs) || ...
        ~all(cellfun(@is_column_cell_string_array,charMatArgs))
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_expection(errId);
elseif ~is_row_cell_string_array(funHandleArgNames)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_expection(errId);
end

%% CHECK CONSISTENCY OF ARGUMENT INPUTS
% Determine the number of families of symbolics and check that the number
% of function handle argument names given is consistent.
nArgs = size(charMatArgs,2);
if size(funHandleArgNames,2) ~= nArgs
    errId = ['MAPS:',mfilename,':InconsistentNargs'];
    generate_and_throw_MAPS_expection(errId);
end

%% CHECK VALIDITY OF FUNCTION HANDLE NAMES
% Check that the names for the function handle arguments are valid in that 
% they only contain alpha-numeric characters.
if any(cellfun('size',regexp(funHandleArgNames,'\<\w+\>','match'),2)-1)
    errId = ['MAPS:',mfilename,':InvalidFunHandleArgNames'];
    generate_and_throw_MAPS_exception(errId);
end

%% CREATE FUNCTION HANDLE DEFINITION STRING
% Construct the function handle definition string using the function handle
% definition @ and the argument name list (eg '@(in1,in2)').
funHandleArgsList = create_comma_separated_list(funHandleArgNames);
funHandleDefStr = ['@(',funHandleArgsList,')'];

%% CREATE FUNCTION HANDLE ARGUMENTS
% Create the vector of function handle arguments corresponding to the
% symbolic matrix argument vectors. For example, if the symbolic matrix is
% [a b], the symbols a and b form part of a single vector in1 = {'a';'b'},
% then the corresponding vector for the function handle (assuming in this
% example that the function handle name is also given as 'in1'), then the
% string vector created is {'in1(1)';'in1(2)'}.
funHandleArgs = cell(1,nArgs);
for iArg = 1:nArgs
    niArgTerms = size(charMatArgs{iArg},1);
    funHandleArgs{iArg} = strcat(...
        repmat(funHandleArgNames(iArg),[niArgTerms 1]),...
        repmat({'('},[niArgTerms 1]),...
        strtrim(cellstr(num2str((1:niArgTerms)'))),...
        repmat({')'},[niArgTerms 1]));
end

%% DEFINE EQUATION DELIMITERS
% Define the equation delimiter symbols with which to split the symbolic
% terms in the matrix up. These include all valid maths symbols for MAPS
% equations (as defined in the configuration), brackets which delimit the 
% matrix, the comma symbol which separate elements and the semi-colon which 
% separates rows. 
validMathsSymbols = get_valid_mathematical_symbols_for_equations;
eqDelims = ['[',validMathsSymbols,'[],;]'];

%% SPLIT STRING MATRIX USING DELIMITERS
% Split the string matrix blob using the equation delimiters, then trim the 
% split terms.
[charMatDelims,charMatSplit] = regexp(charMat,eqDelims,'match','split');
charMatSplit = strtrim(charMatSplit);

%% REPLACE MATRIX ARGS WITH NEW FUN HANDLE ARGS
% Replace all symbols found in the split string from above with the
% corresponding function handle argument equivalent (eg all instance of 'a'
% are replaced with 'in(1)' etc).
for iArg = 1:nArgs
    niArgTerms = size(charMatArgs{iArg},1);
    for iiTerm = 1:niArgTerms
        iiTermLogicals = strcmp(charMatArgs{iArg}{iiTerm},charMatSplit);
        charMatSplit(iiTermLogicals) = funHandleArgs{iArg}(iiTerm);
    end
end

%% REBUILD STRING BLOB MATRIX
% Rebuild the string by recombining it with the equation delimiters.
charMatRebuiltTerms = [charMatSplit;charMatDelims {''}];
charMatRebuilt = [charMatRebuiltTerms{:}];

%% DEFINE FUNCTION HANDLE
% Add the function handle definition string to the string matrix defined
% above and then convert the whole string to a function handle. Note that
% using the str2func function removes potential resolution errors when
% function handles are loaded in from mat files.
funHandleMatStr = [funHandleDefStr charMatRebuilt];
funHandleMat = str2func(funHandleMatStr);

end