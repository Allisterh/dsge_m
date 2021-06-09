function Model = create_LSS_model(modelFileName)
% This macro manages the creation of a new MAPS linear model.
% It allows users to incorporate a new linear state space model written in 
% a MAPS formatted text file into MAPS for use with all relevant MAPS 
% functionality & EASE.
%
% INPUTS:   
%   -> modelFileName: full path name of the *.maps model info file
%
% OUTPUTS:  
%   -> Model: a complete MAPS valid model structure
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> parse_LSS_model 
%   -> create_LSS_model_symbolics
%   -> create_LSS_model_numerics
%   -> construct_additional_LSS_model_info_for_EASE
%
% DETAILS:  
%   -> This linear state space model creation macro first calls the MAPS 
%      linear model parser to parse the model from the text file into 
%      MATLAB. 
%   -> The result is passed to a linear model symbolics creater which 
%      creates a set of symbolic function handles that can be evaluated 
%      given a complete parameter set to produce numeric matrices.
%   -> The numeric structural state space matrices are computed and the 
%      model is solved in MAPS' linear state space model numerics creater.
%   -> Finally, any additional information required by EASE that is not 
%      already in the MAPS model structure is added.
%
% NOTES:   
%   -> The parser controls the integrity of a model and stops invalid 
%      models being parsed into MAPS. It exercises a series of checks on
%      the validity of the model being parsed in. 
%   -> The numeric model creater macro includes checks on the numeric model 
%      (eg does it satisfy the poor man's invertibility condition etc).
%   -> See xxxxx for a description of MAPS linear state space models.
%
% This version: 18/02/2011
% Author(s): Matt Waldron, Francesca Monti

%% CHECK INPUTS
% Check that the number and type of input is as expected by the macro.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(modelFileName)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% PARSE MODEL
% Call MAPS' linear model parser to parse all the model information in the 
% MAPS model file, check it and add it to the MAPS linear model structure.
fprintf('Parsing linear state space model\n');
Model = parse_LSS_model(modelFileName);

%% CREATE SYMBOLIC REPRESENTATION OF THE MODEL
% Call the linear symbolic model creater to convert the string information
% parsed in from above to symbolic information for evaluation given a 
% parameter set.
fprintf('Creating linear state space model symbolic info\n');
Model = create_LSS_model_symbolics(Model);

%% CREATE MODEL NUMERICS & SOLVE MODEL
% Call the linear numeric model creater to convert the symbolic
% representation of the model to a numeric one, solve or evaluate the model
% steady state (if it exists) and then solve for the dynamic model
% solution. The macro also completes a number of numeric checks on the
% model to detect and warn about potential model issues (like lack of
% invertibility).
fprintf('Creating linear state space model numerics\n');
Model = create_LSS_model_numerics(Model);

%% ADD EXTRA INFORMATION REQUIRED BY EASE
% Finally, call a module to add any information to the model required for
% operation in EASE that is not already in the MAPS model structure.
fprintf('Creating additional linear state space model info for EASE\n');
Model = construct_additional_LSS_model_info_for_EASE(Model);

end