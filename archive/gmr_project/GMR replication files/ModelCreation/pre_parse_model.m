function modelIsLinearStateSpace = pre_parse_model(modelFileName)
% This function pre-parses a MAPS model to see if it is linear or not.
% It scans in the content of the MAPS model file correspodning to the input 
% MAPS model file name and then checks it against the expected model file 
% content for linear state space and non-linear backward-looking MAPS 
% models.
%
% INPUTS:
%   -> modelFileName: full path string name of the *.maps model file
%
% OUTPUTS:  
%   -> modelIsLinearStateSpace: indicator true for linear state space 
%      model, false for non-linear backward-looking model
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> scan_MAPS_text_file
%   -> get_LSS_model_file_config
%   -> get_NLBL_model_file_config
%   -> count_model_components_found (sub-function)
%   -> create_printable_file_name_string
%
% DETAILS:  
%   -> The pre parse module scans in the content of the MAPS file and 
%      checks its content to see if it is linear state space (LSS) or non-
%      linear backward-looking (NLBL). 
%   -> It does that by searching for keywords in the LSS and NLBL model 
%      file configurations. If it fails to find any or finds an equal 
%      number of each type, then it throws an error.
%
% NOTES:
%   -> See <> for information about the format of MAPS model files.
%
% This version: 12/05/2011
% Author(s): Matt Waldron

%% CHECK INPUT
% Check that the number and type of inputs is as expected by the this 
% function.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~ischar(modelFileName)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% SCAN FILE CONTENTS
% Scan the content of the file into MAPS as a cell array of strings. This
% function will throw an error if there is any problem in reading
% information in from the file.
fileContents = scan_MAPS_text_file(modelFileName);

%% CATEGORISE THE MODEL FILE AS LSS OR NLBL
% Read in the linear state space and non-linear baxckward-looking model 
% file configurations and compute the number of keywords for each found in 
% the file contents using a sub-function below. The model is categorised as 
% LSS if there are more keywords from the LSS model configuration than the 
% NLBL configuration and is categorised as non-linear if vice versa (this 
% allows for the possibility that there may be some overlap in the keywords 
% used - eg METADATA could appear in both). If the number of keywords found 
% is equal, then throw an error (depending on whether there were no 
% keywords found or whether a positive but equal number were found).
LSSmodelFileConfig = get_LSS_model_file_config;
nLSSmodelComponents = count_model_components_found(...
    LSSmodelFileConfig,fileContents);
NLBLmodelFileConfig = get_NLBL_model_file_config;
nNLBLmodelComponents = count_model_components_found(...
    NLBLmodelFileConfig,fileContents);
if nLSSmodelComponents > nNLBLmodelComponents
    modelIsLinearStateSpace = true;
elseif nNLBLmodelComponents > nLSSmodelComponents
    modelIsLinearStateSpace = false;
else
    modelFileNamePrint = create_printable_file_name_string(modelFileName);
    if nLSSmodelComponents == 0
        errId = ['MAPS:',mfilename,':BadModelFile'];
        generate_and_throw_MAPS_exception(errId,{modelFileNamePrint});
    else
        errId = ['MAPS:',mfilename,':UncategorisableModelFile'];
        generate_and_throw_MAPS_exception(errId,{modelFileNamePrint});
    end
end

end

%% FUNCTION TO COUNT NUMBER OF MODEL FILE COMPONENTS
function nModelComponentsFound = count_model_components_found(...
    modelFileConfig,fileContents)
% This helper counts the number of file keywords found in the contents. 
% It compares the keywords component of the input model file configuration
% with the input file contents, counting the number of separate keywords
% found.
%
% INPUTS:   
%   -> modelFileConfig: MAPS model file configuration cell array
%   -> fileContents: cell array of scanned model file contents
%
% OUTPUTS:  
%   -> nModelComponentsFound: number of keywords found
%
% CALLS:    
%   -> none

%% COUNT MODEL COMPONENTS PRESENT
% Use the cellfun function to compare each keyword in the configuration
% (the first column of the config input) with every line scanned in from 
% the model text file. Convert the result to a matrix and then sum to find
% the total number of separate keywords found.
nModelComponentsFound = sum(cell2mat(cellfun(...
    @(x) any(strcmp(modelFileConfig(:,1),x)),fileContents,...
    'UniformOutput',false)));

end