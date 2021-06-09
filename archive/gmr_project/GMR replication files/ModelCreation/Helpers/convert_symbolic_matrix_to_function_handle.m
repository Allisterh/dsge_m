function funHandleMat = convert_symbolic_matrix_to_function_handle(...
    symMat,symMatArgs,funHandleArgNames)
% This utility function converts symbolic matrices to function handles.
% Specifically, it converts MATLAB symbolic matrices to function handles
% that can be evaluated using numeric vector(s).
%
% INPUTS:
%   -> symMat: symbolic matrix
%   -> symMatArgs: cell array of mnemonic string cell arrays
%   -> funHandleArgNames: string cell array of vector names for the
%      function handle arguments
%
% OUTPUTS:
%   -> funHandleMat: function handle representation of the symbolic matrix
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> create_function_handle_from_matrix_string
%
% DETAILS:
%   -> This helper is crucial in speeding up the evaluation of symbolic
%      matrices. The evaluation of the function handle equivalents to the
%      symbolic marices is substantially quicker (order of magnitude 10x or
%      better).
%   -> The input symbolic matrix is a matrix whose elements are made up of
%      symbols and functions of symbols (eg symMat = [a b/c;alpha beta])
%   -> The families that these symbols belong to are described in
%      symMatArgs (eg in the example above the families could be the first
%      three letters of the English alphabet and the first two letters of
%      the Greek alphabet, so symMatArgs = {{'a';'b';'c'} {'alpha';'beta'}}
%   -> The names for these families are given by funHandleArgNames
%      (eg funHandleArgNames = {'engAlphabet' 'greAlphabet'})
%   -> The resulting function handle can be evaluated with numeric vectors;
%      one for each of the families (eg numMat = funHandleMat(engAlphabet,
%      greAlphabet); if engAlphabet = [1;2;3] & greAlphabet = [4;5] then
%      numMat = [1 2/3; 4 5]). This is equivalent to setting each of the
%      symbols to a numeric value in the workspace and then evaluating the
%      original symbolic matrix input.
%
% NOTES:
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
    generate_and_throw_MAPS_expection(errId,{num2str(nargin)});
elseif ~strcmp(class(symMat),'sym') || ndims(symMat)~=2
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_expection(errId);
end

%% CONVERT SYMBOLIC MATRIX TO A SPLIT STRING BLOB
% Convert the symbolic matrix to a string blob using the 'char' command.
% Remove the word 'matrix' from the 1st of those split terms (which is
% created by the 'char' command). Note also that all instances of the term
% 'ln' are replaced by 'log' because 'ln' is recognised by the MuPad engine
% underlying the symbolic toolbox as the natural logarithm, but not by
% MATLAB itself. Both 'log' and 'ln' should not be allowed to be defined as
% mnemonics in MAPS model files.
charMat = char(symMat);
charMat = strrep(charMat,'matrix([','');
charMat = strrep(charMat,'])','');
charMat = strrep(charMat,'ln(','log(');
charMat = strrep(charMat,'], [',';');

%% CREATE FUNCTION HANDLE
% Call the helper function that creates a vector evluable function handle
% from a string blob representation of a matrix.
funHandleMat = create_function_handle_from_matrix_string(...
    charMat,symMatArgs,funHandleArgNames);

end