function create_model_file(Model,modelFileName)
% This macro manages the creation of a MAPS model file from a model object.
% It allows users to convert existing MAPS model object structures to an
% equivalent MAPS model text file. It inverts the operation in create
% model, which creates a MAPS model object from a MAPS model file.
%
% INPUTS:
%   -> Model: a complete MAPS model structure
%   -> modelFileName: full path name of the *.maps model info file
%
% OUTPUTS:  
%   -> none
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> unpack_model 
%   -> generate_MAPS_exception_add_cause_and_throw
%   -> create_LSS_model_file
%   -> create_NLBL_model_file
%
% DETAILS:  
%   -> The macro first determines the type of model input. MAPS supports
%      two model classes: linear state space (LSS) and non-linear
%      backward-looking (NLBL).
%   -> It then calls either an LSS or NLBL model file creater to produce
%      a new MAPS model file.
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

%% DETERMINE THE TYPE OF MODEL INPUT
% Determine if the model input is linear state space (LSS), true, or 
% non-linear backward-looking (NLBL), false.
try
    modelIsLinearStateSpace = unpack_model(...
        Model,{'modelIsLinearStateSpace'});
catch ModelUnpackE
    errId = ['MAPS:',mfilename,':ModelClassDeterminationFailure'];
    generate_MAPS_exception_add_cause_and_throw(ModelUnpackE,errId);
end

%% CALL SPECIFIC CREATE MODEL FILE MACRO
% Call the appropriate model file creater function depending on the model
% type.
if modelIsLinearStateSpace
    create_LSS_model_file(Model,modelFileName);
else
    create_NLBL_model_file(Model,modelFileName);
end

end