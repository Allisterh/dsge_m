function validate_LSS_model_solution_matrices(B,PHI,F)
% This helper valdiates a LSS model's solution matrices. 
% It validates that the solution matrices are of the expected shape and are
% consistent with each other.
%
% INPUTS:
%   -> B: nx*nx matrix of loadings on lagged model variables
%   -> PHI (optional): nx*nz matrix of loadings on shocks
%   -> F (optional): nx*nx matrix of loadings on anticipated shocks
%
% OUTPUTS
%   -> none 
%
% CALLS: 
%   -> generate_and_throw_MAPS_exception
%   -> is_finite_real_square_numeric_matrix
%   -> is_finite_real_two_dimensional_numeric_matrix
%
% DETAILS: 
%   -> This helper validates a LSS model's solution matrices for use in 
%      MAPS forecast modules. It checks both that the individual inputs are 
%      valid (in the sense that they are finite, real numeric matrices) and 
%      that their dimensions are consistent with each other. This ensures
%      that they can be used (mechanically) in MAPS forecast modules (but
%      not that they are correct in any absolute sense).
%   -> It can be used in two modes. If one input is passed in, it will 
%      validate the loadings on the lagged model variables (which is useful
%      in scenarios where shocks are not being used - like plain vanilla
%      projections). Otherwise, it will validate whichever matrices are
%      passed in (in addition to "B") and validate them for consistency.
%
% NOTES:   
%   -> See <> for a description of MAPS forecast helpers and data 
%      validation.
%
% This version: 26/02/2011
% Author(s): Matt Waldron

%% CHECK NUMBER OF INPUTS
% Check that the number of inputs is as expected. Either 1,2 or 3 inputs 
% must be passed in.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
end

%% CHECK SHAPE OF INDIVIDUAL INPUTS
% Check that the B input is a finite, real two-dimensional square matrix.
% And, if input, that the F input is the same and that the PHI input is a
% finite, real, two-dimensional matrix (it does not have to be square 
% because the model variable and shock dimensions do not have to be the
% same).
BisFinRealSquareMat = is_finite_real_square_numeric_matrix(B);
if ~BisFinRealSquareMat
    errId = ['MAPS:',mfilename,':BadB'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin > 1
    PHIisFinRealTwoDimMat = ...
        is_finite_real_two_dimensional_numeric_matrix(PHI);
    if ~PHIisFinRealTwoDimMat
        errId = ['MAPS:',mfilename,':BadPHI'];
        generate_and_throw_MAPS_exception(errId);
    end
elseif nargin > 2
    FisFinRealSquareMat = is_finite_real_square_numeric_matrix(F);
    if ~FisFinRealSquareMat
        errId = ['MAPS:',mfilename,':BadF'];
        generate_and_throw_MAPS_exception(errId);
    end   
end

%% CHECK CONSISTENT OF INPUTS WITH EACH OTHER
% If more than one input was passed in, check that the number of rows in 
% the B matrix is consistent with the number of rows in the PHI and F
% matrices.
if nargin > 1
    if size(B,1) ~= size(PHI,1)
        errId = ['MAPS:',mfilename,':BincompatiblePHI'];
        generate_and_throw_MAPS_exception(errId);
    end
end
if nargin > 2
    if size(B,1) ~= size(F,1)
        errId = ['MAPS:',mfilename,':BincompatibleF'];
        generate_and_throw_MAPS_exception(errId);
    end
end

end