function MasterE = add_causes_from_list_to_an_exception(...
    MasterE,errId,errArgsList,causeLogicals)
% This helper adds causes to an exiting exception with appropriate args.
% It uses input logical information to determine how many causes to add and
% which exception arguments should accompany each cause.
%
% INPUTS:
%   -> MasterE: exception to add causes to
%   -> errId: exception identifier for the causes
%   -> errArgsList: cell string array of error arguments
%   -> causeLogicals: column vector of logicals dictating how many causes
%      to ad and which arguments to apply
%
% OUTPUTS:
%   -> MasterE (optional): updated exception
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> is_two_dimensional_cell_string_array
%   -> is_logical_column_vector
%   -> generate_MAPS_exception_and_add_as_cause
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
% This version: 20/09/2012
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 4
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~strcmp(class(MasterE),'MException')
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~ischar(errId)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_two_dimensional_cell_string_array(errArgsList)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_logical_column_vector(causeLogicals)
    errId = ['MAPS:',mfilename,':BadInput4'];
    generate_and_throw_MAPS_exception(errId);   
elseif size(errArgsList,1) ~= size(causeLogicals,1);
    errId = ['MAPS:',mfilename,':InconsistentCauseDims'];
    generate_and_throw_MAPS_exception(errId);
end


%% SET DEFAULT FOR THROWING EXCEPTION
% If user has requested the exception back as an output argument, then do
% not throw the exception. Otherwise, it is thrown below.
if nargout > 0
    throwException = false;
else
    throwException = true;
end

%% CONVERT LOGICALS TO INDICES
causeInds = find(causeLogicals);

%% ADD CAUSES
nCauses = size(causeInds,1);
for iCause = 1:nCauses
    iCauseInd = causeInds(iCause);
    iCauseArgs = errArgsList(iCauseInd,:);
    MasterE = generate_MAPS_exception_and_add_as_cause(...
        MasterE,errId,iCauseArgs);
end

%% THROW EXCEPTION IF REQUIRED
if throwException
    throw(MasterE);
end

end