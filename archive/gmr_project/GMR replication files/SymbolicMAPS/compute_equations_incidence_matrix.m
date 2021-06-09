function incMat = compute_equations_incidence_matrix(...
    eqStrs,varMnems,takeAccountOfTimeSubs)
% This helper computes the incidence associated with a set of vars & eqs.
% The incidence matrix describes the presence or otherwise of the variables 
% in the equations.
%
% INPUTS:
%   -> eqStrs: string cell array of equations
%   -> varMnems: string cell array of variable mnemonics
%   -> takeAccountOfTimeSubs (optional): true or false
%
% OUTPUTS:  
%   -> incMat: incidence matrix of logicals
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> get_valid_mathematical_symbols_for_equations
%
% DETAILS:  
%   -> This function computes the incidence matrix associated with a set of 
%      variables and equations.
%   -> It will do that either taking the time subscripts into account or
%      not (optional 3rd input). The default tretament is to ignore time
%      subscripts.
%   -> It does this by operating on the string equations to split them into
%      their constituent parts and then by comparing those parts to the
%      list of variables input.
%   -> It returns an nEqs*nMnems matrix of logicals where, for example,
%      incMat(i,j) = true if variable j appears in equation i and false
%      otherwise.
%
% NOTES:
%   -> This function forms part of a set of functions that operate on
%      string representations of equations. See also 
%      check_equation_is_valid, rearrange_equation.
%   -> See <> for more details.
%
% This version: 15/02/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and type of inputs is as expected and required by
% this function.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(eqStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_column_cell_string_array(varMnems)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin > 2
    if ~islogical(takeAccountOfTimeSubs) || ...
            ~isscalar(takeAccountOfTimeSubs)
        errId = ['MAPS:',mfilename,':BadInput3'];
        generate_and_throw_MAPS_exception(errId);
    end
end

%% SETUP OPTIONS FOR EQUATION SPLIT
% Check for the optional input and set the default treatment (that time 
% subscripts be split out) if it does not exist.
if nargin < 3
    takeAccountOfTimeSubs = false;
end

%% SETUP OUTPUT
% Compute the number of equations and variables. Setup the incidence matrix
% as an nEqs*nVars logical zeros matrix.
nEqs = size(eqStrs,1);
nVars = size(varMnems,1);
incMat = false(nEqs,nVars);

%% DEFINE EQUATION DELIMITERS
% Get the set of valid mathematical operators from the configuration file.
% Augment them with the curly braces used to define time subscripts in MAPS
% code (under the assumption that the symbol 't' will not be used as part 
% of the mnemonics input).
validMathsSymbols = get_valid_mathematical_symbols_for_equations;
eqDelims = ['[',validMathsSymbols,']'];
if ~takeAccountOfTimeSubs
    eqDelims = ['{t?((+|-)\d+)?}|',eqDelims];
end

%% COMPUTE INCIDENCE
% Loop through the equations, splitting each into their constituent parts.
% For each split equation, loop through the variables to determine if they
% form part of that equation.
for iEq = 1:nEqs
    iEqTerms = strtrim(regexp(eqStrs{iEq},eqDelims,'split'));
    for iVar = 1:nVars
        incMat(iEq,iVar) = any(strcmp(varMnems{iVar},iEqTerms));
    end
end

end