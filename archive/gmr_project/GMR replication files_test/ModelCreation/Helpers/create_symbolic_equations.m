function eqSyms = create_symbolic_equations(eqStrs)
% This helper creates symbolic equations from a set of string equations.
% It uses the MATLAB symbolic toolbox to create a set of symbolic equations
% consistent with the MAPS string equations. Note that this function 
% evaluates the symbolic equations in the caller's workspace.
%
% INPUTS:
%   -> eqStrs: column cell string array of equations
%
% OUTPUTS:  
%   -> eqSyms: column array of symbolic equations
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> convert_explicit_equations_to_implicit
%   -> generate_MAPS_exception_add_cause_and_throw
%
% DETAILS:  
%   -> This helper creates a vector of symbolic equations consistent with
%      the vector of string equations passsed in. The symbolics are created
%      using the MATLAB symbolic toolbox.
%   -> Note that it evaluates the symbolic equations in the caller's 
%      workspace, so a pre-requisite for this function to work is that the 
%      individual mnemonic strings that form terms in the equations have 
%      already been defined as symbolics in the caller's workspace - see 
%      create_symbolic_mnemonics. 
%   -> The output to this function can be used in conjunction with the
%      MATLAB symbolic toolbox and other symbolic model objects to compute
%      symbolic matrices like the structural matrices of the model
%      equations.
%
% NOTES:
%   -> This helper is used as part of the creation of MAPS linear models. 
%      See <> for details.
%   -> This helper assumes that the equations passed in are valid - it will
%      throw an exception if not but the exception wil not include precise
%      details of the invaldity (although it will say which equation was
%      responsible).
%
% This version: 10/02/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(eqStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% CONVERT THE EXPLCIT EQUATIONS TO IMPLICIT EQUATIONS
% Convert the explicit string equations (eg 'x = b*y') to implict equations 
% (eg 'b*y-x' = 0 - where the '= 0' is not stated, just assumed).
implicitEqStrs = convert_explicit_equations_to_implicit(eqStrs);

%% CREATE THE SYMBOLIC EQUATIONS
% Setup a vector of symbolic equations and loop through creating a symbolic
% equivalent for each of the implicit equation strings. Throw an exception
% if the symbolic creation of the equation fails for any of the string
% equations. Note that this is designed as a back-stop and will not detail
% the precise cause of the failure.
nEqs = size(implicitEqStrs,1);
eqSyms = sym(zeros(nEqs,1));
for iEq = 1:nEqs
    try
        eqSyms(iEq) = evalin('caller',implicitEqStrs{iEq});
    catch SymToolboxE
        errId = ['MAPS:',mfilename,':SymEqCreationFailure'];
        generate_MAPS_exception_add_cause_and_throw(...
            SymToolboxE,errId,eqStrs(iEq));
    end
end

end