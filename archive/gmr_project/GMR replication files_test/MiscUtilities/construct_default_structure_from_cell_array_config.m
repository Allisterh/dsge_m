function DefaultOpts = ...
    construct_default_structure_from_cell_array_config(cellConfig)
% This helper constructs a default options structure from a config cell.
%
% INPUTS:
%   -> cellConfig: cell array of option & default pairs
%
% OUTPUTS:
%   -> DefaultOpts: structure of options with field names matching the 
%      option names and values describing the defaults
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%
% DETAILS:
%   -> This helper is used to convert a cell array of configuration
%      information for a set of options and their default values (the most
%      user friendly way of writing that information) into a structure with
%      the option names as the fields and defaults as the value (the most
%      convenient representation to operate on in the code).
%
% NOTES:
%   -> The input cell array of configuration information must be of the
%      correct format with strings (to be converted to fields) in the first
%      column and defaults values (which could be any data type) in the
%      second column.
%
% This version: 17/10/2012
% Author(s): Matt Waldron

%% CHECK INPUT
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_two_dimensional_cell_array(cellConfig) || ...
        size(cellConfig,2)~=2 || ...
        ~is_column_cell_string_array(cellConfig(:,1))
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% PACK CELL CONFIG INFO AS A STRUCTURE
nOptions = size(cellConfig,1);
for iOpt = 1:nOptions
    DefaultOpts.(cellConfig{iOpt,1}) = cellConfig{iOpt,2};
end

end