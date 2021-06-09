function eqTidyStr = tidy_equation(eqStr)
% This helper simplifies equation strings by removing unnecessary delims.
% It can be used on valid equations to remove superfluous plus symbols,
% minus symbols and parentheses.
%
% INPUTS:
%   -> eqStr: equation string
%
% OUTPUTS:
%   -> eqTidyStr: simplified equation string
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> split_equation
%   -> compute_indices_of_matching_parentheses_in_equation_delimiters 
%      (sub-function)
%   -> update_indices_of_matching_parentheses_in_equation_delimiters 
%      (sub-function)
%   -> reconstruct_equation
%
% DETAILS:
%   -> This function tdies and equation string to remove superfluous
%      parentheses and rationalise consecutive plus and minus symbols.
%   -> The latter is an essential operation for MAPS' symbolic equation
%      rearranger, which relies on the logic that each term in an equation
%      is associatd with just one mathematical symbol or operator.
%   -> For example, an equation string 'y = a+b--c+(d*e)' would become:
%      'y = a+b+c+d*e'.
%
% NOTES:
%   -> See <> for a description of symbolic MAPS.
%   -> Note that this function assumes that the equation is valid. Invalid
%      equations (eg those with unbalanced parentheses) could cause errors. 
%
% This version: 03/07/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and type of inputs is as expected.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(eqStr)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% SPLIT EQUATION
% Use the MAPS equation splitter to split the input equation into terms and
% equation delimiters - mathematical symbols & operators.
SplitOptions = struct('numerics',false,'operators',true,'timeSubs',false);
[eqStrTerms,eqStrDelims] = split_equation(eqStr,SplitOptions);

%% FIND PARENTHESES
% Find where the paentheses are in the equation delimiters.
[openParenInds,closeParenInds,parenInnerInds] = ...
    compute_indices_of_matching_parentheses_in_equation_delimiters(...
    eqStrDelims);

%% REMOVE CONSECUTIVE PARENTHESES
% Remove parentheses that appear one after the other - for example,
% 'a*((x+b))' would become 'a*(x+b)'.
nParens = size(openParenInds,2);
parensRemoved = false(1,nParens);
for iParen = 1:nParens-1
    if (openParenInds(iParen+1)-openParenInds(iParen))==1 && ...
           (closeParenInds(iParen)-closeParenInds(iParen+1))==1
        eqStrDelims(openParenInds(iParen)) = {''};
        eqStrDelims(closeParenInds(iParen)) = {''};
        parensRemoved(iParen) = true;
    end
end

%% REMOVE UNNECESSARY PARENTHESES
% Remove unnecessary parentheses which contain only one term. For example,
% 'a*(b)' would become 'a*b'. Note that, this cell makes allowance for
% operators like log and exp, so that 'log(a)' remains 'log(a)'.
[openParenInds,closeParenInds,parenInnerInds,parensRemoved,nParens] = ...
    update_indices_of_matching_parentheses_in_equation_delimiters(...
    openParenInds,closeParenInds,parenInnerInds,parensRemoved);
for iParen = 1:nParens
    iOpenParenInd = openParenInds(iParen);
    iCloseParenInd = closeParenInds(iParen);
    if sum(~cellfun(...
            @isempty,eqStrTerms(iOpenParenInd+1:iCloseParenInd)))==1 && ...
            (iOpenParenInd==1||...
            ~any(strcmp(eqStrDelims{iOpenParenInd-1},{'exp','log'})))
           eqStrDelims(iOpenParenInd) = {''};
           eqStrDelims(iCloseParenInd) = {''};
           parensRemoved(iParen) = true;
    end
end

%% EXPAND ADDITIVE PARENTHESES
% Expland out parentheses that are preceded by a plus symbol and followed 
% by plus or minus symbols (or nothing if they are at the start or end of 
% the equation string). For example, 'a+(b*c)+d' becomes 'a+b*c+d'.
[openParenInds,closeParenInds,~,parensRemoved,nParens] = ...
    update_indices_of_matching_parentheses_in_equation_delimiters(...
    openParenInds,closeParenInds,parenInnerInds,parensRemoved);
for iParen = 1:nParens
    iOpenParenInd = openParenInds(iParen);
    iCloseParenInd = closeParenInds(iParen);
    if (iOpenParenInd==1||...
            any(strcmp(eqStrDelims{iOpenParenInd-1},{'+','='}))) && ...
            (iCloseParenInd==size(eqStrDelims,2)||...
            any(strcmp(eqStrDelims{iCloseParenInd+1},{'+','-','='})))
        eqStrDelims(iOpenParenInd) = {''};
        eqStrDelims(iCloseParenInd) = {''};
        parensRemoved(iParen) = true;
    end
end

%% REMOVE CONSECUTIVE ADDITIVE TERMS
% Rationalise consecutive plus and minus symbols. This is important for the
% logic in the MAPS equation rearranger, which works under the assumption
% that there is just one mathematical symbol associated with each separate
% term. For example, 'a+++b' becomes 'a+b' and 'a---b' becomes 'a-b'.
plusLogicals = strcmp('+',eqStrDelims);
minusLogicals = strcmp('-',eqStrDelims);
minusAndPlusLogicals = (plusLogicals|minusLogicals);
minusAndPlusInds = find(minusAndPlusLogicals);
nPlusAndMinusSymbols = sum(minusAndPlusLogicals);
for iSymbol = 1:nPlusAndMinusSymbols
    iSymbolInd = minusAndPlusInds(iSymbol);
    if iSymbol < nPlusAndMinusSymbols
        iNextSymbolInd = minusAndPlusInds(iSymbol+1);
        if any(strcmp(...
                [eqStrDelims{iSymbolInd+1:iNextSymbolInd}],{'+','-'}))
            if all(cellfun(...
                    @isempty,eqStrTerms(iSymbolInd+1:iNextSymbolInd)))
                if minusLogicals(iSymbolInd)
                    if plusLogicals(iNextSymbolInd)
                        eqStrDelims(iNextSymbolInd) = {'-'};
                        minusLogicals(iNextSymbolInd) = true;
                        plusLogicals(iNextSymbolInd) = false;                        
                    else                        
                        eqStrDelims(iNextSymbolInd) = {'+'};
                        minusLogicals(iNextSymbolInd) = false;
                        plusLogicals(iNextSymbolInd) = true;
                    end
                end
                eqStrDelims(iSymbolInd) = {''};
            end
        end
    end
