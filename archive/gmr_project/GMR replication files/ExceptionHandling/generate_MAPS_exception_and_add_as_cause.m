function Exception = generate_MAPS_exception_and_add_as_cause(...
    Exception,errId,errArgs)
% This helper creates a MAPS exception & adds it as cause to an exception.
% It is an additional method on top of generate_MAPS_exception that can be 
% used to manage MAPS exceptions.
%
% INPUTS:   
%   -> Exception: exception object to add cause to
%   -> errId: string representing the MAPS exception identifier
%   -> errArgs: optional cell array of additional message arguments
%
% OUTPUTS:
%   -> Exception: updated exception object with new cause
%
% CALLS:  
%   -> generate_MAPS_exception
%
% DETAILS:
%   -> The identifiers are structured in the following way:
%       'MAPS:<functionName>:<errorCode>'; or 
%       'MAPS:<functionName>:<errorCode1>:<errorCode2>'.
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
%   -> generate_MAPS_exception_and_add_as_cause creates an excpetion as a
%      cause to add to the input exception. It can be used to build up
%      multiple causes and layers of MAPS exceptions.
%   -> This function is a method which sits around generate_MAPS_exception 
%      (the function that creates the MAPS exception). As a result, it 
%      leaves most error handling to that inner method.
%
% This version: 27/01/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check the validity of the inputs and throw an error if they are not as
% expected.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~strcmp(class(Exception),'MException')
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId); 
end

%% GENERATE MAPS EXCEPTION
% Generate the exception using the generate_MAPS_exception function. The
% call to this function depends on the number of inputs passed in.
if nargin == 2
    MAPSexceptionCause = generate_MAPS_exception(errId);
else
    MAPSexceptionCause = generate_MAPS_exception(errId,errArgs);
end

%% ADD THE EXCEPTION CAUSE
% Add the exception passed in as input to this function as cause to the 
% MAPS exception generated above. 
Exception = addCause(Exception,MAPSexceptionCause);

end