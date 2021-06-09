function validate_measurement_equation_matrices(D,G,V)
% This helper valdiates a LSS model's measurement equation matrices. 
% It validates that the measurement equation matrices are of the expected 
% shape and are consistent with each other.
%
% INPUTS:
%   -> D: nY*1 column vector of constants
%   -> G: nY*nz matrix of loadings on model variables
%   -> V (optional): nY*nw matrix of loadings on measurement errors
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
%   -> This helper validates a LSS model's measurement equation matrices 
%      for use in MAPS modules. It checks both that the individual inputs 
%      are valid (in the sense that they are finite, real numeric matrices) 
%      and that their dimensions are consistent with each other. This 
%      ensures that they can be used (mechanically) in MAPS modules (but
%      not that they are correct in any absolute sense).
%   -> It can be used in two modes. If two inputs are passed in, it will 
%      validate the constants and the model variable loadings (which is 
%      useful if the model being used does not have measurement errors).
%      Otherwise, three inputs must be passed in, in which case it
%      validates all three matrices.
%
% NOTES:   
%   -> See <> for a description of MAPS forecast helpers and data 
%      validation.
%
% This version: 26/02/2011
% Author(s): Matt Waldron

%% CHECK NUMBER OF INPUTS
% Check that the number of inputs is as expected. Either 2 or 3 inputs must
% be passed in.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
end

%% CHECK SHAPE OF INDIVIDUAL INPUTS
% Check that the D input is a finite, real column vector; that the G input 
% is a finite, real, two-dimensional matrix. And, if input, that the V 
% input is a finite, real, two-dimensional matrix (it does not have to be 
% square because the model observable and measurement error dimensions do 
% not have to be the same).
DisFinRealColumnVec = is_finite_real_numeric_column_vector(D);
if ~DisFinRealColumnVec
    errId = ['MAPS:',mfilename,':BadD'];
    generate_and_throw_MAPS_exception(errId);
end
GisFinRealTwoDimMat = is_finite_real_two_dimensional_numeric_matrix(G);
if ~GisFinRealTwoDimMat
    errId = ['MAPS:',mfilename,':BadG'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin > 2
    VisFinRealTwoDimMat = is_finite_real_two_dimensional_numeric_matrix(V);
    if ~VisFinRealTwoDimMat
        errId = ['MAPS:',mfilename,':BadV'];
        generate_and_throw_MAPS_exception(errId);
    end   
end

%% CHECK CONSISTENT OF INPUTS WITH EACH OTHER
% Check that the number of rows in the D vector is consistent with the 
% number of rows in the G matrix and, if 3 inputs were passed in, the V
% matrix.
if size(D,1) ~= size(G,1)
    errId = ['MAPS:',mfilename,':DincompatibleG'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin > 2
    if size(D,1) ~= size(V,1)
        errId = ['MAPS:',mfilename,':DincompatibleV'];
        generate_and_throw_MAPS_exception(errId);
    end
end

end