function reEqStr = rearrange_equation(eqStr,varToNormOn)
% This function rearranges an equation to normalise on a specified variable
% It rearranges an equation represented by a string so that the variable
% specified as to normalise on is on the left-hand-side of the equation and
% all other terms are on the right-hand-side.
%
% INPUTS:
%   -> eqStr: equation string
%   -> varToNormOn: variable to normalise on
%
% OUTPUTS:
%   -> reEqStr: rearranged equation string
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> check_equation_is_valid
%   -> split_equation
%   -> generate_MAPS_exception_add_cause_and_throw
%   -> tidy_equation
%   -> extract_expressions_from_equations
%   -> substitute_out_terms_grouped_with_var_to_norm_on (sub-function)
%   -> rearrange_base_equation (sub-function)
%   -> substitute_in_terms_grouped_with_var_to_norm_on (sub-function)
%
% DETAILS:
%   -> This is a symbolic MAPS toolbox function which rearranges a MAPS 
%      string equation to normalise on a specified variable.
%   -> It will rearrange any equation provided that: (i) it is a valid
%      MAPS/MATLAB equation; (ii) the variable to normalise appears only
%      once in the equation.
%   -> It works by recursively iterating through nested parantheses that 
%      contain terms that are grouped with the variable to normalise on. At
%      each stage, it rearranges the simplified, base equation 
%
% NOTES:
%   -> This function was to designed to obviate the need for the symbolic
%      toolbox in inversions using NLBL models in MAPS.
%   -> See <> for more details.
%   -> The latter rule is a restriction that arises because there is no 
%      MAPS function that collects common terms.
%
% This version: 20/05/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(eqStr)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~ischar(varToNormOn)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);    
end

%% CHECK THAT THE EQUATION IS VALID
% Check that the equation is a valid using the check_string_equation helper
% function.
try
    check_equation_is_valid(eqStr);
catch EqValidityE
    errId = ['MAPS:',mfilename,':InvalidEquation'];
    generate_MAPS_exception_add_cause_and_throw(EqValidityE,errId,{eqStr});
end
    
%% CHECK THAT THE EQUATION CONTAINS THE TERM TO NORMALISE ON
% Check that the equation contains one and only one instance of the term to 
% normalise by since its obviously not possible to re-arrange an equation
% for a term that does not exist in the equation!
eqStrSplit = split_equation(eqStr);
if sum(strcmp(eqStrSplit,varToNormOn)) ~= 1
    errId = ['MAPS:',mfilename,':WrongVarToNormOn'];
    generate_and_throw_MAPS_exception(errId,...
        {eqStr num2str(sum(strcmp(eqStrSplit,varToNormOn))) varToNormOn});
end

%% SIMPLIFY THE EQUATION
% Simplify the equation using MAPS simplify_string_equation helper. This
% removes any unnecessary parantheses (eg 'Y = (x)/b' becomes 'Y=x/b') and 
% rationalises sequential addition and subtraction symbols (eg 'Y=a--b' 
% becomes 'Y=a+b').
eqStr = tidy_equation(eqStr);

%% SETUP REARRANGED EQUATION LHS & RHS
% Split the input equation to find the LHS & RHS. Setup the rearranged
% equation so that the variable to normalise on appears on the
% left-hand-side.
[eqStrLhs,eqStrRhs] = extract_expressions_from_equations(eqStr);
eqStrLhsSplit = split_equation(eqStrLhs);
if any(strcmp(varToNormOn,eqStrLhsSplit))
    reEqStrLhs = eqStrLhs;
    reEqStrRhs = eqStrRhs;
else
    reEqStrLhs = eqStrRhs;
    reEqStrRhs = eqStrLhs;    
end

