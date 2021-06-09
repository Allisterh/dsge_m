function modelInds = unpack_model_metadata_and_lookup_index_numbers(...
    Model,modelObjId,strsToLookup)
% This helper returns the indices of the input strings in the model.
% It can be used to lookup the index numbers of variables, parameters, 
% steady states or equations in the model. 
%
% INPUTS:   
%   -> Model: MAPS model structure
%   -> modelObjId: string id for model object to lookup indexes against
%   -> strsToLookup: strings to lookup in the model object
%
% OUTPUTS:  
%   -> modelInds: indices of strsToLookup in the model
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> unpack_model
%   -> lookup_model_index_numbers
%
% DETAILS:  
%   -> This helper unpacks the specified model metadata and returns the 
%      index numbers of a set of strings in that metadata.
%   -> The output is such that: modelStrs(modelInds) = strsToLookup
%   -> See the model index lookup function called for more details.
%           
% NOTES:    
%   -> This is a useful model itility for quickly looking up model indices.
%   -> Note that the lookup is case sensitive.
%   -> If any of the strings to lookup do not form part of the model 
%      component, then the generic index lookup function will throw an
%      exception.
%           
% This version: 17/02/2011
% Author(s): Matt Waldron

%% CHECK THAT THE INPUTS ARE VALID
% Check that the number and shape of the inputs is as expected.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
elseif ~ischar(modelObjId)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif ~ischar(strsToLookup) && (~iscellstr(strsToLookup)||...
        ndims(strsToLookup)~=2||size(strsToLookup,2)~=1)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
end

%% UNPACK MODEL STRINGS
% Unpack the model strings associated with the input model object
% identifier. Throw an exception if the unpack call fails.
try
    modelStrs = unpack_model(Model,{modelObjId});
catch UnpackModelE
    errId = ['MAPS:',mfilename,':UnpackMetadataFailure'];
    generate_MAPS_exception_add_cause_and_throw(errId,UnpackModelE);
end

%% COMPUTE MODEL INDICES
% Compute the indices of the strings in the model using the generic string
% array lookup function.
modelInds = lookup_model_index_numbers(modelStrs,strsToLookup);

end