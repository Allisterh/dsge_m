function bannedMnems = get_banned_mnemonics_config
% This configuration defines banned mnemonics for MAPS models.
%
% INPUTS:   
%   -> none
%
% OUTPUTS:  
%   -> bannedMnems: a cell string array of banned mnemonics
%
% CALLS:
%   -> none
%
% DETAILS:
%   -> The configuration defines strings that are not allowed to be used as
%      mnemonics in MAPS models. 
%   -> The output is used in MAPS model file syntax checking functions.
%
% NOTES:
%   -> See XXXXXXXX for details of the rules and format of MAPS model 
%      files.
%
% This version: 21/04/2011
% Author(s): Matt Waldron

%% DEFINE BANNED MNEMONICS
% Define the strings that are not allowed to be used as mnemonics in MAPS
% models.
bannedMnems = {'t','pi','inf','NaN','nan','diff','log','ln','matrix',...
    'waldron','harrison','monti','haberis','theodoridis','gortz'};

end