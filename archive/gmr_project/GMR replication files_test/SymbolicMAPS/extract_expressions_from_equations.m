function [eqLhsStrs,eqRhsStrs] = extract_expressions_from_equations(eqStrs)
% This helper extracts equation expressions either side of the equal sign.
% The resulting expressions can be evaluated as executable statements in
% MATLAB.
%
% INPUTS:
%   -> eqStrs: string equation or cell string array of equations
%
% OUTPUTS:
%   -> eqLhsStrs: expression as or cell string array of expressions from 
%      the equation LHS
%   -> eqRhsStrs: expression as or cell string array of expressions from 
%      the equation RHS
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%
% DETAILS:  
%   -> This helper extracts the left-hand-sides and right-hand-sides of a 
%      an equation or set of equations as executable expressions.
%   -> For example, suppose a cell string array of equations input is the 
%      following: {'y1=x1';'y2=x2'}. The expressions extracted as the left-
%      hand-sides of these equations are {'y1';'y2'} and the right-hand-
%      sides are: {'x1';'x2'}. These expressions can be directly evaluated 
%      numerically if y1, y2, x1 and x2 are variables in the MATLAB 
%      workspace.
%
% NOTES:
%   -> This helper is used in the creation of MAPS models. See <>
%      for details.
%   -> This function assumes that the equations are valid and in particular
%      that they contain only one equal sign.

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(eqStrs) && ~ischar(eqStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);   
end

%% SPLIT THE EQUATION
% Tokenise the equation by the equal sign.
[eqLhsStrs,eqRhsStrs] = strtok(eqStrs,'=');

%% TRIM THE EXPRESSIONS
% Remove the equal sign from the right-hand-side and trim the results for
% output.
eqLhsStrs = strtrim(eqLhsStrs);
eqRhsStrs = strtrim(strrep(eqRhsStrs,'=',''));

end