function validate_model(Model,modelFileName)
% This macro validates a MAPS model structure.
% It can be used to check whether a MAPS model object (either linear state 
% space of non-linear, backward-looking) is valid for use in the latest
% version of MAPS and in EASE.
%
% INPUTS: 
%   -> Model: MAPS model structure
%   -> modelFileName: full path string name of *.maps model file to create
%
% OUTPUTS:  
%   -> none
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> unpack_model 
%   -> generate_MAPS_exception_add_cause_and_throw
%   -> validate_LSS_model
%   -> validate_NLBL_model
%
% DETAILS:  
%   -> This macro validates a MAPS model object.
%   -> It checks whether the model is linear state space or non-linear,
%      backward-looking and calls the appropriate validation macro.
%   -> In both cases, validation works by recreating a MAPS model file from
%      the model info passed in. The syntax of this model file can then be
%      checked in the usual way (and any erros found can be related to
%      particular lines in the file). Both routines then validate that the
%      model solution can be recreated from the model info parsed in and
%      that any additional EASE info added is consistent.
%   -> If validation is successful, this routine returns no outputs. If
%      not, it throws an error (or errors) detailing the cause of any 
%      failure(s).
%
% NOTES:   
%   -> See <> for a description of MAPS models and the rules that govern
%      their content.
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

%% CALL SPECIFIC VALIDATE MODEL MACRO
% Call the appropriate model validation routine depending on the model 
% type.
if modelIsLinearStateSpace
    validate_LSS_model(Model,modelFileName);
else
%     validate_NLBL_model(Model,modelFileName);
end

end