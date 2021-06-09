function strNum = convert_numeric_scalar_to_string_equivalent(num)
% This helper converts a numeric scalar to a string equivalent.
% This is useful in MAPS external interfaces like writing to a text file.
%
% INPUTS:
%   -> num: real numeric scalar
%
% OUTPUTS:  
%   -> strNum: string equivalent
%
% DETAILS:  
%   -> This function converts a numeric scalar to a string equivalent.
%   -> It is part of a family of data type conversion functions in MAPS.
%
% NOTES:
%   -> This function allows for 16 significant figures in the conversion of
%      the numeric to the string in the call to the MATLAB num2str 
%      function.
%
% This version: 26/02/2013
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_real_numeric_scalar(num)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
end

%% CONVERT NUMERIC TO STRING
% Use the MATLAB num2str command to convert the numeric scalar to a
% character array, allowing for up to 16 significant figures (which
% over-rides the default treatment n num2str).
strNum = num2str(num,16);

end