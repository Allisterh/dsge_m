function varSyms = create_symbolic_mnemonics(varMnems)
% This helper creates symbolic mnemonics from a set of string mnemonics.
% It uses the MATLAB symbolic toolbox to create a set of symbolic mnemonics
% consistent with the MAPS string mnemonics. It also creates symbolics for
% each individual menmonic in the set in the caller's workspace.
%
% INPUTS:
%   -> varMnems: column cell string array of mnemonics
%
% OUTPUTS:  
%   -> varSyms: column array of symbolic mnemonics
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_column_cell_string_array
%
% DETAILS:  
%   -> This helper creates a vector of symbolic mnemonics consistent with
%      the vector of string mnemonics passsed in. The symbolics are created
%      using the MATLAB symbolic toolbox.
%   -> It also creates individual symbolic mnemonics in the caller's
%      workspace. These can then be used to create symbolic equations
%      (which requires having the individual symbolic variables in the
%      workspace).
%   -> The output to this function can be used in conjunction with the
%      MATLAB symbolic toolbox and other symbolic model objects to compute
%      symbolic matrices like the structural matrices of the model
%      equations.
%
% NOTES:
%   -> This helper is used as part of the creation of MAPS linear models. 
%      See <> for details.
%
% This version: 13/05/2011
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

%% CREATE SYMBOLIC MNEMONICS
% Create a vector of symbolic mnemonics using the MATLAB symbolic toolbox
% command 'sym'. In addition, create a symbolic variable in the caller's 
% workspsce for each mnemonics - for more details see the MATLAB 
% documentation for 'assignin'.
nMnems = size(varMnems,1);
varSyms = sym(zeros(nMnems,1));
for iMnem = 1:nMnems
    varSyms(iMnem) = sym(varMnems{iMnem});
    assignin('caller',varMnems{iMnem},varSyms(iMnem));    
end

end