end

%% RECONSTRUCT EQUATION
% Put the equation back together again using the MAPS equation
% reconstructer.
eqTidyStr = reconstruct_equation(eqStrTerms,eqStrDelims);

end

%% FUNCTION TO COMPUTE INDEX NUMBERS OF MATCHING OPEN/CLOSE PARENTHESES
function [openParenInds,closeParenInds,parenInnerInds] = ...
    compute_indices_of_matching_parentheses_in_equation_delimiters(...
    eqStrDelims)
% This helper finds the index numbers of matching open/close parentheses.
% It searches the split out equation delimiters cell array of equation
% delimiters for matching open/close parentheses.
%
% INPUTS:
%   -> eqStrDelims: cell string array of equation delimiters
%
% OUTPUTS:
%   -> openParenInds: row vector of open parentheses index numbers
%   -> closeParenInds: row vector of close parentheses index numbers that
%      match the open parentheses index numbers
%   -> parenInnerInds: row cell array of index numbers for the content of
%      each open/close parentheses pair (excluding nested parens)
%
% CALLS:
%   -> none

%% COMPUTE LOGICAL INDICES OF OPEN/CLOSE PARENTHESES
openParenLogicals = strcmp(eqStrDelims,'(');
closeParenLogicals = strcmp(eqStrDelims,')');

%% COMPUTE INDEX NUMBERS OF OPEN PARENTHESES
openParenInds = find(openParenLogicals);

%% SETUP INDEX NUMBERS FOR CLOSE PARENTHESES & INNER PAREN INDICES CELL
nParens = sum(openParenLogicals);
closeParenInds = zeros(1,nParens);
parenInnerInds = cell(1,nParens);

%% COMPUTE INDEX NUMBERS OF CLOSE PARENTHESES & INNER PAREN INDICES
% Loop through the open parentheses. For each one compute the cumulative
% sum of the remaining parentheses scoring remaining open parentheses 1 and
% close parentheses -1. The close parenthesis that matches each open
% parenthesis is then the first number in that sequence of sums that is 
% equal 0. And the index number is equal to that index number plus the 
% position of the open parenthesis from which the cum sum began. The inner
% paren indices are all the indices between the open and close brackets 
% where the cum sum is equal to 1. This strips out nested parens in which
% the cumulative sums must, by definition, exceed 1 as new parens are 
% encountered.
for iParen = 1:nParens
    iOpenParenInd = openParenInds(iParen);
    iParenCounter = cumsum(...
        double(openParenLogicals(iOpenParenInd:end))-...
        double(closeParenLogicals(iOpenParenInd:end)));
    iCloseParenInd = iOpenParenInd-1+find(...
        closeParenLogicals(iOpenParenInd:end)&iParenCounter==0,1,'first');    
    closeParenInds(iParen) = iCloseParenInd;
    parenInnerInds{iParen} = iOpenParenInd+find(...
        iParenCounter(1:iCloseParenInd-iOpenParenInd+1)==1);   
end

end

%% FUNCTION TO UPDATE INDEX NUMBERS OF MATCHING OPEN/CLOSE PARENTHESES
function [openParenIndsNew,closeParenIndsNew,parenInnerIndsNew,...
    parensRemovedNew,nParensNew] = ...
    update_indices_of_matching_parentheses_in_equation_delimiters(...
    openParenInds,closeParenInds,parenInnerInds,parensRemoved)
% This helper updates the index numbers of matching open/close parentheses.
% It removes the index numbers of the parentheses that have been identified 
% as unneccesary and removed from the equation delimiters in the main 
% function above.
%
% INPUTS:
%   -> openParenInds: row vector of open parentheses index numbers
%   -> closeParenInds: row vector of close parentheses index numbers that
%      match the open parentheses index numbers
%   -> parenInnerInds: row cell array of index numbers for the content of
%      each open/close parentheses pair (excluding nested parens)
%   -> parensRemoved: logical vector describing which parentheses have been
%      removed
%
% OUTPUTS:
%   -> openParenIndsNew: row vector of updated open parentheses indices
%   -> closeParenInds: row vector of updated close parentheses indices
%   -> parenInnerInds: updated row cell array of index numbers for the 
%      content of each remaining open/close parentheses pair
%   -> parensRemovedNew: new logical vector to be updated for further
%      removals
%   -> nParensNew: number of parentheses remaining in the equation
%
% CALLS:
%   -> none

%% ADJUST FOR PARENTHESES REMOVED
openParenIndsNew = openParenInds(~parensRemoved);
closeParenIndsNew = closeParenInds(~parensRemoved);
parenInnerIndsNew = parenInnerInds(~parensRemoved);

%% COUNT PARENTHESES & SETUP NEW LOGICAL VECTOR
nParensNew = size(openParenIndsNew,2);
parensRemovedNew = false(1,nParensNew);

end