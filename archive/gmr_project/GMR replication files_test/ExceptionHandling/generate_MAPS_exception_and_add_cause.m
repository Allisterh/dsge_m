function MAPSexception = generate_MAPS_exception_and_add_cause(...
    ExceptionCause,errId,errArgs)
% This function creates a MAPS exception & adds another exception as cause.
% It is an additional method on top of generate_MAPS_exception that can be 
% used to manage MAPS exceptions.
%
% INPUTS:   
%   -> ExceptionCause: exception object to add as cause
%   -> errId: string representing the MAPS exception identifier
%   -> errArgs: optional cell array of additional message arguments
%
% OUTPUTS:
%   -> MAPSexception: a MAPS exception
%
% CALLS:  
%   -> generate_MAPS_exception
%
% DETAILS:
%   -> The identifiers are structured in the following way:
%       'MAPS:<functionName>:<errorCode>'; or 
%       'MAPS:<functionName>:<errorCode1>:<errorCode2>' etc
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
%   -> generate_MAPS_exception_and_add_cause creates a MAPS exception and 
%      adds the input exception as cause to that exception.
%   -> This function is a method which sits around generate_MAPS_exception 
%      (the function that creates the MAPS exception). As a result, it 
%      leaves most error handling to that inner method.
%
% This version: 27/01/2010
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check the validity of the inputs and throw an error if they are not as
% expected.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~strcmp(class(ExceptionCause),'MException')
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);     
end

%% GENERATE MAPS EXCEPTION
% Generate the exception using the generate_MAPS_exception function. The
% call to this function depends on the number of inputs passed in.
if nargin == 2
    MAPSexception = generate_MAPS_exception(errId);
else
    MAPSexception = generate_MAPS_exception(errId,errArgs);
end

%% ADD THE EXCEPTION CAUSE
% Add the MAPS exception generated as a cause to the master exception 
% passed in as input to this function.
MAPSexception = addCause(MAPSexception,ExceptionCause);

end