function YjInds = transform_indices_from_raw_to_model_observable_space(...
    Model,YtildejInds)
% This utility transforms index numbers from raw to model observable space.
% It computes the index numbers of the raw observables in a linear state 
% (LSS) model when translated to model observable space and then selects 
% the index numbers corresponding to the vector input.
%
% INPUTS:   
%   -> Model: MAPS LSS model structure
%   -> YtildejInds: indices of a sub-set of raw observables from the model
%
% OUTPUTS:  
%   -> YjInds: indices of the sub-set of raw observables from the model
%      transformed to model observable space
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> find_index_numbers_of_raw_observables_in_model_space
%   -> generate_MAPS_exception_add_cause_and_throw
%
% DETAILS:  
%   -> This utility transforms the index numbers of a sub-set of raw 
%      observables from the model to model observable space.
%   -> It first computes the index numbers of all the raw observables from 
%      the model in model observable space. It then picks out those indices
%      that correspond to the raw observable indices input.
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
elseif ~is_finite_real_numeric_column_vector(YtildejInds)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);    
end

%% FIND INDEX NUMBERS OF MODEL RAW OBSERVABLES IN MODEL OBSERVABLE SPACE
% Call a MAPS utility function to convert all the raw observable index
% numbers in the model (1 to nYtilde) to model observable space.
Yinds = find_index_numbers_of_raw_observables_in_model_space(Model);

%% CONVERT RAW OBSERVABLES INDICES INPUT TO MODEL OBSERVABLE SPACE
% Pick out the index numbers of the raw observables transformed to model
% observable space that correspond to the raw observable indices input.
% Throw an exception if this index operation fails (e.g. because the
% maximum index input exceeds the number of observables in the model).
try
    YjInds = Yinds(YtildejInds);
catch IndConversionE
    errId = ['MAPS:',mfilename,':BadInds'];
    generate_MAPS_exception_add_cause_and_throw(IndConversionE,errId);
end

end