function generate_MAPS_exception_add_cause_and_throw(...
    ExceptionCause,errId,errArgs)
% This helper generates a MAPS exception, adds another as cause & throws.
% It is an additional method above generate_MAPS_exception_and_add_cause 
% that can be used to manage MAPS exceptions.
%
% INPUTS:   
%   -> ExceptionCause: exception object to add as cause
%   -> errId: string representing the MAPS exception identifier
%   -> errArgs: optional cell array of additional message arguments
%
% OUTPUTS:
%   -> none
%
% CALLS:  
%   -> generate_MAPS_exception_and_add_cause
%
% DETAILS:
%   -> generate_MAPS_exception_add_cause_and_throw creates a MAPS
%      exception, adds another exception as cause and then throws.
%   -> The identifiers are structured in the following way:
%       'MAPS:<functionName>:<errorCode>'; or 
%       'MAPS:<functionName>:<errorCode1>:<errorCode2>'.
%   -> This function calls generate_MAPS_exception_and_add_cause which 
%      calls generate_MAPS_error_message which contains all documented MAPS 
%      exceptions. The file contains sub-functions for each MAPS function, 
%      which associate the exception identifier with a particular error 
%      message.
%   -> Error messages can be supplemented with additional errArgs,
%      which can be used to provide more specific information about the
%      particular instance of the error.
%
% NOTES:
%   -> See xxxx for more information about exception handling in MAPS.
%   -> generate_MAPS_exception_add_cause_and_throw throws the exception as
%      the caller, which means that the stack will show the line number on
%      which this function was called within the calling function (just as 
%      it would have done if that line had instead contained a throw 
%      command).
%   -> This function is a method which sits around 
%      generate_MAPS_exception_and_add_cause (the function that creates the 
%      MAPS exception). As a result, it leaves most error handling to that 
%      inner method.
%
% This version: 27/01/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check the validity of the inputs and throw an error if they are not as
% expected. 
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});   
end

%% GENERATE MAPS EXCEPTION
% Generate the exception using the generate_MAPS_exception function. The
% call to this function depends on the number of inputs passed in.
if nargin == 2
    MAPSexception = generate_MAPS_exception_and_add_cause(...
        ExceptionCause,errId);
else
    MAPSexception = generate_MAPS_exception_and_add_cause(...
        ExceptionCause,errId,errArgs);
end

%% THROW THE EXCEPTION
% Throw the MAPS exception as the caller to this function (which means the
% stack will point to the line on which this function was called rather 
% than the following line in this function).
throwAsCaller(MAPSexception)

end