function YxInds = find_index_numbers_of_observables_in_model_var_space(...
    Model)
% This utility computes the indices of observables in model variable space.
% It uses the information in linear state space (LSS) model measurement
% equations to compute the index numbers of the model observables
% transformed into model variable space.
%
% INPUTS:   
%   -> Model: MAPS LSS model structure
%
% OUTPUTS:  
%   -> YxInds: index numbers of model observables in model variable space
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> unpack_model
%   -> extract_index_numbers_from_incidence_matrix
%
% DETAILS:  
%   -> This utility computes the index numbers of the model observables 
%      transformed to model variable space in a MAPS linear state space 
%      (LSS) model.
%   -> It uses the matrix of loadings on model variables in the measurement
%      equations and a helper function to compute the model variable
%      indices.
%   -> It then checks that there is a unique mapping between each model
%      observable and a model variable.
%           
% NOTES:    
%   -> See <> for a description of MAPS model utilities.
%           
% This version: 04/03/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the inputs are as expected.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% UNPACK MODEL TYPE
% Unpack the model class field and throw an exception if the model is not
% LSS as expected.
modelIsLinearStateSpace = unpack_model(Model,{'modelIsLinearStateSpace'});
if ~modelIsLinearStateSpace
    errId = ['MAPS:',mfilename,':BadModelClass'];
    generate_and_throw_MAPS_exception(errId);
end

%% UNPACK MODEL CHARACTERSITICS FIELD
% Unpack the model measurement equation characteristics field and throw an
% exception if the model does not have measurement equations.
modelHasMeasurementEqs = unpack_model(Model,{'modelHasMeasurementEqs'});
if ~modelHasMeasurementEqs
    errId = ['MAPS:',mfilename,':BadModelCharacteristics'];
    generate_and_throw_MAPS_exception(errId);
end

%% UNPACK LOADINGS ON MODEL VARIABLES IN MEASUREMENT EQUATIONS
% Unpack the loadings on the model variables in the LSS model measurement
% equations.
G = unpack_model(Model,{'G'});

%% COMPUTE INDEX NUMBERS OF MODEL VARIABLES
% Use a MAPS symbolic helper to extract index numbers from the incidence 
% matrix (the logical equivalent of the matrix) unpacked above.
[YxInds,YeqInds] = extract_index_numbers_from_incidence_matrix(logical(G));

%% CHECK FOR UNIQUE MAPPING
% If the number of model variable index numbers does not equal the number
% of model observables (or there are observables that doe not map into
% model variables - a row or rows with only zeros), throw an exception.
nY = size(G,1);
if (size(YxInds,1)~=nY) || ~isequal((1:nY)',YeqInds)
    errId = ['MAPS:',mfilename,':NonUniqueMapping'];
    generate_and_throw_MAPS_exception(errId);
end

end