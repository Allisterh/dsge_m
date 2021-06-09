function tabAlignedStrArrTable = ...
    create_tab_aligned_table_from_cell_string_array(strArr)
% This function creates a tab-aligned table from a cell string array.
% The resulting output can be printed out row-by-row to produce a tab-
% aligned table of strings.
%
% INPUTS:   
%   -> strArr: two-dimensional cell array of strings
%
% OUTPUTS:  
%   -> tabAlignedStrArrTable: column cell string array amalgamting each 
%      column of the input with a fixed width
%
% DETAILS:  
%   -> This helper tab-aligns the columns of a cell string array such that
%      an fprintf command treating each row of the column cell string 
%      output as a separate line would produce a table in which the columns
%      had equal width.
%   -> The output is designed to be compatible with MAPS' write to text
%      file functionality.
%
% NOTES:
%   -> See the MAPS user guide for more details of misc utilities in MAPS.
%   -> This function implements the tab-aligning by inserting white spaces
%      (rather than through the \t instruction) because that allows it to
%      be used in conjunction with text file writing.
%
% This version: 20/02/2013
% Author(s): Matt Waldron

%% CHECK INPUT
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_two_dimensional_cell_string_array(strArr)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% COMPUTE DIMENSION OF SRTING ARRAY
[nRowsInStrArr,nColsInStrArr] = size(strArr);

%% INITIALISAE OUTPUT
tabAlignedStrArrTable = cell(nRowsInStrArr,1);

%% TAB ALIGN EACH COLUMN & CONCETANTE IN TABLE OUTPUT
for iCol = 1:nColsInStrArr
    tabAlignedStrArrTable = strcat(tabAlignedStrArrTable,...
        tab_align_column_string_array(strArr(:,iCol)));
end

end

%% FUNCTION TO TAB ALIGN COLUMN CELL STRING ARRAY
function tabAlignedColStrArr = tab_align_column_string_array(colStrArr)
% This helper ensures that strings within a column have equal width.
% It does this by padding the strings with white spaces to mimic tab 
% alignment.
%
% INPUTS:   
%   -> colStrArr: column cell array of strings
%
% OUTPUTS:  
%   -> tabAlignedColStrArr: column cell array of strings of equal width

%% COMPUTE NUMBER OF CHARACTERS IN EACH STRING
nCharsInStrs = cellfun(@(x) size(x,2),colStrArr);
maxnChars = max(nCharsInStrs);

%% COMPUTE NUMBER OF HORIZONTAL TABS TO ADD
% This formula uses a horizontal tab character length, equal to 8 white 
% spaces.
tabCharLength = 8;
tabRemainderToAdd = tabCharLength*ceil(maxnChars/tabCharLength)-maxnChars;
nSpacesToAddToStrs = maxnChars-nCharsInStrs+tabRemainderToAdd;

%% ADD WHITE SPACE CHARATCERS TO EACH STRING
nStrs = size(colStrArr,1);
tabAlignedColStrArr = cell(nStrs,1);
for iStr = 1:nStrs
    tabAlignedColStrArr{iStr} = [colStrArr{iStr},...
        repmat(' ',[1 nSpacesToAddToStrs(iStr)])];    
end

end