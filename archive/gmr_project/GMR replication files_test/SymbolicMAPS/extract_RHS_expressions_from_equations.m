function eqRhsStrs = extract_RHS_expressions_from_equations(eqStrs)
% This helper extracts the right-hand-sides of equations as expressions.
% The resulting expressions can be evaluated as executable statements in
% MATLAB.
%
% INPUTS:
%   -> eqStrs: cell string array of equations
%
% OUTPUTS:
%   -> eqRhsStrs: cell string array of expressions from right-hand-sides of
%      equations
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> extract_expressions_from_equations
%
% DETAILS:  
%   -> This helper extracts the right-hand-sides of a set of equations as
%      executable expressions.
%   -> For example, suppose the cell string array of equations input is the 
%      following: {'y1=x1';'y2=x2'}. The expressions extracted as the right
%      -hand-sides of these equations are: {'x1';'x2'}. These expressions 
%      can be directly evaluated numerically if x1 and x2 are variables in
%      the MATLAB workspace.
%
% NOTES:
%   -> This helper is used in the creation of MAPS models. See <>
%      for details.
%   -> This function leaves error checking of the input to the function it 
%      calls.

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)}); 
end

%% EXTRACT THE RHS OF THE EQUATIONS AS EXPRESSIONS USING THE HELPER
% Call the equation splitter helper, returning just the right-hand-sides of
% the equations.
[~,eqRhsStrs] = extract_expressions_from_equations(eqStrs);

end