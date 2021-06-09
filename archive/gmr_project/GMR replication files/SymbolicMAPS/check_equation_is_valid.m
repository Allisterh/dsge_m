function InvalidEqE = check_equation_is_valid(...
    eqStr,isEqExplicit,InvalidEqE)
% This helper checks that an equation string is valid for use in MAPS.
% It throws or passes out an error if the equation passed in cannot be 
% evaluated in MATLAB.
%
% INPUTS:
%   -> eqStr: equation string
%   -> isEqExplicit (optional): boolean true or false
%   -> InvalidEqE (optional): an exception to add causes to
%
% OUTPUTS:
%   -> InvalidEqE: updated exception
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> generate_MAPS_exception
%   -> split_equation
%   -> generate_MAPS_exception_and_add_as_cause
%   -> prepare_equation_fragment_for_evaluation (sub-function)
%   -> reconstruct_equation
%   -> generate_MAPS_exception_and_add_cause
%
% DETAILS:
%   -> This symbolic MAPS helper checks the validity of an equation string 
%      in MAPS. It does so in three stages.
%   -> First, it checks whether the equation contains the correct number of
%      equals symbols depending on whether the equation should be explicit
%      (if 1 input is passed in or if the 2nd input is set to true) or 
%      implicit (if the 2nd input is set to false) - i.e. aassumed equal to
%      0 (or something) with no equal sign (eg 'x+y').
%   -> Second, it searches for invalid terms. These are terms that cannot 
%      be proper MATLAB variables (eg 'x{y').
%   -> Third, it assigns random numeric values to the (non-numeric,
%      non-operator) terms and attempts to evaluate the equation string.
%   -> If any exceptions were found it will either throw them (if the call
%      to this function did not specify an output argument) or pass the 
%      exception out with all its causes (if the call to this function did
%      not specify an output argument). The exception passed out is either
%      an exception constructed within this function (if only 1 or 2 inputs
%      were passed in) or the exception passed in as the optional 3rd
%      input.
%
% NOTES:
%   -> See <> for a discussion of MAPS symbolic functionality.
%
% This version: 27/04/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and type of input is as expected.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(eqStr)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin>1 && (~islogical(isEqExplicit)||~isscalar(isEqExplicit))
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin>2 && ~strcmp(class(InvalidEqE),'MException')
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
end

%% SETUP DEFAULT FOR EXPLICIT EQUATION BOOLEAN
% If only 1 input was passed in, set the is equation explicit boolean to
% true. That is, the default value for this variable is true.
if nargin < 2
    isEqExplicit = true;
end

%% SETUP A MASTER EXCEPTION
% If only 2 inputs were passed in, setup a master exception to add causes
% to as enocuntered below.
if nargin < 3
    masterErrId = ['MAPS:',mfilename,':InvalidEquation'];
    InvalidEqE = generate_MAPS_exception(masterErrId);
end

%% SPLIT EQUATION
% Split the equation into its constituent terms & delimiters using the 
% symbolic MAPS equation splitter. Note that this will strip any valid time
% subscripts from each term. 
[eqStrTerms,eqStrDelims] = split_equation(eqStr);

%% CHECK & REPLACE EQUAL SYMBOLS
% Check that the number of equal signs in the equation is correct given the
% equation type.
equalSymbolsLogicals = strcmp('=',eqStrDelims);
nEqualSymbols = sum(equalSymbolsLogicals);
if isEqExplicit && nEqualSymbols~=1
    errId = ['MAPS:',mfilename,':WrongNumberOfEqualSignsExplicit'];
    InvalidEqE = generate_MAPS_exception_and_add_as_cause(...
        InvalidEqE,errId,{num2str(nEqualSymbols)});
elseif ~isEqExplicit && nEqualSymbols>0
    errId = ['MAPS:',mfilename,':WrongNumberOfEqualSignsImplicit'];
    InvalidEqE = generate_MAPS_exception_and_add_as_cause(...
        InvalidEqE,errId,{num2str(nEqualSymbols)});
end

%% SEARCH FOR TERMS THAT CANNOT BE ASSIGNED VALUES 
% Check that the equation contains only valid terms that can be setup as 
% MATLAB variables. Throw an error containing details of any unrecognised 
% symbols. These are any non-alpha-numeric-underscore characters (including
% blank spaces) that remain in the split equation. Replace any of those
% with a valid term that can be setup as a MATLAB variable for evaluation
% of the equation string below.
eqStrInvalidTerms = regexp(eqStrTerms,'\W','match');
badInds = find(~cellfun(@isempty,eqStrInvalidTerms));
if ~isempty(badInds)
    errId = ['MAPS:',mfilename,':UnexpectedTerm'];
    errArgs = eqStrTerms(badInds);
    InvalidEqE = generate_MAPS_exception_and_add_as_cause(...
        InvalidEqE,errId,errArgs);
    eqStrTerms(badInds) = {'aTerm'};
end

%% ATTEMPT TO EVALUATE THE EQUATION
% Attempt to evaluate the equation by assigning random (on uniform 0,1) 
% numbers to each of the separate terms in the equation, recombining those 
% terms with the equation delimiters and then attempting to evaluate that
% expression in MATLAB.
prepare_equation_fragment_for_evaluation(eqStrTerms);
eqStrToCheck = reconstruct_equation(eqStrTerms,eqStrDelims);
try
    if nEqualSymbols == 1
        [eqStrToCheckLhs,eqStrToCheckRhs] = ...
            extract_expressions_from_equations(eqStrToCheck);
        eval([eqStrToCheckLhs,';']);
        eval([eqStrToCheckRhs,';']);
    else
        eval([eqStrToCheck,';']);
    end
catch EvalE
    errId = ['MAPS:',mfilename,':InevaluableEquation'];
    InevalEqE = generate_MAPS_exception_and_add_cause(EvalE,errId);
    InvalidEqE = addCause(InvalidEqE,InevalEqE);
end

%% THROW EXCEPTION WITH CAUSES
% If any causes were encountered and the call to this function does not 
% specify an output argument, throw the exception out of this function.
if nargout==0 && ~isempty(InvalidEqE.cause)
    throw(InvalidEqE);
end

end

%% FUNCTION TO CREATE RANDOM DATA
function prepare_equation_fragment_for_evaluation(eqStrTerms)
% This helper creates random data for each term in an equation fragment.
% It is used in the main function above to create random data for all the
% terms on the LHS and RHS of the equation being checked.
%
% INPUTS:
%   -> eqStrTerms: split equation terms
%
% OUTPUTS:
%   -> none
%
% CALLS:
%   -> none

%% ASSIGN RANDOM NUMBERS TO EACH OF THE TERMS
% Assign random numbers to each of the equation terms in the main functions
% workspace.
eqStrTermsNonEmpty = eqStrTerms(~cellfun(@isempty,eqStrTerms));
nTerms = size(eqStrTermsNonEmpty,2);
for iTerm = 1:nTerms
    assignin('caller',eqStrTermsNonEmpty{iTerm},rand)
end

end