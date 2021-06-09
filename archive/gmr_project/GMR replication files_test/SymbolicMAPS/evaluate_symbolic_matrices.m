function varargout = evaluate_symbolic_matrices(...
    matArgs,matArgNames,varargin)
% This module numerically evaluates symbolic matrices in MAPS.
% It is a symbolic MAPS function that numerically evaluates symbolic
% matrices that have been defined using function handles in MAPS.
%
% INPUTS:   
%   -> matArgs: cell array of function handle arguments
%   -> matArgNames: cell string array of function handle argument names
%   -> varargin: cell array of function handles to evaluate
%
% OUTPUTS:  
%   -> varargout: cell array of numeric matrices
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_row_cell_array
%   -> is_row_cell_string_array
%   -> is_finite_real_numeric_column_vector
%   -> create_comma_separated_list
%   -> generate_MAPS_exception_add_cause_and_throw
%
% DETAILS:
%   -> This function evaluates a set of symbolic matrices defined in MAPS
%      as function handles using a set of argumands.
%   -> If successful, it returns a numeric matrix for each symbolic
%      function handle matrix passed in.
%
% NOTES:
%   -> See <> for a discussion of symbolic MAPS.
%   -> See also MAPS' function handle creation functionality. 
%
% This version: 16/05/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number of inputs is as expected and that the symbolic
% matrix arguments are the correct shape.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_row_cell_array(matArgs)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_row_cell_string_array(matArgNames)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK CONSISTENCY OF ARGUMENT INPUTS
% Determine the number of matrix arguments and check that the number of
% argument names given is consistent.
nMatArgs = size(matArgs,2);
if size(matArgNames,2) ~= nMatArgs
    errId = ['MAPS:',mfilename,':InconsistentNargs'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK AND UNPACK SYMBOLIC MATRIX ARGUMENTS
% Create a generic input string and input assignment to be used in the 
% function handle evaluation below. At the same time, check that the
% symbolic matrix numeric arguments are stored in column vectors.
for iArg = 1:nMatArgs
    if ~is_finite_real_numeric_column_vector(matArgs{iArg})
        errId = ['MAPS:',mfilename,':BadSymbolicMatArg'];
        generate_and_throw_MAPS_exception(errId);
    end
    eval([matArgNames{iArg},' = matArgs{iArg};']);
end
matArgString = create_comma_separated_list(matArgNames);

%% EVALUATE SYMBOLIC MATRICES
% Evaluate each of the symbolic function handle matrices passed in as
% input. There are two possible exceptions: the first is that the symbolic
% matrices passed in are not function handles; the second is that it is not
% possible to evaluate those function handles given the numeric arguments
% passed in.
nSymMats = size(varargin,2);
varargout = cell(1,nSymMats);
for iMat = 1:nSymMats    
    if strcmp(class(varargin{iMat}),'function_handle')
        try
            varargout{iMat} = eval(['varargin{iMat}(',matArgString,');']);
        catch MatEvalE
            errId = ['MAPS:',mfilename,':SymMatEvalFailure'];
            generate_MAPS_exception_add_cause_and_throw(...
                MatEvalE,errId,{num2str(iMat)});
        end
    else
        errId = ['MAPS:',mfilename,':BadSymbolicMat'];
        generate_and_throw_MAPS_exception(errId,{num2str(iMat)});
    end
end

end