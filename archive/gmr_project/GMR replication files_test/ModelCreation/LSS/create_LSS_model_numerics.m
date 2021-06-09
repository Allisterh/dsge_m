function UpdatedModel = create_LSS_model_numerics(Model,theta)
% This macro creates all numerics associated with LSS models.
% It manages the call to the MAPS linear state space (LSS) model solver
% and to a numeric model checker which checks the numeric model for certain
% properties.
%
% INPUTS:   
%   -> Model: MAPS model structure
%   -> theta (otional): Column vector of parameter values 
%
% OUTPUTS:  
%   -> UpdatedModel: MAPS model structure updated with numeric components
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> unpack_model
%   -> solve_LSS_model
%   -> check_LSS_model_numerics
%   -> create_decomp_add_on_numerics
%
% DETAILS:
%   -> This LSS model numeric creation macro does two things. First, it
%      calls a solve model macro to compute the LSS model solution. 
%      Second, it calls a numeric model checker to check the properties of
%      the numeric model.
%   -> The parameter input to this function is optional. If not provided,
%      it will attempt to unpack the parameters from the input model.
%
% NOTES:
%   -> See <> for a description of LSS model solutions in MAPS.
%
% This version: 13/05/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Complete a basic check of the compulsory inputs coming into the macro.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId);
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end
    
%% CHECK FOR THE OPTIONAL INPUT
% If the second input was not passed in, unpack the parameters from the 
% model structure.
if nargin < 2
    theta = unpack_model(Model,{'theta'});
end

%% SOLVE MODEL
% Call the solve model macro to compute the numeric solution to the model.
% The solve model macro solves for the steady state of the model (if 
% applicable), creates numeric model matrices and then solves for the 
% dynamic solution of the model.
UpdatedModel = solve_LSS_model(Model,theta);

%% CHECK PROPERTIES OF NUMERIC MODEL
% Call the check model macro to test for a number of model properties
% including invertibility, controlability, stability and detectibility. 
% The outcome of each of these tests is saved into the model structure. 
% UpdatedModel = check_LSS_model_numerics(UpdatedModel);

%% UPDATE ANY DECOMPOSITION NUMERICS
modelHasDecompAddOn = unpack_model(Model,{'modelHasDecompAddOn'});
if modelHasDecompAddOn
   UpdatedModel = create_decomp_add_on_numerics(UpdatedModel); 
end

end