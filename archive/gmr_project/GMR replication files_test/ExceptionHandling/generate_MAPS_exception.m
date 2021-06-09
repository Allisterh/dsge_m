function MAPSexception = generate_MAPS_exception(errId,errArgs)
% This function creates a MAPS exception consistent with a MAPS error code.
% It generates a MAPS exception containing a message consistent with the 
% identifier input and any optional error message arguments passed in.
%
% INPUTS:   
%   -> errId: string representing the MAPS exception identifier
%   -> errArgs: optional cell array of additional message arguments
%
% OUTPUTS:
%   -> MAPSexception: a MAPS exception
%
% DETAILS:
%   -> The identifiers are structured in the following way:
%       'MAPS:<functionName>:<errorCode>'; or 
%       'MAPS:<functionName>:<errorCode1>:<errCode2>' etc
%   -> This function calls generate_MAPS_error_message which contains 
%      all documented MAPS exceptions. The file contains sub-functions for 
%      each MAPS function, which associate the exception identifier with a 
%      particular error message.
%   -> Error messages can be supplemented with additional errArgs,
%      which can be used to provide more specific information about the
%      particular instance of the error.
%
% NOTES:
%   -> See xxxx for more information about exception handling in MAPS.
%   -> Note that the error messages relating to this function are 
%      constructed directly rather than by calling this function again. 
%      This is to avoid the possibility of getting stuck in an infinite 
%      loop were the same error is exposed over and over again. 
%
% This version: 12/11/2013
% Author(s): Francesca Monti & Matt Waldron

%% CHECK INPUTS
% Check the validity of the inputs and throw an error if they are not as
% expected.
if nargin < 1
    error(['MAPS:',mfilename,':BadNargin'],[mfilename,' was not ',...
        'passed enough inputs: it requires either 1 or 2 inputs (if ',...
        'optional error arguments are passed in)'])
elseif ~ischar(errId)
    error(['MAPS:',mfilename,':BadInput1'],['1st input passed to ',...
        mfilename,' must be a string representing a MAPS error ',...
        'identifier'])
elseif nargin > 1
    if  ~iscell(errArgs)
        error(['MAPS:',mfilename,':BadInput2'],['Optional 2nd input ',...
            'passed to ',mfilename,' must be a cell array containing ',...
            'additional message arguments'])
    end
end

%% ADJUST ERROR ID FOR OBJECT PACKAGE IDENTIFIERS
% Errors originating from methods of MAPS objects that are stored in 
% packages are only uniquely identified with the <package.class>
% identifier. In order to support the error handling logic embedded in 
% MAPS, the "." part of the function name identifier is converted to an 
% "_". This logic must be mirrored in the error message function.
errId = strrep(errId,'.','_');

%% EXTRACT INFORMATION FROM THE IDENTIFIER
% Break the identifier into its consituent parts; a MAPS identifier, the
% function name and an error code.
if size(strfind(errId,':'),2) < 2
    error(['MAPS:',mfilename,':BadIdentifier'],['Identifier input to ',...
        mfilename,' must contain at least two colons'])
end
[component,R1] = strtok(errId,':');
if ~strcmpi(component,'MAPS'),
    error(['MAPS:',mfilename,':WrongIdentifier'],['Identifier input ',...
        'to ',mfilename,' must begin with ''MAPS:'' to distinguish ',...
        'MAPS exceptions from regular MATLAB exceptions'])
end
R1 = R1(2:end);
[funcName,R2] = strtok(R1,':');
errCode = R2(2:end);

%% GENERATE THE EXCEPTION
% Call the error message configuration file to produce the message string
% given the function name, the error code and the message arguments. If no
% message arguments were passed in, set the message arguments to empty.
if nargin == 1
    errArgs = {};
end
message = generate_MAPS_error_message(funcName,errCode,errArgs);
messageWithoutEscapes = regexprep(message,'\\(?!(n|t))','\\\');
MAPSexception = MException(errId,messageWithoutEscapes);

end