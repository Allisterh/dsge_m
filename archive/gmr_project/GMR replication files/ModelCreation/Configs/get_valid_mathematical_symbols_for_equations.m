function validMathsSymbols = get_valid_mathematical_symbols_for_equations
% This configuration defines the valid symbols for use in MAPS equations.
%
% INPUTS:   
%   -> none
%
% OUTPUTS:  
%   -> validMathsSymbols: a character array of mathematical symbols
%
% CALLS:
%   -> none
%
% DETAILS:
%   -> The configuration defines the valid mathematical symbols for use in
%      MAPS equations.
%   -> These symbols can be used as equation delimiters to split the
%      equations into their constituent parts.
%
% NOTES:
%   -> See XXXXXXXX for details of the rules and format of MAPS linear 
%      model files.
%
% This version: 15/02/2011
% Author(s): Matt Waldron

%% DEFINE VALID SYMBOLS
% Define the valid mathematical symbols that can be used in MAPS equations.
validMathsSymbols = '-+/*^()=';

end