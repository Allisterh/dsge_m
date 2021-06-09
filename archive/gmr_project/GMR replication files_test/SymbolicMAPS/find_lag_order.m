function [varLagLengthInfo,varMaxLagLengthValues,modelLagOrder] = ...
    find_lag_order(eqStrs,varMnems)
% This function finds lag order information for NLBL models.
%
% INPUTS:
%   -> eqStrs: cell string array of string equations
%   -> varMnems: cell string array of variable mnemonics
%
% OUTPUTS:
%   -> varLagLengthInfo: cell array list variable minimum and maximum lags
%   -> varMaxLagLengthValues: vector of variable max lag lengths
%   -> modelLagOrder: scalar indicating the model maximum lag order
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> stack_equation_terms_in_column_cell_array
%   -> find_unique_equation_terms
%
% NOTES:
%   -> See <> for a description of MAPS NLBL models.
%
% This version: 06/06/2011
% Author(s): Alex Haberis

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
end

%% SPLIT STRING EQUATIONS
[eqStrTerms,~,~,eqStrTermsWithTimeSubs] ...
    = split_equation_system_strings(eqStrs);

%% STACK TERMS FROM ALL EQUATIONS IN SINGLE COLUMN CELL ARRAY
allEqStrTerms = horzcat(eqStrTerms{:})';
allEqStrTermsWithTimeSubs = horzcat(eqStrTermsWithTimeSubs{:})';

%% FIND UNIQUE TERMS ACROSS ALL EQUATIONS
[uniqueEqStrTermsWithTimeSubs,uniqueEqStrTermsWithTimeSubsInd] = ...
    unique(allEqStrTermsWithTimeSubs);
uniqueEqStrTerms = allEqStrTerms(uniqueEqStrTermsWithTimeSubsInd);

%% FIND THE MAXIMUM LAG LENGTH FOR EACH VARIABLE IN THE SYSTEM
varLagLengthInfo = ...
    find_var_lag_info(varMnems,uniqueEqStrTerms,...
    uniqueEqStrTermsWithTimeSubs);
varMaxLagLengthValues = cell2mat(varLagLengthInfo(:,3));
modelLagOrder = max(varMaxLagLengthValues);

end
