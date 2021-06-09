function isForwardLooking = are_equations_forward_looking(eqStrs)
% This helper works out whether a system of equations is forward looking.
%
% INPUTS:
%   -> eqStrs: a column cell sring array equation system
%
% OUTPUTS:  
%   -> isForwardLooking: true if system is forward looking, false otherwise
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%
% DETAILS:  
%   -> This helper examines a system of equations represented as strings in
%      a column cell string array to determine whether or not the system is
%      forward looking.
%   -> It searches for any {t+*} terms in any of the equations (using the 
%      MAPS notation for time subscripts, {t}, {t-1} etc). If there are any
%      the model is forward looking, if not it is backward looking. 
%
% NOTES:
%   -> This helper is used in the creation of MAPS linear models to 
%      determine their class.
%   -> This function assumes that the strings passed in are equation 
%      strings and that they represent valid equations.
%
% This version: 14/02/2011
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

%% COLLECT FORWARD-LOOKING TERMS
% Search the equation strings for any forward looking terms {t+*} using the
% MATLAB regexp function - see documentation for further details. This
% outputs an nEqs*1 cell array with each element being empty if no
% forward-looking terms were found or containing a cell array with all
% instances of the terms found.
forwardLookingTerms = regexp(eqStrs,'({t\+.*?})','match');

%% DETERMINE IF MODEL IS FORWARD LOOKING
% Use the output from above to determine if the model is forward looking or
% not based on whether there were any non-empty cells resulting from the
% search.
isForwardLooking = any(~cellfun(@isempty,forwardLookingTerms));

end