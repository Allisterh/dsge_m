function lagLengthInfo = ...
    find_var_lag_info(varMnems,uniqueTerms,uniqueTermsWithTimeSubs)
% This helper finds the lag length info for a set of string equations.
%
% INPUTS:
%   -> varMnems: cell string array of variable mnemonics
%   -> uniqueTerms: cell string array of the unique terms in a set of
%      equations
%   - uniqueTermsWithTimeSubs: cell string array of the unique terms in a 
%     set of equations, including their MAPS formatted time subscripts
%
% OUTPUTS:
%   -> lagLengthInfo: cell array list variable minimum and maximum lags
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%
%
% This version: 26/04/2011
% Author(s): Alex Haberis,

%% CHECK INPUTS
% Check that the number and type of inputs is as expected and required by
% this function.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(varMnems)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);     
elseif ~is_column_cell_string_array(uniqueTerms)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId); 
elseif ~is_column_cell_string_array(uniqueTermsWithTimeSubs)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId); 
end

%% FIND VARIABLE MAX LAG LENGTH
nVars = size(varMnems,1);
maxLagLength = cell(nVars,1);
minLagLength = cell(nVars,1);
for iVar = 1:nVars
    varInd = strmatch(varMnems{iVar},uniqueTerms,'exact');
    timeSubs = ...
        regexp(uniqueTermsWithTimeSubs(varInd),'(?<={t-)\d*(?=})','match');
    if ~isempty([timeSubs{:}])
        maxLagLength{iVar} = max(str2double([timeSubs{:}]));
        minLagLength{iVar} = min(str2double([timeSubs{:}]));
    else
        maxLagLength{iVar} = 0;
        minLagLength{iVar} = 0;
    end
end
lagLengthInfo = [varMnems,minLagLength,maxLagLength];
end