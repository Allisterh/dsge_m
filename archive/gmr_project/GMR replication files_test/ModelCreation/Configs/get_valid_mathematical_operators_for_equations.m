function validMathsOps = get_valid_mathematical_operators_for_equations
% This configuration defines the valid operators for use in MAPS equations.
%
% INPUTS:   
%   -> none
%
% OUTPUTS:  
%   -> validMathsOps: a cell string array of valid operators
%
% CALLS:
%   -> none
%
% DETAILS:
%   -> The configuration defines the valid mathematical operators for use 
%      in MAPS equations.
%   -> These operators can be used as equation delimiters to split
%      equations into their constituent parts.
%
% NOTES:
%   -> See XXXXXXXX for details of the rules and format of MAPS model 
%      files & equations
%
% This version: 01/04/2011
% Author(s): Matt Waldron

%% DEFINE VALID OPERATORS
% Define the valid mathematical operators that can be used in MAPS 
% equations.
validMathsOps = {'log','exp'};

end