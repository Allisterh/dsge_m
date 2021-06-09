function eqReStrs = reorder_equations(eqStrs,varMnems)
% This helper reorders equations so that their LHS args match a list.
% Specifically, it reorders equations (each of which must have only one 
% argument on the left hand side) so that the ordering of the 
% left-hand-side arguments in the reodered equations matches the ordering 
% in the list of variable mnemonics input.
%
% INPUTS:
%   -> eqStrs: cell string array of equations
%   -> varMnems: cell string array of ordered variable mnemonics
%
% OUTPUTS:
%   -> eqReStrs: cell string array of reordered equations
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> extract_LHS_expressions_from_equations
%   -> lookup_index_numbers_in_string_array
%
% DETAILS:  
%   -> This helper reorders a set of equations so that they are 
%      consistent with a particular ordering for the left-hand-side
%      arguments.
%   -> It can be used to ensure that the evaluation of a set of equations
%      returns a numeric vector in a particular order.
%   -> This function can be used to ensure that a set of equations returns 
%      the same ordering as variables in a model. As such, it is a useful 
%      utility function in the construction of MAPS model obejcts because 
%      it can be used to ensure that am expression ordering matches a 
%      mnemonic ordering.
%   -> For example, suppose a model contains a set of variable mnemonics:
%      {'y1';'y2'}. Suppose also that it contains expressions for those
%      variables {'y2=f2(x)';'y1=f1(x)'}. This function will reorder the
%      expressions so that they are {'y1=f1(x)';'y2=f2(x)'}.
%
% NOTES:
%   -> This helper is used in the creation of MAPS models. See <>
%      for details.
%   -> An underlying assumption in this function is that the equations are
%      arranged so that there is only one argument on the left hand side.
%      If that is not true, it will fail and return an exception. To
%      convert a set of equations so that they are arranged with only one
%      left-hand-side argument please use MAPS' rearrange equations
%      function.
%   -> In addition, this function assumes that the equations are valid and
%      in particular that they contain only one equal sign.

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(eqStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_column_cell_string_array(varMnems)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);  
end

%% EXTRACT THE EQUATION LHS ARGUMENTS
% Take the left-hand-side of the equations, which are the arguments of the
% equations.
eqLhsStrs = extract_LHS_expressions_from_equations(eqStrs);

%% FIND THE REORDERING INDICES
% Lookup the index of the model-ordered mnemonics in the equation-ordered
% mnemonics. Throw an exception if the lookup call fails.
try
    reorderInds = lookup_index_numbers_in_string_array(eqLhsStrs,varMnems);
catch IndexLookupE
    errId = ['MAPS:',mfilename,':BadEqSpec'];
    generate_MAPS_exception_add_cause_and_throw(IndexLookupE,errId);
end

%% REORDER THE EQUATIONS
% Reorder the equations so that the variables on the left-hand-side are in
% the same order as they appear in the model.
eqReStrs = eqStrs(reorderInds);

end