function create_LSS_model_file(Model,modelFileName)
% This macro manages the creation of a MAPS LSS model file from a model.
% It allows users to convert existing MAPS linear state space (LSS) model 
% object structures to an equivalent MAPS linear state space model text 
% file. It inverts the operation in create linear state space model, which 
% creates a MAPS linear state space model object from a MAPS linear state 
% space model file.
%
% INPUTS:
%   -> Model: a complete MAPS LSS model structure
%   -> modelFileName: full path name of the *.maps model info file
%
% OUTPUTS:  
%   -> none
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> get_LSS_model_file_config 
%   -> create_MAPS_model_file_text_info
%
% DETAILS:  
%   -> The macro first gets the LSS model file configuration. 
%   -> It then calls the generic model file creater with the configuration
%      information to create the MAPS model file consistent with the model
%      input. 
%   -> If the file creater is unable to do that then it will throw
%      an exception detailing the cause(s) of any failure(s).
%
% NOTES:   
%   -> See xxxxxx for a description of MAPS models and MAPS model creation.
%
% This version: 10/03/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and type of input is as expected by the macro.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
elseif ~ischar(modelFileName)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% VALIDATE MODEL CLASS
% Determine if the model input is linear state space (LSS). If not, throw
% an exception.
modelIsLinearStateSpace = unpack_model(Model,{'modelIsLinearStateSpace'});
if ~modelIsLinearStateSpace
    errId = ['MAPS:',mfilename,':BadModelClass'];
    generate_and_throw_MAPS_exception(ModelUnpackE,errId);
end

%% GET MAPS LSS MODEL FILE CONFIGURATION
% Get the MAPS LSS model file configuration information to pass to the
% generic MAPS model file creater below.
modelFileConfig = get_LSS_model_file_config;

%% CALL GENERIC CREATE MODEL FILE MACRO
% Pass the inputs to this function and the configuration info to the
% generic model file creater function. This function inverts the operation
% in the parse MAPS model text info function.
create_MAPS_model_file_text_info(Model,modelFileConfig,modelFileName)

end