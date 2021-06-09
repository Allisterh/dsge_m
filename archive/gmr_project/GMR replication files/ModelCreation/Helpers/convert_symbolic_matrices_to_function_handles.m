function varargout = convert_symbolic_matrices_to_function_handles(...
    symMatArgs,funHandleArgNames,varargin)
% This utility function converts symbolic matrices to function handles.
% Specifically, it converts MATLAB symbolic matrices to function handles
% that can be evaluated using numeric vector(s). 
%
% INPUTS:
%   -> symMatArgs: cell array of mnemonic string cell arrays
%   -> funHandleArgNames: string cell array of vector names for the 
%      function handle arguments
%   -> symMat: a number of symbolic matrices with the same arguments
%
% OUTPUTS:  
%   -> varargout: function handle representations of the symbolic matrices
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> convert_symbolic_matrix_to_function_handle
%
% DETAILS:  
%   -> This helper is a wrapper which sits outside of the symbolic matrix 
%      to function handle converter. It allows multiple symbolic matrices
%      to be converted to function handles in one call.
%   -> See convert_symbolic_matrix_to_function_handle for more details.
%
% NOTES:
%   -> Since this function is just a wrapper round the single symbolic
%      matrix to function handle converter, it leaves most error checking
%      to that underlying function.
%
% This version: 10/02/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_expection(errId,{num2str(nargin)});
end

%% CREATE THE FUNCTION HANDLES
% Count the number of symbolic matrices passed in as input and create a
% varargout list of the same size. Loop through the symbolic matrices,
% converting each to a function handle and storing it in the output list.
% Note that if any of the inputs were not of the correct shape, the
% converter function will throw an exception.
nVarargin = size(varargin,2);
varargout = cell(1,nVarargin);
for iVararg = 1:nVarargin
    varargout{iVararg} = convert_symbolic_matrix_to_function_handle(...
        varargin{iVararg},symMatArgs,funHandleArgNames);
end

end