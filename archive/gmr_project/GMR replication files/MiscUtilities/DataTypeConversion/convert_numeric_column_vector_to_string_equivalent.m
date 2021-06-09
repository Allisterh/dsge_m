function cellStrNums = ...
    convert_numeric_column_vector_to_string_equivalent(numVec)
% This helper converts a numeric column vector to a cell string equivalent.
% This is useful in the writing of information to a text file.
%
% INPUTS:
%   -> numVec: numeric column vector of data
%
% OUTPUTS:  
%   -> cellStrNums: equivalent cell string array of numerics
%
% CALLS:    
%   -> generate_and_throw_MAPS_exception
%   -> is_finite_real_numeric_column_vector
%
% DETAILS:  
%   -> This function converts a numeric column vector of numbers to a cell
%      string array equivelent, which can be used to write out to text file 
%      or print.
%
% NOTES:
%   -> This function allows for 16 significant figures in the conversion of
%      the numerics to the strings in the call to the MATLAB num2str 
%      function.
%
% This version: 10/03/2011
% Author(s): Matt Waldron

%% CHECK INPUT
% Check that the number and type of input is as expected by this function.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_finite_real_numeric_column_vector(numVec)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
end

%% CONVERT NUMERICS TO STRINGS
% Use the MATLAB num2str command to convert the numeric column vector to a
% character array, allowing for up to 16 significant figures (which
% over-rides the default treatment n num2str).
strNums = num2str(numVec,16);

%% CONVERT CHARACTER ARRAY TO A CELL STRING ARRAY
% Use the MATLAB cellstr command to convert the character array to a cell
% string array and trim the result.
cellStrNums = strtrim(cellstr(strNums));

end