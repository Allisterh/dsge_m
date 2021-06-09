function printableFileName = create_printable_file_name_string(fileName)
% This helper converts full path file name strings to a printable format.
% It ensures that the file name can be printed out in the command window or 
% in error messages. 
%
% INPUTS:   
%   -> fileName: full path file name string
%
% OUTPUTS:  
%   -> printableFileName: equivalent printable full path file name string
%
% DETAILS:  
%   -> This helper can be used by any function that prints a full path file
%      name (eg in error messages).
%   -> It is required because \ is an exit character in MATLAB print
%      commands like (fprintf) which means that path names like 
%      'C:\VSSROOT' do not print.
%   -> Adding a second backslash solves that problem, but still leads to 
%      special characters like \t being treated as escapes (in this case 
%      tab).
%   -> This function instead converts the \ character to /.
%
% This version: 05/12/2013
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId);
elseif ~ischar(fileName)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
end

%% CREATE A PRINTABLE FULL PATH FILE NAME
% If there are any \ terms in the string ensure that they are written as /.
printableFileName = strrep(fileName,'\','/');

end