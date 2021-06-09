function Model = update_model_metadata(Model,metadataFieldValuePairs)
% Updates metadata in a MAPS model, ensuring consistency across fields
% INPUTS:
%   -> Model: a MAPS model structure
%   -> metadataFieldValuePairs: two-column cell array of strings; first
%   column should contain the names of the metadataFields to be updated;
%   second should contain the corresponding strings to be written into the
%   metadataDescriptors.
% OUTPUTS:
%   -> Model: updated MAPS model structure
% DETAILS:
%   -> This function is required because some metadata values are stored in
%   two places in a MAPS model - once within
%   Model.Info.Metadata.metadataDescriptors, and once in named fields
%   within Model.Metadata.
%   -> The function checks that the field names specified all exist
%   within the model's metadatDescriptors, and raises an exception if not.
%   -> Given a valid collection of field names, the corresponding field
%   descriptors are updated, and the named fields in Model.Metadata are
%   also updated - we assume that they have the same name, with a 'model'
%   prefix.
% NOTES:
%   -> See the MAPS User Guide for more details on model structures and the
%   fields in which metadata are stored in these.

% This version: 25-Feb-2013
% Author(s): David Bradnum

%% INPUT CHECKING
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_two_dimensional_cell_string_array(metadataFieldValuePairs) ||...
        size(metadataFieldValuePairs,2) ~= 2
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% UNPACK INPUTS AND MODEL
newMetadataFields = metadataFieldValuePairs(:,1);
newMetadataValues = metadataFieldValuePairs(:,2);

[metadataFields,metadataDescriptors] =  unpack_model(Model,...
    {'metadataFields';'metadataDescriptors'});

%% CHECK THAT FIELD NAMES PROVIDED ARE VALID
[fieldnameIsValid,fieldnameIndices] = ...
    ismember(newMetadataFields,metadataFields);

if ~all(fieldnameIsValid)
    errorId = ['MAPS:',mfilename,':BadFieldNames'];
    generate_MAPS_exception_add_causes_and_throw(....
        errorId,newMetadataFields,~fieldnameIsValid);
end

%% UPDATE MODEL METADATA IN BOTH PLACES
% First pack the updated metadataDescriptors collection
metadataDescriptors(fieldnameIndices) = newMetadataValues;
Model = pack_model(Model,{'metadataDescriptors'},{metadataDescriptors});

% Now pack the individual fields - assume they have the same name, with a
% 'model' prefix.
packModelPrefixes = repmat({'model'},size(newMetadataFields));
packModelIdentifiers =  strcat(packModelPrefixes,newMetadataFields);

Model = pack_model(Model,packModelIdentifiers,newMetadataValues);
end