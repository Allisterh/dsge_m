function varargout = unpack_model(Model,identifiers)
% This model helper can be used to unpack components of a MAPS model.
% It uses information about the structure of MAPS model objects (as stored 
% in the model itself) to unpack any component of the model based on MAPS 
% model object identifiers (which are shorthand for components of the 
% model).
%
% INPUTS:   
%   -> Model: MAPS model structure
%   -> identifiers: cell string array of MAPS model component identifiers
%      or, optionally, a single string for a single unpack instruction
%
% OUTPUTS:  
%   -> varargout: unpacked components of the MAPS model
%
% DETAILS:  
%   -> This model utility can be used as shorthand for unpacking a model
%      based on MAPS model object identifiers (so does not require 
%      knowledge of exactly how a model is put togther).
%   -> It runs through the model object identifiers, using information in 
%      Model.Constructor to remove the requsted information, returning each
%      separate piece of information requested as a separate output.
%   -> The function will return an error if the requested model component
%      does not form part of the model.
%   -> This function is generic to all models because the information used 
%      to unpack the model is stored in the model itself, which means that 
%      it is possible for the structure of a MAPS model object to change 
%      over time, but for pre-existing models to remain valid for use with 
%      this function.
%
% NOTES:
%   -> See also MAPS' pack model helper which inverts the operation in this
%      function.
%
% This version: 22/01/2013
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model) || ~isfield(Model,'Constructor')
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_string_or_vector_cell_string_array(identifiers)
    errId = ['MAPS:',mfilename,':BadInput2'];
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
if nargout ~= nIDs
    errId = ['MAPS:',mfilename,':NarginNargoutMismatch'];
    generate_and_throw_MAPS_exception(errId);
end

%% UNPACK MODEL COMPONENTS
% Run through each of the identifiers specified and use the constructor
% information in the model to unpack the model components requested. Create
% an exception as cause to a master exception if it was not possible to
% unpack the data or the component identifier does not exist among those
% listed in the model.
exceptionFound = false;
varargout = cell(1,nIDs);
for iID = 1:nIDs
    if isfield(Model.Constructor,colCellStrOfIDs{iID})
        try
            varargout{iID} = eval(...
                [Model.Constructor.(colCellStrOfIDs{iID}),';']);
        catch EvalE
            if ~exceptionFound
                masterErrId = ['MAPS:',mfilename,':UnpackFailure'];
                ModelUnpackE = generate_MAPS_exception(masterErrId);
            end
            exceptionFound = true;
            errId = [masterErrId,':ConstructorEvalFailure'];
            ConstructorEvalE = generate_MAPS_exception_and_add_cause(...
                EvalE,errId,colCellStrOfIDs(iID));
            ModelUnpackE = addCause(ModelUnpackE,ConstructorEvalE);
        end
    else
        if ~exceptionFound
            masterErrId = ['MAPS:',mfilename,':UnpackFailure'];
            ModelUnpackE = generate_MAPS_exception(masterErrId);
        end
        exceptionFound = true;
        errId = [masterErrId,':NonExistentID'];
        ModelUnpackE = generate_MAPS_exception_and_add_as_cause(...
            ModelUnpackE,errId,colCellStrOfIDs(iID));
    end
end

%% THROW ANY EXCEPTIONS ENCOUNTERED
% Throw the master exception if any exceptions were encountered above.
if exceptionFound
    throw(ModelUnpackE);
end

end