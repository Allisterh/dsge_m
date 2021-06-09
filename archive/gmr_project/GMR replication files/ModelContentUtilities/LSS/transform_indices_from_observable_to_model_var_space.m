function xjInds = transform_indices_from_observable_to_model_var_space(...
    Model,YjInds)
% This utility transforms index numbers from observable to model var space.
% It computes the index numbers of the model observables in a linear state 
% (LSS) model when translated to model variable space and then selects the
% index numbers corresponding to the vector input.
%
% INPUTS:   
%   -> Model: MAPS LSS model structure
%   -> YjInds: indices of a sub-set of model observables from the model
%
% OUTPUTS:  
%   -> xjInds: indices of the sub-set of model observables from the model
%      transformed to model variable space
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> find_index_numbers_of_observables_in_model_var_space
%   -> generate_MAPS_exception_add_cause_and_throw
%
% DETAILS:  
%   -> This utility transforms the index numbers of a sub-set of model 
%      observables from the model to model variable space.
%   -> It first computes the index numbers of all the model observables 
%      from the model in model variable space. It then picks out those 
%      indices that correspond to the model observable indices input.
%           
% NOTES:    
%   -> See <> for a description of MAPS model utilities.
%           
% This version: 08/03/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that all the necessary inputs were provided and that they have the
% expected shape.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_finite_real_numeric_column_vector(YjInds)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);    
end

%% FIND INDEX NUMBERS OF MODEL OBSERVABLES IN MODEL VARIABLE SPACE
% Call a MAPS utility function to convert all the model observable index
% numbers in the model (1 to nY) to model variable space.
xInds = find_index_numbers_of_observables_in_model_var_space(Model);

%% CONVERT MODEL OBSERVABLES INDICES INPUT TO MODEL VARIABLE SPACE
% Pick out the index numbers of the model observables transformed to model
% variable space that correspond to the model observable indices input.
% Throw an exception if this index operation fails (e.g. because the
% maximum index input exceeds the number of observables in the model).
try
    xjInds = xInds(YjInds);
catch IndConversionE
    errId = ['MAPS:',mfilename,':BadInds'];
    generate_MAPS_exception_add_cause_and_throw(IndConversionE,errId);
end

end