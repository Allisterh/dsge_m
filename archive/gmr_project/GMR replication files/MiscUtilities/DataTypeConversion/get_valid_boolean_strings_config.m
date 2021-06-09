function [validTrueStrings,validFalseStrings] = ...
    get_valid_boolean_strings_config
% This config lists all valid MAPS string representations of logicals.
%
% INPUTS:
%   -> none
%
% OUTPUTS:
%   -> validTrueStrings: valid "true" string representations
%   -> validFalseStrings: valid "false" string representations
%
% CALLS:
%   -> none
%
% DETAILS:  
%   -> The outputa are two column cell string arrays: one detailing valid
%      string representations of the MATLAB logical true and one detailing
%      valid string representations of the MATLAB logical false.
%   -> This configuration is used in conjunction with the MAPS utility
%      function called:
%      "convert_column_cell_string_array_to_boolean_equivalent".
%
% NOTES:
%   -> This configuration is useful for the translation of text information
%      that lives outside of MATLAB and MAPS which users of MAPS may 
%      provide to indicate a logical (eg in estimation info files).
%
% This version: 17/10/2012
% Author(s): Matt Waldron

%% SET OUT CONFIGURATION
validTrueStrings  = {'yes';'on' ;'1';'true';'oui';'ja';'tak';'si'};
validFalseStrings = {'no' ;'off';'0';'false';'non';'nein';'nie'};

end