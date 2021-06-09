function thetaUpdated = update_parameters(...
    Model,thetaUpdate,thetaUpdateIdentifiers,theta,thetaMnems)
% This model helper updates the parameters of a MAPS model. 
% It can be operated in a number of different modes depending on the 
% information passed in, allowing this function to operate at higher and 
% lower levels. 
% 
% INPUTS:
%   -> Model: MAPS model structure
%   -> thetaUpdate: values for the parameters to be updated
%   -> thetaUpdateIdentifiers: identifiers for the parameters to be updated
%      (either index numbers of mnemonics)
%   -> theta (optional): column vector of all parameter values in model
%   -> thetaMnems (optional): column cell string array of all paarameter 
%      mnemonics in model
%
% OUTPUTS:
%   -> thetaUpdated: updated, complete parameter vector for the model
%
% DETAILS:
%   -> This model utility function updates a chosen subset of the model's
%      parameters.
%   -> The parameters to update can be identified by either index numbers
%      (which will be quickest) or mnemonics in which case the index
%      numbers are looked up.
%   -> In addition, the full vector of parameters may be passed in (which
%      saves unpacking them in the update) and the full set of parameter
%      mnemonics which will also save unpacking them to compute the index
%      numbers (if necessary).
%
% NOTES:
%   -> This helper is useful in MAPS LSS model estimation.
%
% This version: 03/12/2012
% Author(s): Matt Waldron

%% CHECK INPUTS
% The compulsory inputs with known format are checked here. The rest of the
% checking happens below.
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
elseif ~is_finite_real_numeric_column_vector(thetaUpdate)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% HANDLE VARIATION IN IDENTIFIERS INPUT
% The identifiers may either be strings (or a single string) in which case
% they must be parameter mnemonics or index numbers in which case they must
% be positive numeric integers.
if ischar(thetaUpdateIdentifiers)
    thetaUpdateMnems = {thetaUpdateIdentifiers};
    identifiersAreMnems = true;
elseif is_column_cell_string_array(thetaUpdateIdentifiers)
    thetaUpdateMnems = thetaUpdateIdentifiers;
    identifiersAreMnems = true;
elseif is_column_vector_of_positive_real_integers(...
        thetaUpdateIdentifiers)
    thetaUpdateInds = thetaUpdateIdentifiers;
    identifiersAreMnems = false;
else
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK IDENTIFIERS DIMS ARE CONSISTENT WITH PARAMETERS
if size(thetaUpdateIdentifiers,1) ~= size(thetaUpdate,1)
    errId = ['MAPS:',mfilename,':IdentifiersParametersDimMismatch'];
    generate_and_throw_MAPS_exception(errId);
end

%% UNPACK PARAMETERS OF MODELS IF NECESSARY & CHECK INPUT IF NOT
if nargin < 4
    theta = unpack_model(Model,{'theta'});
elseif ~is_finite_real_numeric_column_vector(theta)
    errId = ['MAPS:',mfilename,':BadInput4'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK SIZE OF PARAMETER VECTOR IS NOT TOO BIG
if size(thetaUpdate,1) > size(theta,1)
    errId = ['MAPS:',mfilename,':UpdateVectorIsTooLarge'];
    generate_and_throw_MAPS_exception(errId);
end    

%% CONVERT MNEMONICS TO INDEX NUMBERS IF NECESSARY
% If the identifiers passed in were mnemonics, then either unpack the full
% set of the mnemonics from the model if none were provided or check that
% the set provided in the input are valid. Then lookup the index numbers of
% the input identifiers in this full set, catching any errors thrown.
if identifiersAreMnems
    if nargin < 5
        thetaMnems = unpack_model(Model,{'thetaMnems'});
    elseif ~is_column_cell_string_array(thetaMnems) || ...
            size(thetaMnems,1)~=size(theta,1)
        errId = ['MAPS:',mfilename,':BadInput5'];
        generate_and_throw_MAPS_exception(errId);
    end
    try
        thetaUpdateInds = lookup_model_index_numbers(...
            thetaMnems,thetaUpdateMnems);
    catch LookupE
        errId = ['MAPS:',mfilename,':BadMnems'];
        generate_MAPS_exception_add_cause_and_throw(LookupE,errId);
    end
end

%% CHECK INDICES AS APPROPRIATE
% If the identifiers were indices on input, then they cannot exceed the
% range of the parameter vector and must be unique.
if ~identifiersAreMnems
    if max(thetaUpdateInds) > size(theta,1)
        errId = ['MAPS:',mfilename,':IndexIdentifiersOutOfRange'];
        generate_and_throw_MAPS_exception(errId);
    elseif size(unique(thetaUpdateInds),1)~=size(thetaUpdateInds,1)
        errId = ['MAPS:',mfilename,':IndexIdentifiersNonUnique'];
        generate_and_throw_MAPS_exception(errId);        
    end
end

%% UPDATE PARAMETER VECTOR
thetaUpdated = theta;
thetaUpdated(thetaUpdateInds) = thetaUpdate;

end