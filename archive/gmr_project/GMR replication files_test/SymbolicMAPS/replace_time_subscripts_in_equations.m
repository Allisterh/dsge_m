function eqStrsUpdated = replace_time_subscripts_in_equations(eqStrs)
% This helper replaces time subscripts in MAPS equations with equivalents.
% It removes the curly brace {t}, {t-1}, {t+1} subscripts and replaces them
% with '', '_b', '_f' as part of the conversion of MAPS model file
% equations to symbolic, executable equivalents.
%
% INPUTS:
%   -> eqStrs: column cell string array of equations 
%
% OUTPUTS:  
%   -> eqStrsUpdated: column cell string array of updated equations
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%
% DETAILS:  
%   -> This helper removes the time subscript {t} etc MAPS model file 
%      notation and replaces it with an executable equivalent.
%   -> Specifically, it replaces the time {t}, {t-1} and {t+1} mnemonic 
%      subscripts as '', '_b' and '_f' respecively. The reason for doing
%      that is that {t} is not an executable mathematical statement in
%      MATLAB - it in fact attempts to create a cell array with the 
%      variable t from the workspace in it.
%   -> For example, a Phillips curve equation pinf{t} = c1*pinf{t+1}+
%      c2*pinf{t-1}...becomes pinf = c1*pinf_f+pinf_b. See also
%      create_lead_mnemonics and create_lag_mnemonics which can be used in
%      conjunction with this function.
%
% NOTES:
%   -> This helper is used in the creation of MAPS models. See <>
%      for details.
%   -> Note that it assumes that there do not exist {t+2} or {t-2} terms
%      etc. So, either these cannot be part of the model or lead and lag
%      identities must have been created.
%
% This version: 10/02/2011
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

%% REMOVE CONTEMPORANEOUS TIME SUBSCRIPTS, REPLACE LAGS AND LEADS
% Use the string replace command to replace the time subscripts. Note that 
% it is assumed here that '{t}', '{t-1}' and '{t+1}' are not themselves
% terms in the equations. (This is consistent with MAPS model file syntax
% rules).
eqStrsUpdated = eqStrs;
eqStrsUpdated = strrep(eqStrsUpdated,'{t}','');
eqStrsUpdated = strrep(eqStrsUpdated,'{t-1}','_b');
eqStrsUpdated = strrep(eqStrsUpdated,'{t+1}','_f');

end