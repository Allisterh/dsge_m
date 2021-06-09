function [yLImnems,nonLagIdEqStrs,lagIdEqStrs,fullSysEqStrs] = ...
    create_first_order_symbolic_system(eqStrs,varMnems,...
    varMaxLagLengthValues)
% This module transforms a string equation system of lag order n into a
% string equation system of lag order 1 by defining appropriate lag
% identities.
%
% INPUTS:
%   -> eqStrs: A cell array of string equations of lag order n. 
%   -> varMnems: A cell array of variable mnemonics.
%   -> varMaxLagLengthValues: A vector of integers indicating the maximum
%      lag length of the variables in the model.
%
% OUTPUTS:
%   -> yLImnems: a cell array of mnemonics for the lag identity variables
%   -> nonLagIdEqStrs: cell array of non-lag identity equation strings
%   -> lagIdEqStrs: cell array of lag identity equation strings
%   -> fullSysEqStrs: cell array of lag and non-lag identity equation 
%      strings
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> split_equation_system_strings
%   -> create_lag_identities
%   -> reconstruct_equation
%   -> replace_time_subscripts_in_equations
%
% DETAILS:
%   -> This module replaces terms in a system of string equations with lags
%      greater than 1 with a lag identity.
%   -> The convention for lag identities is as follows:
%
%         xL1{t} = x{t-1}
%         xL2{t} = x{t-2}
%         xLn{t} = x{t-n}
%
%   -> If a system has a lag order of n, lag identities going up to n-1 are
%      introduced.  This is in order to ensure the system remains
%      recursive.  In this case, the variable with a lag of n is replaced
%      in the string equations with a lag identity of order n-1 that is
%      itself lagged by one period. For instance the equation:
%
%           y{t} = alpha*x{t-3}
%
%      is replaced with the following system:
%
%           y{t}      = alpha*xL2{t-1}
%           xL1{t}    = x{t-1}
%           xL2{t}    = xL1{t-1}   
%
% This version: 06/06/2011
% Author(s): Alex Haberis

%% CHECK INPUTS
% Check that the number and type of inputs is as expected and required by
% this function.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(eqStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);     
elseif ~is_column_cell_string_array(varMnems)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId); 
elseif ~is_finite_real_numeric_column_vector(varMaxLagLengthValues)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId); 
end

%% SPLIT STRING EQUATIONS
% Split the string equations into their constituent parts.
[eqStrTerms,eqStrDelims,eqStrTimeSubs,eqStrTermsWithTimeSubs] = ...
        split_equation_system_strings(eqStrs);

%% CREATE STRING LAG IDENTITY DEFINITIONS
% Call helper to create necessary lag identities.
[yLImnems,lagIdEqStrs] = ...
    create_lag_identities(varMnems,varMaxLagLengthValues);

%% REPLACE TERMS WITH LAG GREATER THAN ONE WITH LAG IDENTITY
% Where variables with a lag greater than one appear on the RHS of the
% string equation system, replace with appropriate lag identity.
nEqStrs = size(eqStrs,1);
eqStrTermsWithTimeSubsOrderOne = eqStrTermsWithTimeSubs;
for iEqStr = 1:nEqStrs
    lags=regexp(eqStrTimeSubs{iEqStr},'(?<={t-)\d*(?=})','match')';
    nTerms = size(lags,1);
    for iTerm = 1:nTerms
        if ~isempty(lags{iTerm,1}) && str2double(lags{iTerm,1}{:}) > 1
            eqStrTermsWithTimeSubsOrderOne{1,iEqStr}{iTerm} = ...
                    [eqStrTerms{1,iEqStr}{iTerm},'L',...
                    num2str(str2double(lags{iTerm,1}{:})-1),'{t-1}'];
        end
    end  
end

%% RECONSTRUCT STRING EQUATIONS WITH LAG IDENTITIES
nonLagIdEqStrs = cell(nEqStrs,1);
for iEqStr = 1:nEqStrs
    nonLagIdEqStrs{iEqStr} = ...
        reconstruct_equation(eqStrTermsWithTimeSubsOrderOne{iEqStr},...
        eqStrDelims{iEqStr});
end
        
%% REPLACE TIME SUBSCRIPTS IN STRING EQUATIONS
nonLagIdEqStrs = replace_time_subscripts_in_equations(nonLagIdEqStrs);
lagIdEqStrs = replace_time_subscripts_in_equations(lagIdEqStrs);

%% AUGMENT STRING EQUATION SYSTEM WITH LAG IDENTITY DEFINITIONS
fullSysEqStrs = [nonLagIdEqStrs;lagIdEqStrs];

end