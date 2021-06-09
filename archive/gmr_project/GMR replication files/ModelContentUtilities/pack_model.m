function Model = pack_model(ExistingModel,identifiers,data)
% This model helper can be used to pack components of a MAPS model.
% It uses information about the structure of MAPS model objects (as stored 
% in the model itself) to insert new or updated components of a model in 
% the correct place based on MAPS model object identifiers.
%
% INPUTS:
%   -> ExistingModel: MAPS model structure
%   -> identifiers: cell string array of MAPS model component identifiers
%      or, optionally, a single string for a single pack instruction
%   -> data: cell array of data to insert for the objects identified
%
% OUTPUTS:
%   -> Model: Updated MAPS model structure
%
% DETAILS:
%   -> This model utility can be used as shorthand for packing a model
%      based on MAPS model object identifiers (so does not require 
%      knowledge of exactly how a model is put togther).
%   -> It runs through the model object identifiers, using information in 
%      Model.Constructor to pack the requsted information into its 
%      designated place in the MAPS model structure.
%   -> The function will return an error if the requested model component
%      does not exist as a valid component of the model input.
%   -> This function is generic to all models because the information used 
%      to unpack the model is stored in the model itself, which means that 
%      it is possible for the structure of a MAPS model object to change 
%      over time, but for pre-existing models to remain valid for use with
%      this function.
%
% NOTES:
%   -> See also MAPS' unpack model helper which inverts the operation in 
%      this function.
%
% This version: 22/01/2013
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(ExistingModel) || ~isfield(ExistingModel,'Constructor')
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_string_or_vector_cell_string_array(identifiers)      
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_row_or_column_cell_array(data)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
end

%% COMPUTE THE NUMBER OF IDENTIFIERS PASSED IN
% Convert the string or row cell string array to a column cell string 
% array (allowing the precise format of the input to be ignored in what 
% follows). Compute the number of identifiers passed in and check that the 
% number of outputs specified in the call is consistent with that. If not,
% throw an exception.
colCellStrOfIDs = convert_string_or_vector_string_array_to_column_array(...
    identifiers);
nIDs = size(colCellStrOfIDs,1);  
if size(data(:),1) ~= nIDs
    errId = ['MAPS:',mfilename,':InconsistentIdentifierDataDims'];
    generate_and_throw_MAPS_exception(errId);
end

%% PACK MODEL OBJECT
% Run through each of the identifiers specified, using the constructor
% information in the model to pack the data passed in into the model. 
% Create an exception as cause to a master exception if it was not possible
% to unpack the data or the component identifier does not exist among those
% listed in the model.
exceptionFound = false;
Model = ExistingModel;
for iID = 1:nIDs
    if isfield(Model.Constructor,colCellStrOfIDs{iID})
        eval([Model.Constructor.(colCellStrOfIDs{iID}),...
            '=data{iID};']);
    else
        if ~exceptionFound
            masterErrId = ['MAPS:',mfilename,':PackFailure'];
            ModelPackE = generate_MAPS_exception(masterErrId);
        end
        exceptionFound = true;
        errId = [masterErrId,':NonExistentID'];
        ModelPackE = generate_MAPS_exception_and_add_as_cause(...
            ModelPackE,errId,colCellStrOfIDs(iID));
    end
end

%% THROW ANY EXCEPTIONS ENCOUNTERED
% Throw the master exception if any exceptions were encountered above.
if exceptionFound
    throw(ModelPackE);
end

end