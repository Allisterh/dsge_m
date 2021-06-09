function MasterE = generate_MAPS_exception_and_add_causes_from_list(...
    masterErrId,errArgsList,causeLogicals,masterErrArgs)
% This helper creates an exception with causes added with appropriate args.
% It builds an exception given the input identifier and then manages the 
% addition of causes using another helper function..
%
% INPUTS:
%   -> masterErrId: identifier to create general exception
%   -> errArgsList: cell string array of error arguments
%   -> causeLogicals: column vector of logicals dictating how many causes
%      to ad and which arguments to apply
%   -> masterErrArgs (optional): arguments to add to general exception 
%
% OUTPUTS:
%   -> MasterE: general exception with causes added
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_row_cell_string_array
%   -> generate_MAPS_exception
%   -> add_causes_from_list_to_an_exception
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
%   -> The exception identifier used for the cause exceptions is assumed to
%      take on a specific format - see below. This means the identifiers 
%      for the corresponding error messages must take on the same specific
%      format or an error will result.
%
% This version: 20/09/2012
% Author(s): Matt Waldron

%% CHECK INPUTS
% Checking of the 2nd and 3rd inputs is left to the inner function call.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(masterErrId)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin > 3 && ~is_row_cell_string_array(masterErrArgs)
    errId = ['MAPS:',mfilename,':BadInput4'];
    generate_and_throw_MAPS_exception(errId);
end

%% CREATE EXCEPTION
if nargin > 3
    MasterE = generate_MAPS_exception(masterErrId,masterErrArgs);
else
    MasterE = generate_MAPS_exception(masterErrId);
end

%% CREATE IDENTIFIER FOR CAUSES
errId = [masterErrId,':Instance'];

%% ADD CAUSES WITH ARGUMENTS FROM LIST
MasterE = add_causes_from_list_to_an_exception(...
    MasterE,errId,errArgsList,causeLogicals);

end