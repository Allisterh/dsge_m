function validate_LSS_model_equation_matrices(HB,HC,HF,PSI)
% This helper valdiates a LSS model's model equation numeric matrices. 
% It validates that the model equation structural numeric matrices are of 
% the expected shape and are consistent with each other.
%
% INPUTS:
%   -> HB: nx*nx matrix of loadings on lagged model variables
%   -> HC: nx*nx matrix of loadings on contemporaneous model variables
%   -> HF: nx*nx matrix of loadings on future expected model variables
%   -> PSI: nx*nz matrix of loadings on shocks
%
% OUTPUTS
%   -> none 
%
% CALLS: 
%   -> generate_and_throw_MAPS_exception
%   -> is_finite_real_numeric_column_vector
%   -> is_finite_real_two_dimensional_numeric_matrix
%
% DETAILS: 
%   -> This helper validates a LSS model's model equation matrices for use 
%      in MAPS modules. It checks both that the individual inputs are valid
%      (in the sense that they are finite, real numeric matrices) and that 
%      their dimensions are consistent with each other. This ensures that
%      they can be used (mechanically) in MAPS modules (but not that they 
%      are correct in any absolute sense).
%
% NOTES:   
%   -> See <> for a description of MAPS helpers and data validation.
%
% This version: 16/05/2011
% Author(s): Matt Waldron

%% CHECK NUMBER OF INPUTS
% Check that the number of inputs is as expected - all inputs are
% compulsory.
if nargin < 4
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
end

%% CHECK SHAPE OF INDIVIDUAL INPUTS
% Check that the HB, HC & HF matrices are square matrices containing only 
% real & finite numerics. Check that the PSI matrix is a real finite, two-
% dimensional matrix.
if ~is_finite_real_square_numeric_matrix(HB)
    errId = ['MAPS:',mfilename,':BadHB'];
    generate_and_throw_MAPS_exception(errId);    
elseif ~is_finite_real_square_numeric_matrix(HC)
    errId = ['MAPS:',mfilename,':BadHC'];
    generate_and_throw_MAPS_exception(errId);      
elseif ~is_finite_real_square_numeric_matrix(HF)
    errId = ['MAPS:',mfilename,':BadHF'];
    generate_and_throw_MAPS_exception(errId);    
elseif ~is_finite_real_two_dimensional_numeric_matrix(PSI)
    errId = ['MAPS:',mfilename,':BadPSI'];
    generate_and_throw_MAPS_exception(errId);        
end

%% CHECK CONSISTENT OF INPUTS WITH EACH OTHER
% Check that the number of rows (measuring the number of model variables) 
% in each matrix is identical.
if size(HB,1) ~= size(HC,1)
    errId = ['MAPS:',mfilename,':HBincompatibleHC'];
    generate_and_throw_MAPS_exception(errId);    
elseif size(HF,1) ~= size(HC,1)
    errId = ['MAPS:',mfilename,':HFincompatibleHC'];
    generate_and_throw_MAPS_exception(errId);    
elseif size(PSI,1) ~= size(HC,1)
    errId = ['MAPS:',mfilename,':PSIincompatibleHC'];
    generate_and_throw_MAPS_exception(errId);          
end

end