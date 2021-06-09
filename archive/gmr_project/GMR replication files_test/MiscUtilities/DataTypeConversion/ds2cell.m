function cellOutput = ds2cell(ds)
% Converts a dataset array to a cell array. 
% INPUTS:
%   -> ds: dataset to convert
% OUTPUTS:
%   -> cellOutput: cell array mirroring the full content of ds.
% DETAILS:
%   -> 
% NOTES:
%   -> This function was adapted from a version on Matlab Central, Dec 2012
%
% This version: 28/12/2012
% Author(s): David Bradnum

%% TODO: ERROR HANDLING: CHECK INPUT IS A DATASET

%% TODO: CHANGE FUNCTION NAME TO BE CONSISTENT WITH OTHER CONVERSION UTILS

%% GET VARIABLE NAMES FROM DATASET, AND ADD TO FIRST ROW OF CELL
[nobs nvars] = size(ds);
varnames = get(ds,'VarNames');
cellOutput = cell(nobs+1,nvars);
cellOutput(1,:) = varnames;

%% ITERATE OVER VARIABLES, EXTRACTING DATA AND ADDING TO CELL COLUMN-WISE
for iVar = 1:nvars,
    vec = ds.(varnames{iVar});
    if(~isnumeric(vec))
        vec = cellstr(char(vec));
    else
        vec = num2cell(vec);
    end
    cellOutput(2:end,iVar) = vec;
end