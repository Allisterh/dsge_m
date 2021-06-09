function create_MAPS_model_file_text_info(...
    Model,modelFileConfig,modelFileName)
% This macro creates a MAPS model text file from a MAPS model object.
% It inverts model creation in which a MAPS model object is created from a 
% MAPS model text file.
%
% INPUTS:   
%   -> Model: MAPS model object
%   -> modelFileConfig: cell array of information about the configuration
%      and content of the model file
%   -> modelFileName: full path string name of *.maps model file to create
%
% OUTPUTS:  
%   -> none (writes out a model file)
%
% DETAILS:  
%   -> This macro writes out a *.maps text file given a MAPS model and a
%      full path file name for that text file.
%   -> It extracts the relevant information from a MAPS model object,
%      compiles it together and then calls a helper to write out a *.maps 
%      text file.
%
% NOTES:
%   -> See the MAPS user guide for information about the format of MAPS 
%      model files.
%   -> If the model file name passed in as input already exists, this
%      function will overwrite that information with the information in the
%      model passed in.
%   -> This function is guaranteed (assuming no bugs!) to create a valid 
%      *.maps model file if the model passed in as input has been created
%      and validated using the standard model creation macro. However, if 
%      the model was subsequently manipulated or is in some other way 
%      inconsistent with MAPS' create model functionality (eg if it is old 
%      and out-of-date), then there is no guarantee that this function will 
%      work or, if it does "work", that the resulting text file will be 
%      valid if parsed back into MAPS. 
%
% This version: 20/02/2013
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 3
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~iscellstr(modelFileConfig) || ndims(modelFileConfig)~=2 || ...
        size(modelFileConfig,2)~=4
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);    
elseif ~ischar(modelFileName)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);    
end

%% RECONSTRUCT THE FILE CONTENTS FROM THE MAPS MODEL
% Call a sub-function to mirror the cell array of model information that
% exists when a model is scanned in in the parsing process.
rawFileContents = reconstruct_file_contents(Model,modelFileConfig);

%% WRITE THE RECONSTRUCTED FILE CONTENTS TO THE MAPS MODEL FILE
% Call a helper function to write out the file contents computed above to a
% MAPS text file.
write_to_MAPS_text_file(rawFileContents,modelFileName);

end

%% FUNCTION TO CREATE THE *.MAPS FILE CONTENT FROM THE MAPS MODEL
function rawFileContents = reconstruct_file_contents(Model,modelFileConfig)
% This helper amalgamates all model file information from a MAPS model.
% It adds all information into a cell array in a format consistent with the
% input format for the MAPS model file.
%
% INPUTS:
%   -> Model: MAPS model structure 
%   -> modelFileConfig: cell string array of model file configuration info
%
% OUTPUTS:  
%   -> rawFileContents: cell array containing the information to write out

%% SETUP A MASTER EXCEPTION
% Setup a master exception to add causes to as encountered below.
errId = ['MAPS:',mfilename,':InvalidModel'];
ModelContentE = generate_MAPS_exception(errId);

%% CONSTRUCT RAW FILE CONTENT INFO
% Run through each of the possible sections of a MAPS model file (as
% inferred by the number of rows and keywords in the configuration) and
% extract the relevant information from the model adding all information
% (with its keyword) to a cell array. Collect any exceptions encountered.
rawFileContents = cell(0,1);
nKeywords = size(modelFileConfig,1);
for iKeyword = 1:nKeywords
    try
        fileContent = reconstruct_field_info(Model,...
            modelFileConfig{iKeyword,1},modelFileConfig{iKeyword,2},...
            modelFileConfig{iKeyword,3},modelFileConfig{iKeyword,4});
        rawFileContents = [...
            rawFileContents;...
            modelFileConfig(iKeyword,1);...
            fileContent;...
            {''}];                                                          %#ok<AGROW>
    catch BadContentE
        ModelContentE = addCause(ModelContentE,BadContentE);
    end
end

%% THROW ANY EXCEPTIONS ENCOUNTERED
% Throw the master exception if any exceptions were added to it.
if ~isempty(ModelContentE.cause)
    throw(ModelContentE);
end

end

%% FUNCTION TO CONSTRUCT MAPS MODEL FILE FIELD INFO
function fileContent = reconstruct_field_info(...
    Model,fileKeyword,fieldCompulsoryFlag,fileLayout,fileCompulsoryFlags)   
% This helper amalgamates all info into a field for a MAPS model file.
% It combines all the information from a model related to a particular
% field of a MAPS model file (e.g. metadata).
%
% INPUTS:
%   -> Model: MAPS model object
%   -> fileKeyword: string file keyword for the field (e.g. METADATA)
%   -> fieldCompulsoryFlag: string indicating whether field is compulsory
%      or not
%   -> fileLeayout: string with the field component and layout
%   -> fileCompulsoryFlags: string indicating whether each component of the
%      field is compulsory or not
%
% OUTPUTS:  
%   -> fileContent: cell array containing the field information

