function modelInds = lookup_model_index_numbers(modelStrs,strsToLookup)
% This helper returns the indices of the input strings in the model.
% It can be used to lookup the index numbers of variables, parameters, 
% steady states or equations in the model. 
%
% INPUTS:
%   -> modelStrs: cell string array of model metadata
%   -> strsToLookup: strings to lookup in the model object
%
% OUTPUTS:  
%   -> modelInds: indices of strsToLookup in the model
%
% DETAILS:  
%   -> This helper returns the index numbers of a set of strings in
%      the model.
%   -> The output is such that: modelStrs(modelInds) = strsToLookup
%           
% NOTES:    
%   -> This is a useful model utility for quickly looking up model indices.
%   -> See the content of the lookup function called below for further
%      details.
%           
% This version: 28/01/2013
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
end

%% COMPUTE MODEL INDICES
% Compute the indices of the strings in the model using the generic string
% array lookup function. The third, optional input flag is set to true
% meaning that the set of strings to lookup must be unique.
modelInds = lookup_index_numbers_in_string_array(...
    modelStrs,strsToLookup,true);

end