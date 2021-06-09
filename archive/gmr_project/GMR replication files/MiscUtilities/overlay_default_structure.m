function OverlaidStruct = overlay_default_structure(...
    OverlayStruct,DefaultStruct,validateDataTypes)
% This helper creates a structure from the merger of two input structures.
% More precisely, the structure created is the default structure input
% overlaid with the content of the other input structure provided that the
% field names of the overlay structure are a subset of those in the default
% structure (or an error will be thrown).
%
% INPUTS:
%   -> OverlayStruct: structure of information to overlay on the default
%   -> DefaultStruct: default or reference structure
%
% OUTPUTS:
%   -> OverlaidStruct: default structure overlaid with information from the
%      overlay strcuture input
%
% DETAILS:
%   -> This function can be used to merge the information in two structures
%      together, taking one of those structures as the base (or
%      default/reference structure).
%   -> The default structure is overlaid with information from the
%      "overlay" structure.
%   -> This function requires that the fields (field names) of the overlay
%      structure are a sub-set of those in the default structure and will 
%      throw an error if any of the field names in the overlay structure do
%      not appear as fields in the default structure.
%   -> Optionally, this function can also require that the data types of 
%      the fields of the overlay structure are the same as those 
%      corresponding in the default structure.
%
% NOTES:
%   -> This helper is useful in the management of options as part of the
%      MAPS Bayesian estimation toolkit.
%
% This version: 25/02/2013
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(OverlayStruct)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~isstruct(DefaultStruct)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin>2 && ~is_logical_scalar(validateDataTypes)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
end

%% HANDLE OPTIONAL INPUT DEFAULT
if nargin < 3
    validateDataTypes = false;
end

%% EXTRACT FIELD NAMES
overlayStructFields = fieldnames(OverlayStruct);
defaultStructFields = fieldnames(DefaultStruct);

%% CHECK OVERLAY STRUCTURE IS VALID
% Check that all of the field names in the overlay structure also appear in
% the default structure.
invalidFieldLogicals = ~ismember(overlayStructFields,defaultStructFields);
if any(invalidFieldLogicals)
    errId = ['MAPS:',mfilename,':InvalidFields'];
    generate_MAPS_exception_add_causes_and_throw(...
        errId,overlayStructFields,invalidFieldLogicals)
end

%% CHECK DATA TYPES IN OVERLAY STRUCTURE MATCH THE DEFAULT STRUCTURE
if validateDataTypes
    nOverlayFields = size(overlayStructFields,1);
    badFieldContentLogicals = false(nOverlayFields,1);
    for iField = 1:nOverlayFields
        iFieldName = overlayStructFields{iField};
        if ~stcrmp(class(OverlayStruct.(iFieldName)),...
                class(DefaultStruct.(iFieldName)))
            badFieldContentLogicals(iField) = true;
        end
    end
    if any(badFieldContentLogicals)
        errId = ['MAPS:',mfilename,':InvalidFieldDataTypes'];
        generate_MAPS_exception_add_causes_and_throw(...
            errId,overlayStructFields,badFieldContentLogicals);
    end
end

%% OVERLAY DEFAULT STRUCTURE WITH CONTENT OF OVERLAY STRUCTURE
OverlaidStruct = overlay_structure(OverlayStruct,DefaultStruct);

end