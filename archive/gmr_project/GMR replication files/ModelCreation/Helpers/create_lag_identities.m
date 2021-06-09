function [yLImnems,lagIdEqStrs] = ...
    create_lag_identities(varMnems,varMaxLagLengthValues)
% This helper creates lag identity string equations for variables with lags
% greater than one in the system of string equations
%
% INPUTS:
%   -> varMnems: cell string array of variable mnemonics
%   -> varMaxLagLengthValues: vector of integers indicating the maximum lag
%      length of the variables in varMnems
%
% OUTPUTS:
%   -> yLImnems: cell string array of lag identity mnemonics
%   -> lagIdEqStrs: cell string array of lag identity equationd
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%
% DETAILS:
%   -> This helper implements the convention for lag identities specified
%      as follows:
%
%         xL1{t} = x{t-1}
%         xL2{t} = x{t-2}
%         xLn{t} = x{t-n}
%
%   -> Where a variable appears with a lag of n (though not necessarily any
%      other lags), n-1 lag identities are created to "bridge" to the
%      lagged terms. For instance, the equation:
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
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(varMnems)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId); 
elseif ~is_finite_real_numeric_column_vector(varMaxLagLengthValues)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId); 
end

%% CREATE LAG IDENTITY STRING EQUATIONS
% For variables with a lag length greater than 1, create lag identity
% variables and equation strings.
nVars = size(varMnems,1);
yLImnems = cell(nVars,1);
lagIdEqStrs = cell(nVars,1);
for iVar = 1:nVars
    if varMaxLagLengthValues(iVar)>1
        nLagIdentities = varMaxLagLengthValues(iVar)-1;
        yLImnemsStrs = cell(nLagIdentities,1);
        lagIdentityStrs = cell(nLagIdentities,1);
        yLImnemsStrs{1} = [varMnems{iVar},'L1'];
        lagIdentityStrs{1} = ...
            [yLImnemsStrs{1},'{t}=',varMnems{iVar},'{t-1}'];
        for iLagIdentity = 2:nLagIdentities
            yLImnemsStrs{iLagIdentity} = ...
                [varMnems{iVar},'L',num2str(iLagIdentity)];
            lagIdentityStrs{iLagIdentity} = ...
                [yLImnemsStrs{iLagIdentity},'{t}=',...
                yLImnemsStrs{iLagIdentity-1},'{t-1}'];
        end
        yLImnems{iVar,1} = yLImnemsStrs;
        lagIdEqStrs{iVar,1} = lagIdentityStrs;
    end
end
yLImnems = ...
    yLImnems(~cellfun(@isempty,yLImnems));
yLImnems = vertcat(yLImnems{:});
lagIdEqStrs = ...
    lagIdEqStrs(~cellfun(@isempty,lagIdEqStrs));
lagIdEqStrs = vertcat(lagIdEqStrs{:});
end