function varMnemsLagged = create_lag_mnemonics(varMnems)
% This helper creates a set of lagged variable (string) mnemonics.
%
% INPUTS:
%   -> varMnems: column cell string array of mnemonics 
%
% OUTPUTS:  
%   -> varMnemsLagged: column cell string array of mnemonics lagged
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> append_strings
%
% DETAILS:  
%   -> This helper creates a set of lagged string mnemonics using the MAPS
%      '_b' appendage to menomincs to denote that they are lags. 
%   -> For example, if the mnemonic signifying output in the model is 'y'
%      then lagged output would be signified by 'y_b'.
%
% NOTES:
%   -> This helper is used in the creation of MAPS linear models. See <>
%      for details.
%
% This version: 10/02/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(varMnems)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% CREATE THE LAGGED EQUIVALENTS TO THE INPUT MNEMONICS
% Call the append strings helper to append the mnemonics with the MAPS 
% '_b' notation for lagged mnemonics.
varMnemsLagged = append_strings(varMnems,'_b');

end