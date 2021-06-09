function [eqStrTerms,eqStrDelims,eqStrTimeSubs] = split_equation(...
    eqStr,SplitOptions)
% This helper splits an equation string into is constituent parts.
% It uses two configuration files and a time subscript convention in MAPS
% string equations to split the equation input into terms, valid equation 
% delimiters and time subscripts.
%
% INPUTS:
%   -> eqStr: equation string
%   -> SplitOptions (optional): structure of options for the equation split
%
% OUTPUTS:
%   -> eqStrTerms: cell string array of split terms from the equation
%   -> eqStrDelims: cell string array of delimiters found
%   -> eqStrTimeSubs: cell string array of time subscripts for the terms
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> get_valid_mathematical_symbols_for_equations
%   -> get_valid_mathematical_operators_for_equations
%
% DETAILS:
%   -> This helper splits a string equation into its constituent terms (ie 
%      variable and parameter mnemonics), its valid delimiters, and time
%      subscripts associated with each of the terms (eg '{t}' etc).
%   -> The valid delimiters are all valid mathematical symbols & operators
%      for use in MAPS equations (defined by two configurations) and all
%      valid numbers.
%   -> This function uses the MATLAB command "regexp" to do a complicated
%      text scan with several conditions in one command. See below for
%      details and see the "regular expressions" section of the MATLAB
%      programming fundamentals user guide for context and further details.
%
% NOTES:
%   -> This helper is used in the creation of MAPS models. See <>
%      for details.
%   -> The function reconstruct_equation puts a split equation back 
%      together again (i.e. reverses the operation in this equation).
%
% This version: 16/06/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(eqStr)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId); 
elseif nargin>1 && ~isstruct(SplitOptions)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);     
end

%% SETUP SPLIT EQUATION DEFAULT OPTIONS
splitOutNumerics = true;
splitOutOperators = true;
splitOutTimeSubs = true;

%% UNPACK ANY SPLIT EQUATION INSTRUCTIONS PASSED IN
if nargin > 1
    splitOptionFields = fieldnames(SplitOptions);
    nOptionFields = size(splitOptionFields,1);
    for iOption = 1:nOptionFields
        iOptionName = splitOptionFields{iOption};
        iOptionContent = SplitOptions.(iOptionName);
        if ~any(strcmp(iOptionName,{'numerics','operators','timeSubs'}))
            errId = ['MAPS:',mfilename,':BadOptionFieldName'];
            generate_and_throw_MAPS_exception(errId,{iOptionName});
        elseif ~islogical(iOptionContent) || ~isscalar(iOptionContent)
            errId = ['MAPS:',mfilename,':BadOptionField'];
            generate_and_throw_MAPS_exception(errId,{iOptionName});
        elseif strcmp(iOptionName,'numerics')
            splitOutNumerics = iOptionContent;
        elseif strcmp(iOptionName,'operators')
            splitOutOperators = iOptionContent;
        elseif strcmp(iOptionName,'timeSubs')
            splitOutTimeSubs = iOptionContent;
        end
    end
end

%% DEFINE VALID DELIMITERS TO SPLIT EQUATION BY
% Call a configuration to get the valid MAPS equation mathematical
% symbols as a character array (eg '*+' etc). Enclose it in square brackets
% which is regexp shorthand for "or" (eg [+-] is equivalent to +|-).
validMathsSymbols = get_valid_mathematical_symbols_for_equations;
validEqDelims = ['[',validMathsSymbols,']'];

%% DEFINE NUMERIC DELIMITERS (AS REQUESTED)
% Define valid numerical delimiters: a valid number is any number of
% numeric digits ('((\d+)?)'), optionally followed by a decimal place
% ('(\.)?'), optionally followed by any number of numeric digits. Add a
% lookahead and lookbehind condition (see the MATLAB regular expressions
% documentation) to ensure that numbers that follow or preceed an
% alpha-numeric charcater are ignored. This ensures that variables defined
% with numeric digits in them (eg 'alpha0') are not split into two (eg 
% 'alpha' and '0'). 
if splitOutNumerics
    numericDelims = '(?<!\w)((\d+)?(\.)?(\d+)?)(?!\w)';
    validEqDelims = ['((',validEqDelims,')|(',numericDelims,'))'];
end

%% ADD A LOOKAROUND OPERATION IF THERE ARE TIME SUBSCRIPTS IN EQUATION
% This will ensure that does no math symbols that appear in '{}', which are
% used in MAPS to denote time subscripts, are split out. See the MATLAB 
% regular expressions documentation (eg grouping operators and lookaround 
% operators) for more details of how this works.
if any(strfind(eqStr,'{'))
    lookBehindCond = '(?<!{(\w+)?)';
    lookAheadCond = '(?!(\w+)?})';
    validEqDelims = [lookBehindCond,validEqDelims,lookAheadCond];
end

%% SPLIT EQUATION STRING BY VALID DELIMITERS
% Use the MATLAB regexp function to split the equation string by the valid
% mathematical symbols and numerics (as required), leaving any time 
% subscripts as appropriate. 
[eqStrSplit,eqStrDelims] = regexp(eqStr,validEqDelims,'split','match');
eqStrSplit = strtrim(eqStrSplit);
eqStrTerms = eqStrSplit;

%% GET VALID MATHEMATICAL OPERATORS (AS REQUESTED)
% Call a configuration to get the valid mathematical operators for use in
% MAPS. This returns a cell string array of valid operator names (eg 
% {'log','exp'}). Find each one and move them down into the delimiters cell
% array.
if splitOutOperators
    validMathsOperators = get_valid_mathematical_operators_for_equations;
    nValidOperators = size(validMathsOperators,2);
    for iOp = 1:nValidOperators
        eqStrSplitOpInds = find(strcmp(...
            validMathsOperators{iOp},eqStrSplit));
        nEqStrSplitOps = size(eqStrSplitOpInds,2);
        for iiOp = 1:nEqStrSplitOps
            iiOpInd = eqStrSplitOpInds(iiOp)+iiOp-1;
            eqStrDelims = [eqStrDelims(1:iiOpInd-1) ...
                eqStrSplit(iiOpInd) eqStrDelims(iiOpInd:end)];
            eqStrSplit = [eqStrSplit(1:iiOpInd-1) {'' ''} ...
                eqStrSplit(iiOpInd+1:end)];
        end
    end
    eqStrTerms = eqStrSplit;
end

%% SPLIT OUT TIME SUBSCRIPTS (AS REQUESTED)
% Split out the time subscripts from each of the split terms provided that
% an alpha-numeric character appears before the time subscript & provided
% that nothing appears after the time subscript (eg 'x{t}', not 'x{t}y').
% Note that this cell is only executed if the time subscripts output is
% specified or if any open '{' braces can be found in the equation string.
if nargout>2 || splitOutTimeSubs
    [eqStrSplitSplit,eqStrSplitDelims] = regexp(...
        eqStrSplit,'{([^}]+)?}$','split','match');
    eqStrTerms = cellfun(@(x) x{:},eqStrSplitSplit,'UniformOutput',false);
    eqStrSplitDelims(cellfun(@isempty,eqStrSplitDelims)) = {{''}};
    eqStrTimeSubs = cellfun(...
        @(x) x{:},eqStrSplitDelims,'UniformOutput',false);
end

end