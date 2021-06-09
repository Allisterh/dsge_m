function cellStrLogicals = ...
    convert_logical_column_vector_to_string_equivalent(logicalVec)
% This helper converts a logical vector to a cell string equivalent.
% This is useful in the writing of information to a text file.
%
% INPUTS:
%   -> logicalVec: numeric column vector of data
%
% OUTPUTS:  
%   -> cellStrLogicals: equivalent cell string array of logicals
%
% DETAILS:  
%   -> This function converts a column vector of logicals to a cell string
%      array equivelent, which can be used to write out to text file or
%      print.
%
% NOTES:
%   -> This function is part of a family of string conversion functions.
%
% This version: 30/10/2012
% Author(s): Matt Waldron

%% CHECK INPUT
% Check that the number and type of input is as expected by this function.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_logical_column_vector(logicalVec)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
end

%% INITIALISE OUTPUT
nLogicals = size(logicalVec,1);
cellStrLogicals = cell(nLogicals,1);

%% CONVERT LOGICALS TO STRINGS
% Write the true elements out as 'true' in the cell string array and the 
% false elements out as 'false'.
cellStrLogicals(logicalVec) = {'true'};
cellStrLogicals(~logicalVec) = {'false'};


end