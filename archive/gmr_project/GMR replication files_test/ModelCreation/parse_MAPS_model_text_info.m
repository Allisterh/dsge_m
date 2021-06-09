function [FileContents,FileKeywords,FileLineNumbers] = ...
    parse_MAPS_model_text_info(modelFileConfig,modelFileName)
% This is a generic MAPS model file parser.
% It scans raw text information from a *.maps model file. It then checks 
% that information against and deconstructs the information according to 
% the instructions implicit in the input model file configuration.
%
% INPUTS:   
%   -> modelFileConfig: cell array of information about the configuration
%      and content of the model file
%   -> modelFileName: full path string name of the *.maps model file
%
% OUTPUTS:  
%   -> FileContents: structure containing all the information in the model
%      file deconstructed into its constituent parts
%   -> FileKeywords: structure (with the same fields as the above) 
%      containing the keywords used in the model file
%   -> FileLineNumbers: structure (with the same fields as the above) 
%      containing the line numbers in the file from which the information
%      was taken
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> scan_MAPS_text_file 
%   -> deconstruct_file_contents (sub-function)
%
% DETAILS:  
%   -> parse_MAPS_model_text_info reads, checks & compiles the text 
%      information contained in  modelFileName. 
%   -> It first scans in the information from the model file into a cell
%      array.
%   -> It then separates out the individual bits of that cell array into 
%      their components in the call to deconstruct_file_contents.
%   -> Each of the components is stored in a spearate field in the file
%      contents output with the names of the components (and resulting
%      fields) coming from the model file configuration input.
%   -> The two additional outputs are also structures with exactly the same
%      field names as the file contents structure. These outputs contain
%      metadata about the file keyword used for the object in the model 
%      file and the line numbers on which each piece of information was
%      taken from the model file.
%   -> The function will throw an exception if the information in the model
%      file is incomplete (because compulsory information is missing) or if
%      it is formatted incorrectly.
%
% NOTES:
%   -> This function is generic and will scan in information (as MATLAB
%      strings) from any text file provided its format is the same as that
%      described in the configuration file. 
%   -> The configuration file itself must be formatted in a particular way. 
%      The first column must contain the model file keywords 
%      (eg. 'METADATA'), the second column indicates whether the 
%      information under that keyword is 'compulsory' or 'optional, the 
%      third column contains the names for each separate piece of 
%      information under the keyword and the delimiters between them 
%      (eg. xNames:xMnems) and the fourth column indicates whether 
%      individual pieces of information are compulsory or optional 
%      (eg compulsory:optional). The number of rows in the configuration
%      describe the number of keywords.
%   -> See <> for information about the format of MAPS model files.
%
% This version: 09/02/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and basic shape of the inputs are as expected/
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId);
elseif ~iscellstr(modelFileConfig) || ndims(modelFileConfig)~=2 || ...
        size(modelFileConfig,2)~=4
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~ischar(modelFileName)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
end

%% SCAN IN FILE CONTENTS
% Call function to scan the raw text info in from the MAPS model file.
% This scan is based on information being delimited by new lines in the
% text file and a comment style of %. For more details, open the function
% itself.
[rawFileContents,linesInFile] = scan_MAPS_text_file(modelFileName);

%% DECONSTRUCT FILE CONTENTS
% Call sub-function to check and break the raw information down into its 
% constituent parts as dictated by the modelFileConfig info. The 
% sub-function returns this information in a structure. It also returns a
% structure with identical fields containing information about the file
% keyword used and the line number on which each piece of information
% appeared in the text file.
[FileContents,FileKeywords,FileLineNumbers] = deconstruct_file_contents(...
    modelFileConfig,rawFileContents,linesInFile);

end

%% FUNCTION TO INTERROGATE MODEL FILE CONTENTS
function [FileContents,FileKeywords,FileLineNumbers] = ...
    deconstruct_file_contents(modelFileConfig,rawFileContents,linesInFile)
% This helper separates separates out info in the scanned file contents. 
% It checks that the format of the file is as expected and then compiles 
% the individual pieces of information in a structure according to the
% instructions in the modelFileConfig.
%
% INPUTS:
%   -> modelFileConfig: cell array of information about the model file
%   -> rawFileContents: cell array of strings scanned from the text file
%   -> linesInFile: vector of line numbers for each row of rawFileContents
%
% OUTPUTS:  
%   -> FileContents: structure containing all the information in the model
%      file deconstructed into its constituent parts
%   -> FileKeywords: structure with identical fields containing the
%      keyword used in the model file
%   -> FileLineNumbers: structure with identical fields containing 
%      the line numbers on which each line of information was found in the
%      model file
%
% CALLS:
%   -> generate_MAPS_exception
%   -> generate_MAPS_exception_and_add_as_cause
%   -> generate_MAPS_exception_and_add_cause
%   -> deconstruct_field_info (sub-function)

