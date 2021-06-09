function check_field_names_in_structure(...
    StructToCheck,structDescription,compulsoryFields,optionalFields)
% This helper validates the field names of a structure.
%
% INPUTS:
%   -> StructToCheck: structure whose fields to check
%   -> structDescription: description of the structure to add to error 
%      message
%   -> compulsoryFields: compulsory fields (can be an empty string '')
%   -> optionalFields (optional): optional fields
%
% OUTPUTS:
%   -> none
%
% DETAILS:
%   -> This helper checks the fields of a structure.
%   -> It will throw an exception if: a) any compulsory fields are missing
%      from the structure; b) the structure contains any random, unknown
%      fields.
%   -> The structure description can be used to provide some context for 
%      the error. It is used as the first part of the error message, which
%      for missing compulsory fields reads: 
%      [structDescription,' is missing the following compulsory fields:']
%
% NOTES:
%   -> This function is a useful helper for input validation.
%
% This version: 20/11/2012
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(StructToCheck)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~ischar(structDescription)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_string_or_vector_cell_string_array(compulsoryFields)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin>3 && ~is_string_or_vector_cell_string_array(optionalFields)
    errId = ['MAPS:',mfilename,':BadInput4'];
    generate_and_throw_MAPS_exception(errId);
end

%% HANDLE FORMAT OF COMPULSORY FIELDS INPUT
if isempty(compulsoryFields)
    areCompulsoryFieldsInStruct = false;
else
    areCompulsoryFieldsInStruct = true;
    compulsoryFields = ...
        convert_string_or_vector_string_array_to_column_array(...
        compulsoryFields);
end

%% AMALGAMATE COMPULSORY & OPTIONAL OPTIONAL FIELDS AS APPROPRIATE
if nargin < 4
    if areCompulsoryFieldsInStruct
        allPermittedFields = compulsoryFields;
    else
        errId = ['MAPS:',mfilename,':NoFieldsToCheck'];
        generate_and_throw_MAPS_exception(errId);
    end
else
    optionalFields = ...
        convert_string_or_vector_string_array_to_column_array(...
        optionalFields);
    if areCompulsoryFieldsInStruct
        allPermittedFields = [compulsoryFields;optionalFields];
    else
        allPermittedFields = optionalFields;
    end
end

%% CHECK INPUT FIELD NAMES CONSTITUTE A UNIQUE SET
repeatedPermittedFields = find_repeated_strings(allPermittedFields);
if ~isempty(repeatedPermittedFields)
   nRepeatedStrings = size(repeatedPermittedFields,1);
   errId = ['MAPS:',mfilename,':InvalidInputFieldNames'];
   generate_MAPS_exception_add_causes_and_throw(...
       errId,repeatedPermittedFields,true(nRepeatedStrings,1));
end

%% EXTRACT FIELD NAMES OF STRUCTURE TO CHECK
fieldNamesOfStruct = fieldnames(StructToCheck);

%% CHECK THAT COMPULSORY FIELDS ARE PRESENT
if areCompulsoryFieldsInStruct
    isMissingCompulsoryField = ~ismember(...
        compulsoryFields,fieldNamesOfStruct);
    if any(isMissingCompulsoryField)
        errId = ['MAPS:',mfilename,':MissingCompulsoryFields'];
        generate_MAPS_exception_add_causes_and_throw(errId,...
            compulsoryFields,isMissingCompulsoryField,{structDescription});
    end
end

%% CHECK THAT THERE ARE NO UNEXPECTED FIELDS
isUnknownField = ~ismember(fieldNamesOfStruct,allPermittedFields);
if any(isUnknownField)
    errId = ['MAPS:',mfilename,':UnknownFields'];
    generate_MAPS_exception_add_causes_and_throw(...
        errId,fieldNamesOfStruct,isUnknownField,{structDescription});
end

end