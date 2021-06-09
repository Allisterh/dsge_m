function [eqStrTerms,eqStrDelims,eqStrTimeSubs,eqStrTermsWithTimeSubs] = ...
        split_equation_system_strings(eqStrs)
% This helper splits an equation string system into is constituent parts.
% It performs a loop, calling split_equation for each equation in the
% system.
%
% INPUTS:
%   -> eqStr: equation string system
%   -> additionalDelims (optional): character array of additional 
%      delimiters to split by
%
% OUTPUTS:
%   -> eqStrTerms: cell array of cell string arrays of split terms from the 
%      equations
%   -> eqStrDelims: cell array of cell string arrays of delimiters found
%   -> eqStrTimeSubs: cell array of cell string array of time subscripts 
%      for the terms
%   -> eqStrTermsWithTimeSubs: cell array of cell string arrays of terms 
%      combined with their time subscripts for the terms
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> split_equation 
%
% DETAILS:
%   -> For details of how equations are split, refer to split_equation.
%
% NOTES:
%   -> This helper is used in the creation of MAPS models. See <>
%      for details.
%
% This version: 06/06/2011
% Author(s): Alex Haberis

%% CHECK INPUTS
% Check that the number and type of inputs is as expected and required by
% this function.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(eqStrs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);  
end

%% SPLIT STRING EQUATIONS
% Call split_equation for each equation in the system.
nEqStrs = size(eqStrs,1);
eqStrTerms = cell(1,nEqStrs);
eqStrDelims = cell(1,nEqStrs);
eqStrTimeSubs = cell(1,nEqStrs);
eqStrTermsWithTimeSubs = cell(1,nEqStrs);
for iEqStr = 1:nEqStrs 
    [eqStrTerms{1,iEqStr},eqStrDelims{1,iEqStr},...
        eqStrTimeSubs{1,iEqStr}] = split_equation(eqStrs{iEqStr});
    eqStrTermsWithTimeSubs{1,iEqStr} = ...
        strcat(eqStrTerms{iEqStr},eqStrTimeSubs{iEqStr});
end
end