function twoColCellStrArrOfPairs = ...
    build_two_column_cell_array_of_string_pairs(...
    colCellStrArr1,colCellStrArr2,sortAlphabetically,sortSecondColFirst)
% This helper forms a grid of all possible string combinations in inputs.
% 
% INPUTS:
%   -> colCellStrArr1: first column array of strings
%   -> colCellStrArr2: second column array of strings
%   -> sortAlphabetically (optional): true/false
%   -> sortSecondColFirst (optional): true/false
%
% OUTPUTS:
%   -> twoColCellStrArrOfPairs: two column cell string array containing all
%      combinations of the input string arrays
%
% DETAILS:
%   -> This helper creates a cell string grid containing all possible
%      combinations of pairs from the two separate string array inputs.
%   -> For example, if colCellStrArr1 = {'b';'a'} and 
%      colCellStrArr2 = {'z';'y'}, then 
%      twoColCellStrArrOfPairs = {'b' 'z';'a' 'z';'b' 'y';'a' 'y'}
%   -> Optionally, the output can also be sorted alphabetically in which
%      case the output in the example just given would be: 
%      {'a' 'y';'a' 'z';'b' 'y';'b' 'z'}
%   -> And, as a further option, the output can be sorted alphabetically by
%      the second column first in which case the output in the example is:
%      {'a' 'y';'b' 'y';'a' 'z';'b' 'z'}
%
% NOTES:
%   -> Please see the MAPS user guide for more information on helpers in 
%      MAPS.
%   -> If sortAlphabetically is set to false, then no sorting will take
%      place regardless of the value of sortSecondColFirst. An alternative 
%      implementation would be to throw an error if this were set to true.
%
% This version: 16/03/2013
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_column_cell_string_array(colCellStrArr1)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~is_column_cell_string_array(colCellStrArr2)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin>2 && ~is_logical_scalar(sortAlphabetically)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);   
elseif nargin>3 && ~is_logical_scalar(sortSecondColFirst)
    errId = ['MAPS:',mfilename,':BadInput4'];
    generate_and_throw_MAPS_exception(errId);   
end

%% HANDLE OPTIONAL INPUTS
% The default for the alphabetical sort is false and the default for sort
% 2nd column first is also false.
if nargin < 3
    sortAlphabetically = false;
end
if nargin < 4
    sortSecondColFirst = false;
end

%% COMPUTE THE DIMENSIONS OF THE STRING INPUTS AND INITIALISE OUTPUT
nStrsInColCellArr1 = size(colCellStrArr1,1);
nStrsInColCellArr2 = size(colCellStrArr2,1);
twoColCellStrArrOfPairs = cell(nStrsInColCellArr1*nStrsInColCellArr2,2);

%% CREATE THE GRID OF STRING PAIRS
% The implementation here adds the string pairs in blocks. An alternative
% would be to add them one-by-one in two loops (or a hybrid of the two).
for iStr = 1:nStrsInColCellArr2
    iStrStartInd = (iStr-1)*nStrsInColCellArr1+1;
    iStrEndInd = iStr*nStrsInColCellArr1;
    twoColCellStrArrOfPairs(iStrStartInd:iStrEndInd,1) = colCellStrArr1;
    twoColCellStrArrOfPairs(iStrStartInd:iStrEndInd,2) = repmat(...
        colCellStrArr2(iStr),[nStrsInColCellArr1 1]);
end

%% SORT ALPHABETICALLY (IF APPLICABLE)
% This uses the MATLAB sortrows function.
if sortAlphabetically
    if sortSecondColFirst
        twoColCellStrArrOfPairs = sortrows(twoColCellStrArrOfPairs,[2;1]);
    else
        twoColCellStrArrOfPairs = sortrows(twoColCellStrArrOfPairs);
    end
end

end