function eqSolvedStrs = solve_recursive_system_of_equations(...
    eqStrs,endogVarMnems)
% This helper solves a recursive system of equations.
% It eliminates as many of the endogenous variables on the right-hand-side
% of the equations as possible and then checks that the resulting system is
% comprised of analytical expressions alone.
%
% INPUTS:
%   -> eqStrs: cell string array of equations
%   -> endogVarMnems: cell string array of endogenous variable mnemonics
%
% OUTPUTS:
%   -> eqSolvedStrs: solved out system of equations
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> eliminate_endogenous_variables_from_equations
%   -> extract_RHS_expressions_from_equations
%   -> compute_equations_incidence_matrix
%   -> generate_MAPS_exception
%   -> generate_MAPS_exception_and_add_as_cause
%
% DETAILS:
%   -> This function calls a helper function to eliminate (by substitution) 
%      as many of the endogenous variables on the right-hand-sides of the 
%      equations as possible. 
%   -> It then checks that the resulting recursive system has been "solved 
%      out" (i.e. has no remaining endogenous variables on the 
%      right-hand-sides).
%
% NOTES:
%   -> This helper is used in the creation of MAPS models. See <>
%      for details.

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(eqStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_column_cell_string_array(endogVarMnems)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);  
end

%% ELIMINATE ENDOGENOUS VARIABLES FROM THE SYSTEM
% Call a symbolic MAPS helper function to eliminate as many endogenous
% variables from the system as possible.
eqSolvedStrs = eliminate_endogenous_variables_from_equations(...
    eqStrs,endogVarMnems);

%% CHECK THAT THE RESULTING SYSTEM IS RECURSIVE
% Check that the resulting system of equations is recursive by searching
% for endogenous variables on the right-hand-side using the incidence 
% matrix. If it is not recursive, throw an exception detailing the
% equations that form part of the endogenous block.
eqSolvedRhsStrs = extract_RHS_expressions_from_equations(eqSolvedStrs);
eqVarIncMat = compute_equations_incidence_matrix(...
    eqSolvedRhsStrs,endogVarMnems);
if any(any(eqVarIncMat))
    eqNonRecursiveInds = find(sum(eqVarIncMat,2));
    masterErrId = ['MAPS:',mfilename,':NonRecursiveEqSystem'];
    NonRecursiveE = generate_MAPS_exception(masterErrId);
    errId = [masterErrId,':Instance'];
    nSimultaneousEqs = size(eqNonRecursiveInds,1);
    for iEq = 1:nSimultaneousEqs
        NonRecursiveE = generate_MAPS_exception_and_add_as_cause(...
            NonRecursiveE,errId,eqStrs(eqNonRecursiveInds(iEq)));
    end
    throw(NonRecursiveE)
end

end