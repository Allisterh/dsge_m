function generate_and_throw_MAPS_exception(errId,errArgs)
% This function creates and throws a MAPS exception given an error ID.
% It is an additional method on top of generate_MAPS_exception that can be 
% used to generate a MAPS exception and throw it in once command.
%
% INPUTS:   
%   -> errId: string representing the MAPS exception identifier
%   -> errArgs: optional cell array of additional message arguments
%
% OUTPUTS:
%   -> none 
%
% CALLS:  
%   -> generate_MAPS_exception
%
% DETAILS:
%   -> The identifiers are structured in the following way:
%       'MAPS:<functionName>:<errorCode>'; or 
%       'MAPS:<functionName>:<errorCode1>:<errorCode2>' etc
%   -> This function calls generate_MAPS_exception which creates a MAPS 
%      exception from the documented list.
%   -> Error messages can be supplemented with additional errArgs,
%      which can be used to provide more specific information about the
%      particular instance of the error.
%
% NOTES:
%   -> See xxxx for more information about exception handling in MAPS.
%   -> generate_and_throw_MAPS_exception throws the exception as the
%      caller, which means that the stack will show the line number on
%      which this function was called within the calling function (just as 
%      it would have done if that line had instead contained a throw 
%      command).
%   -> This function is a method which sits around generate_MAPS_exception 
%      (the function that creates the MAPS exception). As a result, it 
%      leaves most error handling to that inner method.
%   -> Note that the error messages relating to this function are 
%      constructed directly rather than by calling this function again. 
%      This is to avoid the possibility of getting stuck in an infinite 
%      loop were the same error is exposed over and over again.
%
% This version: 27/01/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check the validity of the inputs and throw an error if they are not as
% expected. 
if nargin < 1
    error('MAPS:generate_and_throw_MAPS_exception:BadNargin',...
        ['generate_and_throw_MAPS_exception was not passed enough ',...
        'inputs: it requires either 1 or 2 inputs (if optional error ',...
        'arguments are passed in)'])
end

%% GENERATE MAPS EXCEPTION
% Generate the exception using the generate_MAPS_exception function. The
% call to this function depends on the number of inputs passed in.
if nargin == 1
    MAPSexception = generate_MAPS_exception(errId);
else
    MAPSexception = generate_MAPS_exception(errId,errArgs);
end

%% THROW THE EXCEPTION
% Throw the MAPS exception as the caller to this function (which means the
% stack in the exception will point to the line on which this function was 
% called rather than the following line).
throwAsCaller(MAPSexception)

end