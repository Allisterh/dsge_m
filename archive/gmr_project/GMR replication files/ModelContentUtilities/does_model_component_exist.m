function modelComponentExists = ...
    does_model_component_exist(Model,modelComponent)
% This model helper checks whether a model part exists in a model.
% It tries to unpack the model part. If it succeeds, it sets the output to
% true and if the non-existent ID error is thrown it sets the output to false.
%
% INPUTS:
%   -> Model: a MAPS model structure with constructor
%   -> modelComponent: a string representing the model part to look for,
%   e.g. xMnems or theta

% OUTPUTS:
%   -> modelComponentExists: a logical indicating whether the model part
%   was found
%
% DETAILS:
%   -> A helper to determine whether a model part exists to be used before
%   trying to unpack it.
%   -> This helper looks for a specific error (non-existent ID). If another
%   error found it throws it.
%
% NOTES
%   ->
%
% This version: 28/02/2014
% Author: Kate Reinold

%% CHECK INPUTS
% Check the number of inputs (all are compulsory) and that they are of the
% right type
if  nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model) || ~isfield(Model,'Constructor')
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~ischar(modelComponent)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% DOES MODEL COMPONENT EXIST
% Try to unpack the requested model component. If it succeeds, set
% modelComponentExists to 1, else catch the error. If the error is
% NonExistentID, set modelComponentExists to 0.
try
    data = unpack_model(Model,{modelComponent});  %#ok<NASGU>
    modelComponentExists=true;
catch UnpackModelE
    if strcmp(UnpackModelE.cause{1}.identifier,...
            'MAPS:unpack_model:UnpackFailure:ConstructorEvalFailure')|| ...
            strcmp(UnpackModelE.cause{1}.identifier,...
            'MAPS:unpack_model:UnpackFailure:NonExistentID');
        modelComponentExists=false;
    else
        rethrow(UnpackModelE);
    end
end

end