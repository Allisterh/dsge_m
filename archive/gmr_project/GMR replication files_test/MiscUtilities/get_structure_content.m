function structureContent = get_structure_content(structure,structureName)
% Recursively evaluate the content of a structure and nested sub-structures
% INPUTS:
%   -> structure: either the structure to display or a string holding the
% name of the structure to display
% OUTPUTS:
%   -> structureContent: two column cell array with each row containing the
%   path to one of the structure's fields or subfields, and the
%   corresponding scalar value.
% DETAILS:
%   ->
% NOTES:
%   -> This function was inspired by an entry on Matlab Central; see
%   http://www.mathworks.com/matlabcentral/fileexchange/13831-structure-display
%   for details

% This version: 13-Mar-2013
% Author(s): David Bradnum

%% INITIALISATION
if ischar(structure)
    value = evalin('caller',structure);
    name = structure;
else
    value = structure;
    if nargin > 1
        name = structureName;
    else
        name = inputname(1);
    end
end

%TODO: Proper error handling
if ~isstruct(value)
    error('argument should be a structure or the name of a structure');
end
structureContent = cell(0,2);
rec_structdisp(name,value);

    function rec_structdisp(name,value)
        %% INITIALISE CONTROL PARAMETERS
        ARRAYMAXROWS = 10;
        ARRAYMAXCOLS = 10;
        ARRAYMAXELEMS = 30;
        CELLMAXROWS = 10;
        CELLMAXCOLS = 10;
        CELLMAXELEMS = 30;
        
        if ~isstruct(value)
            structureContent = [structureContent; {name,value}];
        else
            fields = sort(fieldnames(value));
            nFields = length(fields);
            
            for iField=1:nFields
                iFieldName = fields{iField};
                iFieldValue = value.(iFieldName);
                iFieldFullName = [name '.' iFieldName];
                
                if isstruct(iFieldValue) || isobject(iFieldValue)
                    if length(iFieldValue) == 1
                        rec_structdisp(iFieldFullName,iFieldValue);
                    else
                        for k=1:length(iFieldValue)
                            rec_structdisp(...
                                [iFieldFullName '(' num2str(k) ')'],...
                                iFieldValue(k));
                        end
                    end
                elseif iscell(iFieldValue)
                    if size(iFieldValue,1)<=CELLMAXROWS && ...
                            size(iFieldValue,2)<=CELLMAXCOLS && ...
                            numel(iFieldValue)<=CELLMAXELEMS
                        rec_structdisp(iFieldFullName,iFieldValue);
                    end
                elseif size(iFieldValue,1)<=ARRAYMAXROWS && ...
                        size(iFieldValue,2)<=ARRAYMAXCOLS && ...
                        numel(iFieldValue)<=ARRAYMAXELEMS && ...
                        ~isstruct(iFieldValue)
                    
                    structureContent = [structureContent; ...
                        {iFieldFullName,iFieldValue}];
                end
            end
        end
    end
end