%% DEFINE A NORMALISATION REPLACEMENT TERM
% Define a term to use to replace inner functions of the equation string.
% For example, if the equation is '100*(x-a) = y' and the aim is to 
% normalise on 'x', then the 1st part of the algorithm below would replace
% the term in parantheses: '100*[x] = y'. The algorithm would then proceed
% to rearrange the equation such that: '[x] = y/100'. It would then
% substitute '(x-a)' back in: '(x-a) = y/100' before restarting. In the
% next iteration it would susbtitute out 'x' with '[x]' rearrange to leave
% only '[x]', before finishing. Note that the use of square brackets (or 
% something equivalent - eg '!x!' here is necessary because square brackets
% cannot be used in valid MAPS equations, which means that the term '[x]' 
% cannot ever be confused with a valid equation term.
varToNormOnRepTerm = '[x]';

%% REARRANGE EQUATION
% Loop through the equation, rearranging terms until the only term
% remaining on the left-hand-side is the variable to normalise on. Each
% iteration completes three operations. First, all terms grouped with the
% variable to normalise on are aggregated together and replaced with the
% replacment terms specified above. For example, if the equation to
% rearrange is 'a+b*(c-d*log(x^e)/f) = y', the whole term in parantheses 
% will be replaced to give 'a+b*([varToNormOnRepTerm]) = y'. Second, that
% base equation is rearranged to give: '[varToNormOnRepTerm] = (y-a)/b'.
% Third, the original expression containing the variable to normalise on
% that was susbstituted out in the first step is substituted back in to
% give 'c-d*log(x^e)/f = (y-a)/b'. This procedure is repeated for another
% two iterations until the only variable remaining on the left-hand-side is
% the variable to normalise on, 'x'.
while ~strcmp(reEqStrLhs,varToNormOn)    
    [eqStrLhsVarToNormOnRep,exprReplaced] = ...
        substitute_out_terms_grouped_with_var_to_norm_on(...
        reEqStrLhs,varToNormOn,varToNormOnRepTerm);
    [reEqStrLhsVarToNormOnRep,reEqStrRhs] = rearrange_base_equation(...
        eqStrLhsVarToNormOnRep,reEqStrRhs,varToNormOnRepTerm);
    reEqStrLhs = substitute_in_terms_grouped_with_var_to_norm_on(...
        reEqStrLhsVarToNormOnRep,exprReplaced,varToNormOnRepTerm);       
end

%% PUT THE REARRANGED EQUATION BACK TOGETHER
% Put the rearranged equation back together again.
reEqStrRhs = tidy_equation(reEqStrRhs);
reEqStr = [reEqStrLhs,'=',reEqStrRhs];

end

%% FUNCTION TO REARRANGE SUBSTITUTED EQUATION
function [reEqStrLhs,reEqStrRhs] = rearrange_base_equation(...
    eqStrLhs,eqStrRhs,varToNormOn)
% This helper rearranges a simplified equation for the specified variable.
% It rearranges a simplified, base equation in which the variable to
% normalise on has been aggregated together with all terms that are grouped
% with it in nested parantheses. It contains all the logic of how to
% rearrange an equation including how to invert particular operations and
% the order in which to do that.
%
% INPUTS:
%   -> eqStrLhs: equation LHS string
%   -> eqStrRhs: equation RHS string
%   -> varToNormOn: variable to normalise on
%
% OUTPUTS:
%   -> reEqStrLhs: rearranged equation LHS string
%   -> reEqStrRhs: rearranged equation RHS string
%
% CALLS:
%   -> substitute_out_expressions_in_parantheses (sub-function)
%   -> substitute_in_expressions_in_parantheses (sub-function)
%   -> split_equation
%   -> reconstruct_equation
%   -> generate_and_throw_MAPS_exception

%% SETUP OUTPUT
% Setup the output be assigning the rearranged equation RHS equal to the
% input (non-rearranged) equation RHS.
reEqStrRhs = eqStrRhs;

%% REPLACE TERMS IN PARANTHESES ON THE LHS OF THE EQUATION
% Substitute out all terms in parantheses with a placeholder aggregate 
% term, taking into account nested constructs. For example, 'a*(b+c*(d-e))'
% is converted to 'a*([AggregatedTerm1])' since the multiplication 
% operation stands regardless of the content of the parantheses.
[eqStrLhsSubs,exprsReplaced,replacementTerms] = ...
    substitute_out_expressions_in_parantheses(eqStrLhs);

%% SUBSTITUTE VARIABLE TO NORMALISE ON BACK IN
% If any of the expressions replaced in the above step include the variable
% to normalise the equation on, susbtitute that variable back into the
% equation.
if any(strcmp(varToNormOn,exprsReplaced))
    eqStrLhsSubs = substitute_in_expressions_in_parantheses(...
        eqStrLhsSubs,exprsReplaced(strcmp(varToNormOn,exprsReplaced)),...
        replacementTerms(strcmp(varToNormOn,exprsReplaced)));
end

%% AUGMENT EQUATION WITH A PLUS SYMBOL
% If the LHS of the equation does not begin with a '+' or '-' symbol, 
% augment it with a '+' symbol. This ensures that all additive terms look 
% the same in the equation because they are all preceded by a '+' or a '-'
% (eg 'a+b-c*x' becomes '+a+b-c*x'). 
if ~any(strcmp(eqStrLhsSubs(1),{'-','+'}))
    eqStrLhsSubs = ['+',eqStrLhsSubs];
end

%% SPLIT EQUATION
% Use the MAPS equation splitter function to split the equation into terms
% and equation delimiters (like '+', '-' etc).
[eqStrLhsTerms,eqStrLhsDelims] = split_equation(eqStrLhsSubs);

%% FIND INDEX NUMBER OF VARIABLE TO NORMALISE ON
% Find the index number of the variable to be normalised on in the split
% out terms.
varToNormOnInd = find(strcmp(varToNormOn,eqStrLhsTerms));

%% REARRANGE ADDITIVE TERMS
% Find all additions & subtractions on the equation LHS. For each term
% found, move it over to the other side of the equation by taking all terms
% that appear between two additive symbols, reconstructing them into a
% single string and then adding them on the RHS of the equation with the
% symbol inverted (i.e. '+' becomes '-' and '-' becomes '+'). Note that if
% the variable to normalise on appears between the '+' or '-' symbol and
% the next '+' or '-' symbol, the terms are not moved over to the RHS since
% the purpose of this function is to nornalise on that variable! For
% example, if the equation LHS is '+a+b-x+d' and the RHS is 'y', then by 
% the end of this cell the LHS is '-x' and the RHS is 'y-a-b-d'.
plusLogicals = strcmp('+',eqStrLhsDelims);
minusLogicals = strcmp('-',eqStrLhsDelims); 
minusAndPlusLogicals = (plusLogicals|minusLogicals);
minusAndPlusLogicalsAug = [minusAndPlusLogicals true];
minusAndPlusInds = find(minusAndPlusLogicalsAug);
nPlusAndMinusSymbols = sum(minusAndPlusLogicals);
for iSymbol = 1:nPlusAndMinusSymbols
    iSymbolInd = minusAndPlusInds(iSymbol);
    iNextSymbolInd = minusAndPlusInds(iSymbol+1);
    if ~(iSymbolInd<varToNormOnInd&&iNextSymbolInd>=varToNormOnInd)
        if iSymbolInd==1 || ~(...
                any(strcmp(eqStrLhsDelims{iSymbolInd-1},{'^','/','*'}))...
                &&isempty(eqStrLhsTerms{iSymbolInd}))            
            if plusLogicals(iSymbolInd)
                eqStrLhsDelims{iSymbolInd} = '-';
            else
                eqStrLhsDelims{iSymbolInd} = '+';
            end
            reEqStrRhs = [reEqStrRhs,reconstruct_equation(...
                [eqStrLhsDelims(iSymbolInd:iNextSymbolInd-1) {''}],...
                eqStrLhsTerms(iSymbolInd+1:iNextSymbolInd))];               %#ok<AGROW>
            eqStrLhsDelims(iSymbolInd:iNextSymbolInd-1) = {''};
            eqStrLhsTerms(iSymbolInd+1:iNextSymbolInd) = {''};
        end
    end
end

%% GET RID OF ANY REMAINING PLUS TERMS
% Remove any remaining '+' symbols from the list of equation delimiters.
% This step is necessary and is a consequence of possibly having added a 
% '+' term before splitting the LHS equation string above. For example,
% that step could have left the following: 'a*x' to '+a*x'. This removes
% the '+' symbol to get back to 'a*x'.
eqStrLhsDelims(strcmp('+',eqStrLhsDelims)) = {''};

%% REARRANGE TRAILING MULTIPLICATIVE TERMS
% Rearrange traling multiplicative terms. These are '*' and '/' operations
% that appear after the variable to normalise on: 'x*a' or 'x*a/b' etc.
% The logic is very similar to the logic of the additive terms
% rearrangement above.
timesLogicals = strcmp('*',eqStrLhsDelims);
divideLogicals = strcmp('/',eqStrLhsDelims);
timesAndDivideLogicals = (timesLogicals|divideLogicals);
timesAndDivideLogicalsAug = [timesAndDivideLogicals true];
timesAndDivideInds = find(timesAndDivideLogicalsAug);
nTimesAndDivideSymbols = sum(timesAndDivideLogicals);
for iSymbol = 1:nTimesAndDivideSymbols
    iSymbolInd = timesAndDivideInds(iSymbol);
    iNextSymbolInd = timesAndDivideInds(iSymbol+1);
    if iSymbolInd>=varToNormOnInd
        if timesLogicals(iSymbolInd)
            eqStrLhsDelims{iSymbolInd} = '/';
        else
            eqStrLhsDelims{iSymbolInd} = '*';
        end
        reEqStrRhs = ['(',reEqStrRhs,')',reconstruct_equation(...
            [eqStrLhsDelims(iSymbolInd:iNextSymbolInd-1) {''}],...
            eqStrLhsTerms(iSymbolInd+1:iNextSymbolInd))];                   %#ok<AGROW>
        eqStrLhsDelims(iSymbolInd:iNextSymbolInd-1) = {''};
        eqStrLhsTerms(iSymbolInd+1:iNextSymbolInd) = {''};        
    end
end

%% REARRANGE LEADING MULTIPLICATIVE TERMS
% This cell rearranges all multiplicative terms that appear before the
% variable to normalise on. The logic hers is slightly different. Instead 
% of addition/subtracting/multiplying/dividing one term at a time, this 
% cell takes any '/' or '*' symbol that appears nearest to the variable to
% normalise on, then inverts all the terms in front of that symbol (eg 
% if the LHS is 'log(a)*b*c/x' and the RHS 'y', after this cell they will 
% become 'log(a)*b*c/(y)'.
timesLogicals = strcmp('*',eqStrLhsDelims);
divideLogicals = strcmp('/',eqStrLhsDelims);
timesAndDivideLogicals = (timesLogicals|divideLogicals);
timesAndDivideBeforeVarToNormOnInd = find(...
    timesAndDivideLogicals(1:varToNormOnInd-1),1,'last');
if ~isempty(timesAndDivideBeforeVarToNormOnInd)
    if timesLogicals(timesAndDivideBeforeVarToNormOnInd)
        reEqStrRhs = ['(',reEqStrRhs,')/(',reconstruct_equation(...
            eqStrLhsTerms(1:timesAndDivideBeforeVarToNormOnInd),...
            eqStrLhsDelims(1:timesAndDivideBeforeVarToNormOnInd-1)),')'];
    else
        reEqStrRhs = ['(',reconstruct_equation(...
            eqStrLhsTerms(1:timesAndDivideBeforeVarToNormOnInd),...
            eqStrLhsDelims(1:timesAndDivideBeforeVarToNormOnInd-1)),...
            ')/(',reEqStrRhs,')'];
    end
    eqStrLhsTerms(1:timesAndDivideBeforeVarToNormOnInd) = {''};
    eqStrLhsDelims(1:timesAndDivideBeforeVarToNormOnInd) = {''};    
end

%% REARRANGE TRAILING POWER TERMS
% This cell rearranges trailing power terms, one-by-one. For example, if
% the LHS is 'x^a^b' and the RHS 'y', then the LHS would become 'x' and the
% RHS would become 'y^(1/a)^(1/b)'.
powerLogicals = strcmp('^',eqStrLhsDelims);
powerLogicalsAug = [powerLogicals true];
powerInds = find(powerLogicalsAug);
nPowerSymbols = sum(powerLogicals);
for iSymbol = 1:nPowerSymbols
    iSymbolInd = powerInds(iSymbol);
    iNextSymbolInd = powerInds(iSymbol+1);    
    if iSymbolInd>=varToNormOnInd
        reEqStrRhs = ['(',reEqStrRhs,')^(1/',reconstruct_equation(...
            [{''} eqStrLhsDelims(iSymbolInd+1:iNextSymbolInd-1) {''}],...
            eqStrLhsTerms(iSymbolInd+1:iNextSymbolInd)),')'];               %#ok<AGROW>
        eqStrLhsDelims(iSymbolInd:iNextSymbolInd-1) = {''};
        eqStrLhsTerms(iSymbolInd+1:iNextSymbolInd) = {''};        
    end
end

%% REARRANGE LEADING POWER TERMS
% Rearrange leading power terms. This cell works in a similar way to the
% leading multiplicative terms cell. For example, 'a^x' becomes 'x' and if
% the RHS was 'y', it becomes log(y)/log(a).
powerLogicals = strcmp('^',eqStrLhsDelims);
powerBeforeVarToNormOnInd = find(...
    powerLogicals(1:varToNormOnInd-1),1,'last');
if ~isempty(powerBeforeVarToNormOnInd)
    reEqStrRhs = ['log(',reEqStrRhs,')',...
        '/log(',reconstruct_equation(...
        eqStrLhsTerms(1:powerBeforeVarToNormOnInd),...
        eqStrLhsDelims(1:powerBeforeVarToNormOnInd-1)),')'];
    eqStrLhsTerms(1:powerBeforeVarToNormOnInd) = {''};
    eqStrLhsDelims(1:powerBeforeVarToNormOnInd) = {''};    
end

%% DEAL WITH REMAINING LEADING OPERATORS
% Finally, invert all remaining leading operators. The only possible
% remaining operators are '-', 'log' and 'exp'. For each one found, invert
% it in an appropriate way.
for iDelim = 1:varToNormOnInd-1
    switch eqStrLhsDelims{iDelim}
        case '-'
            reEqStrRhs = ['-(',reEqStrRhs,')'];                                 %#ok<AGROW>
            eqStrLhsDelims{iDelim} = '';                    
        case 'log'
            reEqStrRhs = ['exp(',reEqStrRhs,')'];                               %#ok<AGROW>
            eqStrLhsDelims{iDelim} = '';
        case 'exp'
            reEqStrRhs = ['log(',reEqStrRhs,')'];                               %#ok<AGROW>
            eqStrLhsDelims{iDelim} = '';
    end
end

%% REMOVE ANY REMAINING PARANTHESES
% Remove any remaining parantheses from the equation left-hand-side.
eqStrLhsDelims(strcmp('(',eqStrLhsDelims)) = {''};
eqStrLhsDelims(strcmp(')',eqStrLhsDelims)) = {''};

%% RECONSTRUCT EQUATION LHS
% Reconsruct the equation left-hand-side. Check that the only term
% remaining is the variable to normalise on. If it isn't, then this
% function has failed, so throw an exception.
reEqStrLhs = reconstruct_equation(eqStrLhsTerms,eqStrLhsDelims);
if ~strcmp(reEqStrLhs,varToNormOn)
    errId = ['MAPS:',mfilename,':BadEqRearrangement'];
    generate_and_throw_MAPS_exception(errId,{eqStrLhs varToNormOn});
end

%% SUBSTITUTE AGGREGATED TERMS BACK IN TO EQUATION RHS
% Substitute any aggregated terms that were grouped together at the start
% of this function back into the equation RHS.
reEqStrRhs = substitute_in_expressions_in_parantheses(...
    reEqStrRhs,exprsReplaced,replacementTerms);

end

%% FUNCTION TO SUBSTITUTE OUT TERMS GROUPED WITH VARIABLE TO NORMALISE ON
function [eqStrWithNormTermExprSubsOut,exprReplaced] = ...
    substitute_out_terms_grouped_with_var_to_norm_on(...
    eqStr,varToNormOn,replacementTerm)
% This helper substitutes out terms grouped with variable to normalise on.
% It finds all terms that appear inside parantheses with the variable to 
% normalise on with a pre-designated replacement term.
%
% INPUTS:
%   -> eqStr: equation string
%   -> varToNormOn: variable to normalise on
%   -> replacementTerm: term to replace the inner functions with
%
% OUTPUTS:
%   -> eqStrWithNormTermExprSubsOut: equation string with the expression 
%      made up of terms grouped with the variable to normalise on 
%      substituted out. 
%
% CALLS:
%   -> split_equation
%   -> find_indices_of_outer_parantheses_in_equation_delimiters
%   -> reconstruct_equation

%% SPLIT EQUATION
% Split the equation into its constituent terms and delimiters.
[eqStrTerms,eqStrDelims] = split_equation(eqStr);

%% FIND NESTED PARANTHESES CONSTRUCTS
% Find the index numbers in the equation delimiters of the open and close
% outer parantheses in nested constructs.
[outOpenParanInds,outCloseParanInds] = ...
    find_indices_of_outer_parantheses_in_equation_delimiters(eqStrDelims);

%% FIND VARIABLE TO NORMALISE ON
% Find the index number of the variable to normalise on in the split
% equation terms.
varToNormOnInd = find(strcmp(varToNormOn,eqStrTerms));

%% FIND OUT OF THE VARIABLE TO NORMALISE ON APPEARS IN NESTED PARANTHESES
% Find the index number of the parantheses location indices between which
% the variable to normalise on appears. If the variable to normalise on
% does not appear in parantheses, then this will return empty.
varToNormOnOuterParansIndsInd = find(...
    varToNormOnInd>outOpenParanInds&...
    varToNormOnInd<=outCloseParanInds);

%% REPLACE VARIABLE TO NORMALISE ON
% If the variable to normalise on does not appear in parantheses, replace
% it with the replacement term. If it does, collect the terms that are
% grouped with it to return as output and replace them with the replacement
% term.
if isempty(varToNormOnOuterParansIndsInd)
    exprReplaced = eqStrTerms{varToNormOnInd};
    eqStrTerms{varToNormOnInd} = replacementTerm;
else
    openParanInd = outOpenParanInds(varToNormOnOuterParansIndsInd);
    closeParanInd = outCloseParanInds(varToNormOnOuterParansIndsInd);    
    exprReplaced = reconstruct_equation(...
        eqStrTerms(openParanInd+1:closeParanInd),...
        eqStrDelims(openParanInd+1:closeParanInd-1));       
    eqStrTerms(openParanInd+1:closeParanInd) = {''};   
    eqStrDelims(openParanInd+1:closeParanInd-1) = {''};
    eqStrTerms{openParanInd+1} = replacementTerm;   
end

%% RECONSTRUCT EQUATION
% Reconstruct the equation with the expression substituted out for output 
% to this function.
eqStrWithNormTermExprSubsOut = reconstruct_equation(...
    eqStrTerms,eqStrDelims);

end

%% FUNCTION TO SUBSTITUTE IN TERMS GROUPED WITH VARIABLE TO NORMALISE ON
function eqStr = substitute_in_terms_grouped_with_var_to_norm_on(...
    eqStrWithNormTermExprSubsOut,exprReplaced,replacementTerm)
% This helper substitutes in terms grouped with variable to normalise on.
% It reverses the operation in the sister function which substitutes terms
% out.
%
% INPUTS:
%   -> eqStrWithNormTermExprSubsOut: equation string with the expression 
%      made up of terms grouped with the variable to normalise on 
%      substituted out
%   -> exprReplaced: expression replaced
%   -> replacementTerm: term to replace the expression
%
% OUTPUTS:
%   -> eqStr: equation string
%
% CALLS:
%   -> substitute_in_expressions_in_parantheses (sub-function)

%% CALL HELPER SUB-FUNCTION
% Call the general helper sub-function below (which will substitute any
% as many terms back in as were replaced).
eqStr = substitute_in_expressions_in_parantheses(...
    eqStrWithNormTermExprSubsOut,{exprReplaced},{replacementTerm});

end

%% FUNCTION TO SUBSTITUTE OUT EXPRESSIONS IN PARANTHESES
function [eqStrWithExprsSubsOut,exprsReplaced,replacementTerms] = ...
    substitute_out_expressions_in_parantheses(eqStr)
% This helper susbstitutes out expressions in parantheses from an equation.
% It replaces expressions in parantheses (and nested parantheses) with an 
% aggregated term that is used as a place holder to represent them. It 
% replaces as many expressions as there are nested parantheses constructs 
% in the equation. See also substitute_in_expressions_in_parantheses which
% reverses the operation in this function.
%
% INPUTS:
%   -> eqStr: equation string
%
% OUTPUTS:
%   -> eqStrWithExprsSubsOut: rewritten equation string with subs made
%   -> exprsReplaced: cell array of terms replaced
%   -> replacementTerms: cell array of terms used to replace expressions in
%      parantheses
%
% CALLS:
%   -> split_equation
%   -> find_indices_of_outer_parantheses_in_equation_delimiters
%      (sub-function)
%   -> reconstruct_equation

%% SPLIT EQUATION
% Split the equation into its constituent terms and delimiters.
[eqStrTerms,eqStrDelims] = split_equation(eqStr);

%% FIND NESTED PARANTHESES CONSTRUCTS
% Find the index numbers in the equation delimiters of the open and close
% outer parantheses in nested constructs 
[outOpenParanInds,outCloseParanInds] = ...
    find_indices_of_outer_parantheses_in_equation_delimiters(eqStrDelims);

%% SETUP OUTPUT
% Compute the number of nested constructs and setup the cell array outputs
% accordingly.
nParanConstructs = size(outOpenParanInds,2);
exprsReplaced = cell(nParanConstructs,1);
replacementTerms = cell(nParanConstructs,1);

%% REPLACE EXPRESSIONS IN NESTED CONSTRUCTS
% Replace the expressions in each of the nested constructs with a
% placeholder ('[aggregatedTerm1]' etc). Save the expressions replaced and
% the replacement terms to the output cell arrays setup above.
for iConstruct = 1:nParanConstructs
    iOpenParanInd = outOpenParanInds(iConstruct);
    iCloseParanInd = outCloseParanInds(iConstruct);
    exprsReplaced{iConstruct} = reconstruct_equation(...
        eqStrTerms(iOpenParanInd+1:iCloseParanInd),...
        eqStrDelims(iOpenParanInd+1:iCloseParanInd-1));       
    eqStrTerms(iOpenParanInd+1:iCloseParanInd) = {''};   
    eqStrDelims(iOpenParanInd+1:iCloseParanInd-1) = {''};
    replacementTerms{iConstruct} = ...
        ['[aggregatedTerm',num2str(iConstruct),']'];
    eqStrTerms(iOpenParanInd+1) = replacementTerms(iConstruct);
end

%% RECONSTRUCT EQUATION
% Reconstruct the equation with the expressions substituted out for output
% to this function.
eqStrWithExprsSubsOut = reconstruct_equation(eqStrTerms,eqStrDelims);

end

%% FUNCTION TO SUBSTITUTE IN EXPRESSIONS IN PARANTHESES
function eqStr = substitute_in_expressions_in_parantheses(...
    eqStrWithExprsSubsOut,exprsReplaced,replacementTerms)
% This helper susbstitutes in expressions in parantheses into an equation.
% It reverses the operation in substitute_out_expressions_in_parantheses by 
% replacing the aggregated terms that were used to represent 
% expressions in parantheses (and nested parantheses) with the original 
% expressions that were substituted out.
%
% INPUTS:
%   -> eqStrWithExprsSubsOut: equation string
%   -> exprsReplaced: cell array of expressions replaced
%   -> replacementTerms: cell array of terms used to represent those 
%      expressions
%
% OUTPUTS:
%   -> eqStr: equation string with expressions substituted back in
%
% CALLS:
%   -> split_equation
%   -> reconstruct_equation

%% SPLIT EQUATION
% Split the equation into its constituent terms and delimiters.
[eqStrTerms,eqStrDelims] = split_equation(eqStrWithExprsSubsOut);

%% REPLACE AGGREGATED TERMS WITH EXPRESSIONS
% Find each of the terms used to represent an expression and substitute the
% expression which that terms was used to represent back into the equation.
nReplacementTerms = size(replacementTerms,1);
for iTerm = 1:nReplacementTerms
    termToSubsLogicals = strcmp(replacementTerms{iTerm},eqStrTerms);
    eqStrTerms(termToSubsLogicals) = exprsReplaced(iTerm);
end

%% RECONSTRUCT EQUATION
% Put the equation back together again.
eqStr = reconstruct_equation(eqStrTerms,eqStrDelims);

end

%% FUNCTION TO FIND INDICES OF OUTER PARANTHESES IN EQUATION DELIMITERS
function [outOpenParanInds,outCloseParanInds] = ...
    find_indices_of_outer_parantheses_in_equation_delimiters(eqStrDelims)
% This helper finds the index numbers of parantheses constructs.
% It searches the equation string delimters in a split equation and finds
% the index numbers of the outer open parantheses in nested constructs and
% the corresponding outer closed parantheses.
%
% INPUTS:
%   -> outOpenParanInds: index numbers of outer open parantheses
%   -> outCloseParanInds: index numbers of outer close parantheses
%
% OUTPUTS:
%   -> eqStrDelims: cell string array of equation delimiters
%
% CALLS:
%   -> none

%% COMPUTE LOGICAL INDICES OF OPEN & CLOSE PARANTHESES
% Use "strcmp" to compute the logical indices of all the open and close
% parantheses.
openParanLogicals = strcmp(eqStrDelims,'(');
closeParanLogicals = strcmp(eqStrDelims,')');

%% CREATE A COUNTER OF PARANTHESES CONSTRUCTS
% Setup a counter used to identify where the nested parantheses exist. This
% counter is constructed by taking a cumulative sum (using the statistics
% toolobox function cumsum) of the open parantheses logicals minus the
% close paranthese logicals. For example, the construct '(())' would be
% captured in the counter as [1 2 1 0].
paranCounter = cumsum(...
    double(openParanLogicals)-double(closeParanLogicals));

%% FIND OPEN & CLOSE PARANTHESES INDEX NUMBERS
% Use thc ounter to find the index numbers of the open and close outer
% paranthese by finding the intersection of the counter equal 1 with the
% positions of the open parantheses (because non-parantheses equation
% delimiters will show up as 0s in the logicals) and the intersection of
% the counter equal 0 with the close parantheses.
outOpenParanInds = find((openParanLogicals&paranCounter==1));
outCloseParanInds = find((closeParanLogicals&paranCounter==0));

end