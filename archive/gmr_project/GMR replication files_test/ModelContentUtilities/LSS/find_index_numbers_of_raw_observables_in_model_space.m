function YtildeYinds = ...
    find_index_numbers_of_raw_observables_in_model_space(Model)
% This utility computes the indices of raw observables in model space.
% To be precise, it computes the index numbers of the raw observables in a
% linear state (LSS) model when translated to model observable space.
%
% INPUTS:   
%   -> Model: MAPS LSS model structure
%
% OUTPUTS:  
%   -> YtildeYinds: index numbers of raw observables in model space
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> unpack_model
%
% DETAILS:  
%   -> This utility computes the index numbers of the raw observables 
%      transformed to model observable space in a MAPS linear state space 
%      (LSS) model.
%   -> It uses the string equations and mnemonics stored in the model
%      object to compute the incidence matrix of the data transformation
%      equations with respect to the raw observables and then extracts the 
%      index numbes from these. 
%   -> It then checks that there is a unique mapping between each raw
%      observable and a model observable.
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
% Unpack the model data transformation equation characteristics field and 
% throw an exception if the model does not have data transformation 
% equations.
modelHasDataTransformationEqs = unpack_model(...
    Model,{'modelHasDataTransformationEqs'});
if ~modelHasDataTransformationEqs
    errId = ['MAPS:',mfilename,':BadModelCharacteristics'];
    generate_and_throw_MAPS_exception(errId);
end 

%% UNPACK MODEL COMPONENTS
% Unpack the data transformation equation strings, the raw and model
% observable mnemonics.
[YtildeEqStrs,Ymnems,YtildeMnems] = unpack_model(...
    Model,{'YtildeEqStrs','Ymnems','YtildeMnems'});

%% REORDER EQUATIONS
% Reoder the equations so that there ordering is consistent with the model
% observable ordering. (This should be guaranteed given the format of MAPS
% model files and syntax checking of those, but reordering again here
% protects this code against changes to the format of MAPS model files
% later on. Note also that this function will throw an exception if model
% observables are not uniquely identified on the left-hand-side.)
YtildeEqsReordered = reorder_equations(YtildeEqStrs,Ymnems);

%% COMPUTE INCIDENCE MATRIX OF REORDERED EQUATIONS
% Compute the incidence matrix of the equations with respect to the raw
% observables.
YtildeEqsReorderedIncMat = compute_equations_incidence_matrix(...
    YtildeEqsReordered,YtildeMnems);

%% FIND INDEX NUMBERS IN INCIDENCE MATRIX
% Use a MAPS symbolic helper to extract index numbers from the incidence 
% matrix. Note that in order to ensure that the index numbers are of the
% raw observables in model space (rather than the other way round), it is
% necessary to transpose the incidence matrix.
[YtildeYinds,YtildeEqInds] = ...
    extract_index_numbers_from_incidence_matrix(YtildeEqsReorderedIncMat');

%% CHECK FOR UNIQUE MAPPING
% If the number of model observable index numbers does not equal the number
% of raw observables (or there are observables that do not map into
% model variables - a row or rows with only zeros), throw an exception.
nY = size(YtildeEqsReordered,1);
if (size(YtildeYinds,1)~=nY) || ~isequal((1:nY)',YtildeEqInds)
    errId = ['MAPS:',mfilename,':NonUniqueMapping'];
    generate_and_throw_MAPS_exception(errId);
end

end