%% SETUP A MASTER EXCEPTION
% Setup an expection to add any causes to as encountered below and thrown
% at the end of the sub-function.
errId = ['MAPS:',mfilename,':BadModelContent'];
BadContentE = generate_MAPS_exception(errId,{fileKeyword});

%% EXTRACT THE FILE DELIMITERS
% Extract the file content delimiters from the file layout configuration as 
% the non-letter, non-numeric components of the file layout. For example, 
% if the fileLayout is 'names:mnemonics', the fileDelimiters are ':'. 
fileDelimitersSplit = regexp(fileLayout,'\<\w+\>','split');
fileDelimiters = [fileDelimitersSplit{:}];

%% RUN THROUGH THE DELIMITERS SPLITTING INFORMATION OUT
% Setup a cell array to hold all the componenets of the file field found in 
% the model, ready for packaging togther below. For each delimiter extract 
% the model keyword (unless the delimiter is supposed to be on its own at 
% the end of the line (eg (thetaLB,thetaUB) where ')' is the final 
% delimiter with nothing following) and then attempt to extract that 
% information from the model using the model unpacker. If the content is 
% referenced as compulsory but is missing from the model (i.e. the unpacker 
% returns an error or if the information unpacked is not a numeric or cell 
% string column then add an exception (also if there was any unspecified 
% unpacking error).
nDelimiters = length(fileDelimiters);
fileContentSplit = cell(1,nDelimiters+1);
remainingFileLayout = fileLayout;
for iDelimiter = 1:nDelimiters+1
    if iDelimiter <= nDelimiters
        [nameComponent,remainingFileLayout] = strtok(...
            remainingFileLayout,fileDelimiters(iDelimiter));                         %#ok<STTOK>
         [fileCompulsoryFlag,fileCompulsoryFlags] = strtok(...
            fileCompulsoryFlags,fileDelimiters(iDelimiter));                %#ok<STTOK>       
    elseif ~isempty(remainingFileLayout)
        nameComponent = remainingFileLayout;
        fileCompulsoryFlag = fileCompulsoryFlags;
    else        
        break
    end
    try
        fileContentSplit{iDelimiter} = unpack_model(Model,{nameComponent});
        if ndims(fileContentSplit{iDelimiter})~=2 || ...
                size(fileContentSplit{iDelimiter},2)~=1
            errId = ['MAPS:',mfilename,':BadDataDims'];
            BadContentE = generate_MAPS_exception_and_add_as_cause(...
                BadContentE,errId,{nameComponent});
        elseif isnumeric(fileContentSplit{iDelimiter})
            fileContentSplit{iDelimiter} = ...
                convert_numeric_column_vector_to_string_equivalent(...
                fileContentSplit{iDelimiter});
        elseif ~iscellstr(fileContentSplit{iDelimiter})
            errId = ['MAPS:',mfilename,':BadDataType'];
            BadContentE = generate_MAPS_exception_and_add_as_cause(...
                BadContentE,errId,{nameComponent});
        end
    catch UnpackE
        if strcmp(fileCompulsoryFlag,'compulsory') && ...
                strcmp(fieldCompulsoryFlag,'compulsory')
            errId = ['MAPS:',mfilename,':MissingModelContent'];
            MissingContentE = generate_MAPS_exception_and_add_cause(...
                UnpackE,errId,{nameComponent});
            BadContentE = add_cause(BadContentE,MissingContentE);
        end
    end
    if iDelimiter <= nDelimiters
        remainingFileLayout(1) = [];
        fileCompulsoryFlags(1) = [];
    end
end

%% THROW EXCEPTION
% Throw the master exception if any exceptions were encountered above.
if ~isempty(BadContentE.cause)
    throw(BadContentE)
end

%% COMBINE THE INFORMATION TOGETHER
% Take the information from above and combine it into one, separating each
% component using the appropriate delimiters. Throw an error if the number 
% of lines pertaining to each component are not consistent such that they 
% cannot be combined together.
if all(cellfun(@isempty,fileContentSplit))
    fileContent = cell(0,1);
else
    nLines = max(cellfun('size',fileContentSplit,1));
    fileContentWithDelimiters = cell(nLines,nDelimiters+1);
    for iDelimiter = 1:nDelimiters+1
        if ~isempty(fileContentSplit{iDelimiter})
            if size(fileContentSplit{iDelimiter},1) ~= nLines
                errId = ['MAPS:',mfilename,':InconsistentFieldSizes'];
                generate_MAPS_exception_and_add_as_cause_and_throw(...
                    BadContentE,errId,{fileLayout});
            else
                iDelimiterPrecedingContent = fileContentSplit{iDelimiter};
            end
        else
            iDelimiterPrecedingContent = repmat({' '},[nLines 1]);
        end
        if iDelimiter < nDelimiters+1
            fileContentWithDelimiters(:,iDelimiter) = strcat(...
                iDelimiterPrecedingContent,...
                repmat({fileDelimiters(iDelimiter)},[nLines 1]));
        else
            fileContentWithDelimiters(:,iDelimiter) = ...
                iDelimiterPrecedingContent;
        end
    end
    fileContent = create_tab_aligned_table_from_cell_string_array(...
        fileContentWithDelimiters);
end

end