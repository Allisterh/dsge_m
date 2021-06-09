function bannedNameContent = get_banned_name_content_config
% This configuration defines banned name content for MAPS models.
%
% INPUTS:   
%   -> none
%
% OUTPUTS:  
%   -> bannedNameContent: a cell string array of banned name content
%
% CALLS:
%   -> none
%
% DETAILS:
%   -> The configuration defines strings that are not allowed to be used as
%      part of names in MAPS models. 
%   -> The output is used in MAPS model file syntax checking functions.
%
% NOTES:
%   -> See XXXXXXXX for details of the rules and format of MAPS model 
%      files.
%
% This version: 21/04/2011
% Author(s): Matt Waldron

%% DEFINE BANNED NAME CONTENT
% Define the strings that are not allowed to be used as part of names 
% in MAPS models.
bannedNameContent = {'+','-','*','/','=','^','.','|',';','[',']',...
    'shock_based','waldron'};

end