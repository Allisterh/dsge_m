function bannedMnemContent = get_banned_mnemonic_content_config
% This configuration defines banned mnemonic content for MAPS models.
%
% INPUTS:   
%   -> none
%
% OUTPUTS:  
%   -> bannedMnemContent: a cell string array of banned mnemonic content
%
% CALLS:
%   -> none
%
% DETAILS:
%   -> The configuration defines strings that are not allowed to be used as
%      part of mnemonics in MAPS models. 
%   -> The output is used in MAPS model file syntax checking functions.
%
% NOTES:
%   -> See XXXXXXXX for details of the rules and format of MAPS model 
%      files.
%
% This version: 10/06/2011
% Author(s): Matt Waldron

%% DEFINE BANNED MNEMONIC CONTENT
% Define the strings that are not allowed to be used as part of mnemonics 
% in MAPS models.
bannedMnemContent = {'+','-','*','/','=','^','@','#','$','{','}',...
    '(',')','[',']',':','.',';','|','_b','_f','bradnum','elliot',...
    'monaghan','patel','waldron'};

end