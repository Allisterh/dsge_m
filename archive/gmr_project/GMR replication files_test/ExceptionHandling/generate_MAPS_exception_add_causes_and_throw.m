function generate_MAPS_exception_add_causes_and_throw(...
    masterErrId,errArgsList,causeLogicals,masterErrArgs)
% This helper throws an exception with causes added with appropriate args.
% It builds an exception given the input identifier, manages the addition
% of causes using another helper function and then throws it.
%
% INPUTS:
%   -> masterErrId: identifier to create general exception
%   -> errArgsList: cell string array of error arguments
%   -> causeLogicals: column vector of logicals dictating how many causes
%      to ad and which arguments to apply
%   -> masterErrArgs (optional): arguments to add to general exception 
%
% OUTPUTS:
%   -> none
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> generate_MAPS_exception_and_add_causes_from_list
%
% DETAILS:
%   -> This helper is used in validation throughout MAPS. 
%   -> In many validation scenarios, particularly those in model file and
%      add-on validation, the object of the exercise is to inform users of
%      errors they have made. Often this involves adding specific error
%      cases as cause to a more general error.
%   -> For example, mnemonics must be unique in MAPS model files. If they 
%      are not, MAPS creates an exception informing users of the rule and 
%      informing users which mnemonics were repeated and the line numbers 
%      those repeats appeared on.
%
% NOTES:
%   -> See MAPS documentation for more information about validation and
%      error handling in MAPS.
%
% This version: 05/10/2012
% Author(s): Matt Waldron

%% CHECK INPUTS
% Checking of all inputs is left to the inner function call.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
end

%% CREATE EXCEPTION
if nargin > 3
    MasterE = generate_MAPS_exception_and_add_causes_from_list(...
        masterErrId,errArgsList,causeLogicals,masterErrArgs);
else
    MasterE = generate_MAPS_exception_and_add_causes_from_list(...
        masterErrId,errArgsList,causeLogicals);
end

%% THROW EXCEPTION
throw(MasterE);

end