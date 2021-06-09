function implicitEqStrs = convert_explicit_equations_to_implicit(eqStrs)
% This helper converts a set of explicit string equations to implicit.
%
% INPUTS:   
%   -> eqStrs: cell string array of explicit equations
% 
% OUTPUTS:  
%   -> implicitEqStrs: cell string array of implicit equations
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> generate_MAPS_exception
%   -> generate_MAPS_exception_and_add_as_cause
%
% DETAILS:  
%   -> Explicit equations are those that look like the following: 
%      'y = f(x)'
%   -> The implicit equations output just represents those as:
%      'f(x)-y = 0' where the equality with 0 is assumed: 'f(x)-y'.
%
% NOTES:
%   -> This function operates on a cell string array of equations and will 
%      throw an error if a single equation string is passed as input.
%   -> The only testing included in this function is that the equation
%      contains one and only one equals sign (which is an obvious
%      requirement for the validity of the operation). It does no further
%      testing and therefore assumes that the equation is otherwise valid.
%
% This version: 10/02/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_column_cell_string_array(eqStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK EQUATION VALIDITY FOR THIS FUNCTION
% Check that the operation in this function is valid for the cell string
% array of equations input (ie that each equation contains one and only one
% equal sign).
posEquals = strfind(eqStrs,'=');
nEqualsPerEq = cellfun('size',posEquals,2);
indBadEqs = find(nEqualsPerEq~=1);
if ~isempty(indBadEqs)
    masterErrId = ['MAPS:',mfilename,':InvalidEqs'];
    InvalidEqsE = generate_MAPS_exception(masterErrId);
    errId = [masterErrId,':Instance'];
    nBadEqs = size(indBadEqs,1);
    for iBadEq = 1:nBadEqs
        InvalidEqsE = generate_MAPS_exception_and_add_as_cause(...
            InvalidEqsE,errId,eqStrs(indBadEqs(iBadEq)));
    end
    throw(InvalidEqsE);
end

%% CREATE IMPLICIT EQUATIONS
% Split the equation by the equal sign remove it and then subtract the
% left-hand-side from the right-hand-side.
[eqLhsStrs,eqRhsStrs] = strtok(eqStrs,'=');
eqRhsStrs = strrep(eqRhsStrs,'=','');
nEqs = size(eqStrs,1);
implicitEqStrs = strcat(strtrim(eqRhsStrs),...
    repmat({'-('},[nEqs 1]),strtrim(eqLhsStrs),repmat({')'},[nEqs 1]));

end