function Model = create_model(modelFileName)
% This macro manages the creation of a new MAPS model.
% It allows users to incorporate a new linear state space or non-linear 
% backward-looking model written in a MAPS formatted text file into MAPS 
% for use with all relevant MAPS functionality & EASE.
%
% INPUTS:   
%   -> modelFileName: full path name of the *.maps model info file
%
% OUTPUTS:  
%   -> Model: a complete MAPS model structure
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> pre_parse_model 
%   -> create_LSS_model
%   -> create_NLBL_model
%
% DETAILS:  
%   -> This model creation macro first calls a pre-parser to determine the 
%      model type (either linear state space or non-linear backward-
%      looking). 
%   -> It then calls either a linear or non-linear model creater to produce
%      a new MAPS model.
%
% NOTES:   
%   -> See xxxxxx for a description of MAPS models and MAPS model creation.
%
% This version: 09/03/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and type of input is as expected by the macro.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(modelFileName)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% DETERMINE MODEL TYPE
% Call a pre-parser to scan in the model info to determine whether the 
% model is linear state space or non-linear backward-looking.
fprintf('Pre-parsing model\n');
modelIsLinearStateSpace = pre_parse_model(modelFileName);

%% CREATE MODEL BASED ON TYPE
% If model is linear then call the linear model creater. Otherwise, call
% the non-linear model creater.
if modelIsLinearStateSpace
    Model = create_LSS_model(modelFileName);
else
    Model = create_NLBL_model(modelFileName);
end

end