function eqsFunHandle = ...
    convert_equations_to_model_ordered_function_handle(...
    eqStrs,endogVarMnems,eqRhsArgs,funHandleArgNames)
% This helper converts a set of equations to executable function handles.
% It reorders the equations to be consistent with the model ordering for
% the endogenous variablaes in the equations. It then creates (vector 
% evaluable) function handles from the expressions on the right-hand-side 
% of the equations based on the argument list vectors and function handle
% (vector) argument names input.
%
% INPUTS:   
%   -> eqStrs: cell string array of equations
%   -> endogVarMnems: cell string array of endogenous variable mnemonics
%   -> eqRhsArgs: cell array of mnemonic string cell arrays
%   -> funHandleArgNames: string cell array of vector names for the 
%      function handle arguments
% 
% OUTPUTS:  
%   -> eqsFunHandle: function handle representation of the equations
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> reorder_equations
%   -> extract_RHS_expressions_from_equations
%   -> convert_expressions_to_function_handle
%
% DETAILS:  
%   -> This function can be used to convert string equations to executable 
%      function handles. 
%   -> The input equations must be of a form where they have only one
%      variable (an endogenous variable) on the left-hand-side and only
%      numerical expressions and exogenous variables on the
%      right-hand-side (i.e. the right-hand-sides of the equations must be
%      expressions for the endogenous variables on the left-hand-sides).
%   -> This function first reorders the equations so that the ordering of
%      the endogenous variables on the left-hand-side matches the ordering
%      in the mnemonics input (which could be from a model).
%   -> It then extracts the expressions that relate to these variables and
%      converts the result to vector evaluable function handles. See the
%      underlying functions for more details.
%
% NOTES:
%   -> This function is used in the creation of MAPS models. See <> for 
%      more information.
%   -> This function only checks the inputs that it uses directly. The 
%      other inputs are checked in the underlying functions to avoid
%      repetition.
%
% This version: 18/02/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 4
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
end

%% REORDER EQUATIONS
% Reorder equations so that their ordering with respect to their
% left-hand-side arguments is consistent with the mnemonics input.
eqReStrs = reorder_equations(eqStrs,endogVarMnems);

%% EXTRACT EXPRESSIONS
% Extract the expressions that match up to the left-hand-side mnemonics as
% the right-hand-sides to the equations.
exprStrs = extract_RHS_expressions_from_equations(eqReStrs);

%% CREATE FUNCTION HANDLE
% Create the function handle associated with the expressions using the
% right-hand-side arguments and vector argument names input.
eqsFunHandle = convert_expressions_to_function_handle(...
    exprStrs,eqRhsArgs,funHandleArgNames);

end