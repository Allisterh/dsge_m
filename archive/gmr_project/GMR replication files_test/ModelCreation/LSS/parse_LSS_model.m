function Model = parse_LSS_model(modelFileName)
% This parser reads in & validates info from a MAPS linear model text file.
% It scans in the contents of the sepcified MAPS linear model file and then
% validates it to check that the model meets MAPS linear model syntax 
% rules. If the model fails validation, it throws an exception detailing
% the cause(s) of the validation failure.
%
% INPUTS:
%   -> modelFileName: full path string name of the *.maps linear model file
%
% OUTPUTS:  
%   -> Model: MAPS model structure containing all info from the model file
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> get_LSS_model_file_config
%   -> parse_MAPS_model_text_info
%   -> check_LSS_model_file_syntax
%   -> generate_MAPS_exception_add_cause_and_throw
%   -> convert_parameter_strings_to_numerics
%   -> are_equations_forward_looking
%   -> get_LSS_model_structure_config
%   -> pack_model
%
% DETAILS:  
%   -> This parser reads, checks & compiles the text information contained 
%      in modelFileName. 
%   -> It first calls a generic MAPS model parser to scan in the raw model 
%      text information. This function will throw exceptions if the file is 
%      not formatted correctly.
%   -> It then validates the syntax in the model using the MAPS LSS model 
%      file syntax checker. If the model fails validation, this function 
%      throws an exception detailing the cause(s) of the validation 
%      failure.
%   -> Finally, the scanned model info is augmented with new information
%      (based on the information already scanned - eg separated metadata 
%      fields) and then packed into the model using the LSS MAPS model 
%      structure configuration information.
%
% NOTES:
%   -> See <> for information about the format of MAPS model files.
%   -> The first sub-function will be deleted soon and the model syntax
%      checker amended accordingly.
%
% This version: 29/01/2013
% Author(s): Matt Waldron & Kate Reinold

%% CHECK INPUT
% Check that the number and type of input is as expected by the parser.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(modelFileName)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% READ MODEL FILE CONTENTS INTO MATLAB
% Call the generic MAPS model parser to scan the model file information
% into MAPS as dictated by the information in the congiguration file passed
% as input. This returns three strcutures - one containing the file 
% contents, one containing the keywords used in the file, and one 
% containing the line numbers on which each spearate piece of information 
% appeared.
modelFileConfig = get_LSS_model_file_config;
[FileContents,FileKeywords,FileLineNumbers] = ...
    parse_MAPS_model_text_info(modelFileConfig,modelFileName);

%% VALIDATE MODEL SYNTAX
% Check that the model syntax is valid and throw any excpetions encountered
% if not.
errId = ['MAPS:',mfilename,':ModelFileSyntaxErrors'];
ModelFileSyntaxE = generate_MAPS_exception(errId,{modelFileName});
check_LSS_model_file_syntax(...
    FileContents,FileKeywords,FileLineNumbers,ModelFileSyntaxE);

%% CREATE DATA TRANSFORMATION EQUATIONS
% Create data transformation equations by combining the model observables 
% with the raw observable transformations.
if isfield(FileContents,'YtildeTransformations') && ...
        isfield(FileContents,'Ymnems')
    YtildeTransformations = FileContents.YtildeTransformations;
    Ymnems = FileContents.Ymnems;
    Ynames = FileContents.Ynames;
    nY = size(Ymnems,1);
    YtildeEqStrs = strcat(...
        Ymnems,repmat({' = '},[nY 1]),YtildeTransformations);
    FileContents.YtildeEqStrs = YtildeEqStrs;
    FileContents.YtildeEqNames = Ynames;
end

%% CREATE STEADY STATE (AND PARAMETER TRANSFORMATION) EQUATIONS
% Create steady state equations by combining the steady states with the 
% steady state definitions.
if isfield(FileContents,'ssDefs') && isfield(FileContents,'ssMnems')
    ssDefs = FileContents.ssDefs;
    ssMnems = FileContents.ssMnems;
    ssNames = FileContents.ssNames;
    nss = size(ssMnems,1);
    ssEqStrs = strcat(ssMnems,repmat({' = '},[nss 1]),ssDefs);
    FileContents.ssEqStrs = ssEqStrs;    
    FileContents.ssEqNames = ssNames;
end

%% CONVERT PARAMETER STRINGS TO NUMERICS
if isfield(FileContents,'theta')
    thetaDefaultStrs = FileContents.theta;
    theta = convert_column_string_array_to_numeric_equivalent(...
        thetaDefaultStrs);
    FileContents.theta = theta;
end

%% DECONSTRUCT MODEL METADATA INFORMATION
% Pull out the individual fields from the cell elements in the metadata
% component of the model info file and create new fields for each
% individual piece of meatdata. Add an additional piece of metadata for the
% model creation date.
if isfield(FileContents,'metadataFields') && ...
        isfield(FileContents,'metadataDescriptors')
    metadataFields = FileContents.metadataFields;
    metadataDescriptors = FileContents.metadataDescriptors;
    nFields = size(metadataFields,1);
    metadataFields = strcat(repmat({'model'},[nFields 1]),metadataFields);
    for iField = 1:nFields
        FileContents.(metadataFields{iField}) = ...
            metadataDescriptors{iField};
    end
    FileContents.modelCreationDate = datestr(now,1);
end

%% DETERMINE MODEL TYPE
% Set the class of model to linear state space and call a helper to 
% determine if the model is forward looking or not. Examine the content of 
% the model to determine its type and characteristics.
FileContents.modelIsLinearStateSpace = true;
FileContents.modelIsForwardLooking = are_equations_forward_looking(...
    FileContents.xEqStrs);
if isfield(FileContents,'YeqStrs')
    FileContents.modelHasMeasurementEqs = true;
else
    FileContents.modelHasMeasurementEqs = false;
end
if isfield(FileContents,'wMnems')
    FileContents.modelHasMeasurementErrors = true;
else
    FileContents.modelHasMeasurementErrors = false;
end
if isfield(FileContents,'YtildeEqStrs')
    FileContents.modelHasDataTransformationEqs = true;
else
    FileContents.modelHasDataTransformationEqs = false;
end
if isfield(FileContents,'etatMnems')
    FileContents.modelHasTimeVaryingTrends = true;
else
    FileContents.modelHasTimeVaryingTrends = false;
end
if isfield(FileContents,'ssEqStrs')
    FileContents.modelHasSteadyStateEqs = true;
else
    FileContents.modelHasSteadyStateEqs = false;
end
FileContents.modelHasDecompAddOn = false;

%% PACK MODEL
% Get the MAPS model structure configuration and package the flat file info 
% sructure into the info section of a MAPS model object using the 
% pack_model helper function.
Model.Constructor = get_LSS_model_structure_config;
Model = pack_model(...
    Model,fieldnames(FileContents),struct2cell(FileContents));

end