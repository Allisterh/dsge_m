function eqStr = reconstruct_equation(eqStrTerms,eqStrDelims,eqStrTimeSubs)
% This helper splits an equation string by the input delimiters.
%
% INPUTS:
%   -> eqStrTerms: cell string array of split terms from the equation
%   -> eqStrDelims: cell string array of delimiters
%   -> eqStrTimeSubs: cell string array of time subscripts
%
% OUTPUTS:
%   -> eqStr: equation string
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%
% DETAILS:
%   -> This helper reconstructs a split string equation.
%   -> It recombines any time subscripts with any respective terms (eg 
%      {'gdp'} and '{t}' becomes {'gdp{t}'} and then recombines the 
%      equation delimiters with those terms (eg {'gdp{t}' '' ''} and 
%      {'=' '0'} becomes 'gdp{t} = 0').
%   -> The time subscripts are an optional input. If they are not input
%      then this function just recombines the terms with the delimiters.
%
% NOTES:
%   -> This helper is used in the creation of MAPS models. See <>
%      for details.
%   -> The function split_equation splits an equation i.e. reverses the 
%      operation in this equation).

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected. And check that
% the dimensions of the inputs are consistent with each other and the
% operations in this function.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_row_cell_string_array(eqStrTerms)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_row_cell_string_array(eqStrDelims) && ...
        size(eqStrDelims,1)~=0 
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif size(eqStrDelims,2) ~= size(eqStrTerms,2)-1
    errId = ['MAPS:',mfilename,':InconsistentTermsDelimsSizes'];
    generate_and_throw_MAPS_exception(errId);    
elseif nargin > 2
    if ~is_row_cell_string_array(eqStrTimeSubs)
        errId = ['MAPS:',mfilename,':BadInput3'];
        generate_and_throw_MAPS_exception(errId);
    elseif size(eqStrTimeSubs,2) ~= size(eqStrTerms,2)
        errId = ['MAPS:',mfilename,':InconsistentTermsTimeSubsSizes'];
        generate_and_throw_MAPS_exception(errId);
    end
end

%% RECOMBINE ANY TIME SUBSCRIPTS WITH TERMS
% If any time subscripts were passed in as input, concatenate them with the
% terms passed in.
if nargin > 2
    eqStrTerms = strcat(eqStrTerms,eqStrTimeSubs);
end

%% PREPARE EQUATION STRING
% Add the delimiters from the split equation under the split terms. This
% orders the first term, followed by the first delimiter, followed by
% the second split term etc (i.e. it reverses the splitting logic).
eqStrTermsAndDelims = [eqStrTerms;eqStrDelims {''}];

%% PUT TERMS BACK TOGETHER
% Put the cell terms togther by unpacking the cell array and collecting the
% terms in a single string array.
eqStr = [eqStrTermsAndDelims{:}];

end