function OverlaidStruct = overlay_structure(OverlayStruct,RefStruct)
% This helper creates a structure from the merger of two input structures.
% More preceisely, the structure created is the reference input structure
% overlaid with the content of the other input structure regardless of
% whether or not the field names intersect.
%
% INPUTS:
%   -> OverlayStruct: structure of information to overlay on the default
%   -> RefStruct: reference structure
%
% OUTPUTS:
%   -> OverlaidStruct: reference structure overlaid with information from
%      the overlay strcuture input
%
% DETAILS:
%   -> This function can be used to merge the fields in two structures
%      together, taking one of those structures as the base (or
%      reference structure).
%   -> The reference structure is overlaid with all information from the
%      "overlay" structure regardless of whether the field names overlap.
%      The output will be the same as the reference structure but with new 
%      fields, where there are fields in the overlay structure that did not
%      exist in the reference structure, and with fields from the overlay
%      structure, where the field names in the two input structure
%      overlapped.
%
% NOTES:
%   -> This function has a twin in MAPS which will also check whether the
%      field names in the overlay structure are a subset of the reference 
%      structure and throw an error if not.
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
elseif ~isstruct(RefStruct)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% EXTRACT FIELD NAMES OF OVERLAY STRUCTURE
overlayStructFields = fieldnames(OverlayStruct);

%% OVERLAY DEFAULT STRUCTURE WITH CONTENT OF OVERLAY STRUCTURE
OverlaidStruct = RefStruct;
nFieldsToOverlay = size(overlayStructFields,1);
for iField = 1:nFieldsToOverlay
    iOverlayField = overlayStructFields{iField};
    OverlaidStruct.(iOverlayField) = OverlayStruct.(iOverlayField);
end

end