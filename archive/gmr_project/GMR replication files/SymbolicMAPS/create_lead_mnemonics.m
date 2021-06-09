function varMnemsLead = create_lead_mnemonics(varMnems)
% This helper creates a set of lead variable (string) mnemonics.
%
% INPUTS:
%   -> varMnems: column cell string array of mnemonics 
%
% OUTPUTS:  
%   -> varMnemsLead: column cell string array of mnemonics lead
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%   -> append_strings
%
% DETAILS:  
%   -> This helper creates a set of lead string mnemonics using the MAPS
%      '_f' appendage to menomincs to denote that they are leads. 
%   -> For example, if the mnemonic signifying output in the model is 'y'
%      then one period ahead expected output would be signified by 'y_f'.
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
% '_f' notation for lead mnemonics.
varMnemsLead = append_strings(varMnems,'_f');

end