%% SETUP AN EXCEPTION FOR MODEL INFO FILE FORMAT ERRORS
% Setup an exception to add causes to if and when file format exceptions
% are encountered.
masterErrId = ['MAPS:',mfilename,':FileFormatError'];
FileFormatE = generate_MAPS_exception(masterErrId);

%% COMPUTE MODEL FIELD KEYWORDS & THE LINES ON WHICH THEY APPEAR
% Search model contents for all model field keywords. If a compulsory 
% keyword is missing add a cause to the file format exception. Compute the
% row numbers of rawFileContents on which the model file keywords appear.
% Remove any missing keywords from the modelFileConfig information.
modelFileKeywords = modelFileConfig(:,1);
isModelFileKeywordCompulsory = strcmp('compulsory',modelFileConfig(:,2));
nKeywords = size(modelFileKeywords,1);
modelFileKeywordRows = NaN*ones(nKeywords,1);
for iKeyword = 1:nKeywords
    rowOfKeyword = find(...
        strcmp(modelFileKeywords{iKeyword},rawFileContents));
    if size(rowOfKeyword,1) > 1
        errId = [masterErrId,':RepeatedKeyword'];
        FileFormatE = generate_MAPS_exception_and_add_as_cause(...
            FileFormatE,errId,...
            {modelFileKeywords{iKeyword} num2str(rowOfKeyword')});
    elseif isempty(rowOfKeyword) && isModelFileKeywordCompulsory(iKeyword)
        errId = [masterErrId,':MissingKeyword'];
        FileFormatE = generate_MAPS_exception_and_add_as_cause(...
            FileFormatE,errId,{modelFileKeywords{iKeyword}});
    elseif ~isempty(rowOfKeyword)
        modelFileKeywordRows(iKeyword) = rowOfKeyword;
    end
end
isMissingKeyword = isnan(modelFileKeywordRows);
modelFileConfig(isMissingKeyword,:) = [];
modelFileKeywordRows(isMissingKeyword) = [];

%% CONSTRUCT MODEL FILE FIELD NAME STRUCTURE WITH MODEL FILE INFO
% Create a structure with the model field names that exist in the 
% rawFileContents as the field names and the lines of the file information
% as the fields.
nRowsInContents = size(rawFileContents,1);
augRows = [modelFileKeywordRows;nRowsInContents+1];
modelFileKeywords = modelFileConfig(:,1);
isModelFileKeywordCompulsory = strcmp('compulsory',modelFileConfig(:,2));
nKeywords = size(modelFileKeywords,1);
rawFileContentsSplit = cell(nKeywords,1);
linesInFileSplit = cell(nKeywords,1);
for iKeyword = 1:nKeywords
    firstRow = modelFileKeywordRows(iKeyword)+1;
    lastRow = min(augRows(augRows>modelFileKeywordRows(iKeyword)))-1;
    if lastRow >= firstRow
        rawFileContentsSplit{iKeyword} = rawFileContents(firstRow:lastRow);
        linesInFileSplit{iKeyword} = linesInFile(firstRow:lastRow);
    elseif isModelFileKeywordCompulsory(iKeyword)
        errId = [masterErrId,':MissingInfo'];
        FileFormatE = generate_MAPS_exception_and_add_as_cause(...
            FileFormatE,errId,{modelFileKeywords{iKeyword}});
    end
end
emptyInfoLogicals = cellfun(@isempty,rawFileContentsSplit);
rawFileContentsSplit(emptyInfoLogicals) = [];
linesInFileSplit(emptyInfoLogicals) = [];
modelFileConfig(emptyInfoLogicals,:) = [];

%% THROW ANY EXCEPTIONS ENCOUNTERED
if ~isempty(FileFormatE.cause)
    throw(FileFormatE);
end

%% CHECK FORMAT OF & COMPILE CONTENT OF MODEL FIELDS
% Check that the information under each of the model fields is formatted
% correctly. If it is, compile the information in a structure, which is the 
% output of this function. 
nKeywords = size(modelFileConfig,1);
for iKeyword = 1:nKeywords
    try
        FieldInfo = deconstruct_field_info(...
            rawFileContentsSplit{iKeyword},linesInFileSplit{iKeyword},...
            modelFileConfig{iKeyword,3},modelFileConfig{iKeyword,4});
        fields = fieldnames(FieldInfo);
        nFields = size(fields,1);
        for iField = 1:nFields
            FileContents.(fields{iField}) = FieldInfo.(fields{iField});
            FileKeywords.(fields{iField}) = modelFileConfig{iKeyword,1};
            FileLineNumbers.(fields{iField}) = linesInFileSplit{iKeyword};
        end
    catch FieldInfoE
        errId = [masterErrId,':BadlyFormattedInfo'];
        FieldFormatE = generate_MAPS_exception_and_add_cause(...
            FieldInfoE,errId,...
            {modelFileConfig{iKeyword,1} modelFileConfig{iKeyword,3}});
        FileFormatE = addCause(FileFormatE,FieldFormatE);
    end
end

%% THROW ANY EXCEPTIONS ENCOUNTERED
if ~isempty(FileFormatE.cause)
    throw(FileFormatE);
end

end

%% FUNCTION TO COMPILE FIELD INFO
function FieldInfo = deconstruct_field_info(...
    fileContent,fileLineNumbers,fileLayout,fileCompulsoryFlags)
% This helper deconstructs the info under an individual keyword.
% It throws an exception if the file content is not laid out (or present) 
% in the way sepcified by the inputs.
%
% INPUTS:   
%   -> fileContent - string cell array of field info from fileContents
%   -> fileLineNumbers - numeric vector of line numbers
%   -> fileLayout - string description of field's layout in the file
%   -> fileCompulsoryFlags - string 'compulsory', 'optional'' flags
%
% OUTPUTS:  
%   -> FieldInfo - a structure with the file content split out
%
% CALLS:
%   -> generate_and_throw_MAPS_exception

%% SETUP A VECTOR OF FORMAT ERRORS FOR EACH OF THE LINES
% Setup a place-holder vector to fill in individually for each line of text
% as format errors are encountered.
nLinesOfInfo = size(fileContent,1);
badlyFormattedLines = false(nLinesOfInfo,1);

%% EXTRACT FILE DELIMITERES FROM THE LAYOUT INFO
% Extract the file content delimiters from the file layout configuration as 
% the non-letter, non-numeric components of the file layout. For example, 
% if the fileLayout is 'names:mnemonics', the fileDelimiters are ':'.
fileDelimitersSplit = regexp(fileLayout,'\<\w+\>','split');
fileDelimiters = [fileDelimitersSplit{:}];

%% RUN THROUGH THE DELIMITERS SPLITTING INFORMATION OUT
% Split the fileLayout, compulsory flags and file content by each 
% delimiter, one by one, saving them in a structure. For example, if the 
% file layout configuration is 'names:mnemonics' and fileCompulsoryFlags is 
% 'compulsory:compulsory', the first iteration in the loop extracts the 
% nameComponent as 'names', the fileCompulsoryFlag as 'compulsory' and 
% saves the component of the file content as FieldInfo.names = component. 
% The second iteration then compiles the remaining file content as 
% FieldInfo.mnemonics. Finally, if there is missing (compulsory) 
% information update the badlyFormattedLines flag for each badly formatted 
% line. Note that each iteration in the loop adds a blank string to the
% front of file contents to workaround the fact that strtok ignores
% (consecutive) delimiters that appear first in a string. So, if a user has
% left out optional information in a MAPS model file, but left the
% delimiters in (eg. '(,)') strtok would not split the information
% correctly without this line.
nDelimiters = length(fileDelimiters);
for iDelimiter = 1:nDelimiters+1
    if iDelimiter <= nDelimiters
        fileContent = strcat(repmat({' '},[nLinesOfInfo 1]),fileContent);
        [nameComponent,fileLayout] = strtok(...
            fileLayout,fileDelimiters(iDelimiter));                         %#ok<STTOK>
        [fileCompulsoryFlag,fileCompulsoryFlags] = strtok(...
            fileCompulsoryFlags,fileDelimiters(iDelimiter));                %#ok<STTOK>
        [component,fileContent] = strtok(...
            fileContent,fileDelimiters(iDelimiter));                        %#ok<STTOK>
    elseif ~isempty(fileLayout)
        nameComponent = fileLayout;
        fileCompulsoryFlag = fileCompulsoryFlags;
        component = fileContent;
    else
        break
    end
    component = strtrim(component);
    emptyLines = cellfun(@isempty,component);
    if strcmp(fileCompulsoryFlag,'compulsory')
        badlyFormattedLines = (badlyFormattedLines|emptyLines);
    end    
    if ~all(emptyLines)
        FieldInfo.(nameComponent) = component;
    end
    if iDelimiter <= nDelimiters
        fileContent = cellfun(...
            @(x) x(2:end),fileContent,'UniformOutput',false);
        fileLayout(1) = [];
        fileCompulsoryFlags(1) = [];
    end
end

%% WRITE OUT AN EXCEPTION IF THERE ARE ANY BADLY FORMATTED LINES
% If there are badly formatted lines, save the line numbers in an
% exception to throw out to the calling function.
if any(badlyFormattedLines)
    errId = ['MAPS:',mfilename,':BadLines'];
    generate_and_throw_MAPS_exception(...
        errId,{num2str(fileLineNumbers(badlyFormattedLines)')});
end

end