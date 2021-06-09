function modelComponentContainsElements = does_model_component_contain_element...
    (Model,modelComponent,element)
% Helper function to check that a model component contains an element. 
% For example, does xMnems contain a variable called c?
%
% INPUTS:
%   -> Model: MAPS model structure with constructors to allow unpacking
%   -> modelComponent: a string representing the part of the model to look
%   in, e.g. 'xMnems'
%   -> element: a cell containing a string representing the element to look
%   for, e.g. 'c'
%
% DETAILS:
%   -> Helper checks that there is one instance of the model element and so
%   will fail if there is not instance and if there is more than one. 
%   -> Makes use of the unpack function in MAPS so is used in conjunction
%   with a helper to check that the model component exists in the model.
%
% This version: 26/11/2012
% Author(s): Kate Reinold

%% CHECK INPUTS
% Check the number of inputs (all are compulsory) and that they are of the
% correct type.

if  nargin<3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model) || ~isfield(Model,'Constructor')
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
elseif ~ischar(modelComponent)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif ~iscell(element)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId); 
end

%% DOES MODEL ELEMENT EXIST IN MODEL PART
% Check that the component in which to search exists and then that 
modelComponentExists = does_model_component_exist(Model,modelComponent);

if modelComponentExists
    data = unpack_model(Model,{modelComponent});
    modelComponentContainsElements = ismember(element,data);
else
    errId = ['MAPS:',mfilename,':NonExistentComponent'];
    generate_and_throw_MAPS_exception(errId,{modelComponent});
end