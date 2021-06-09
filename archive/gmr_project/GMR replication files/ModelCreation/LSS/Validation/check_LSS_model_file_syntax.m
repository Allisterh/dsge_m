function check_LSS_model_file_syntax(...
    FileContents,FileKeywords,FileLineNumbers,ModelFileSyntaxE)
% This function validates the content of an LSS model file.
% It checks that the model file content meets all of the MAPS linear state
% space (LSS) model file syntax rules. It throws an exception detailing the
% cause of any failure if the content does not.
%
% INPUTS:
%   -> FileContents: structure containing all the information in the model
%      file deconstructed into its constituent parts
%   -> FileKeywords: structure (with the same fields as the above) 
%      containing the keywords used in the model file
%   -> FileLineNumbers: structure (with the same fields as the above) 
%      containing the line numbers in the file from which the information
%      was taken
%   -> ModelFileSyntaxE: exception to add causes to
%
% OUTPUTS:
%   -> none
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> get_LSS_model_file_syntax_checks_configs
%   -> check_MAPS_model_file_metadata_syntax
%   -> check_conditionality_of_file_content (sub-function)
%   -> check_conditionality_of_object_numbers (sub-function)
%   -> check_model_equation_syntax (sub-function)
%   -> check_measurement_equation_syntax (sub-function)
%   -> check_data_transformations_syntax (sub-function)
%   -> check_steady_state_expressions_syntax (sub-function)
%   -> check_usage_of_diff_operator_in_data_transformations (sub-function)
%   -> check_usage_of_model_variables_in_measurement_equations
%      (sub-function)
%
% DETAILS:
%   -> This LSS model creation utility completes all documents LSS model 
%      file syntax checks. 
%   -> If it finds any syntax errors, it throws an exception detailing the
%      causes of the error(s) so that users can go into their model files 
%      and fix them.
%   -> The syntax checks are split into two parts: those that relate to
%      metadata syntax which apply to any model (like all mnemonics must be
%      unique etc) and those that relate specifically to LSS model files.
%   -> The content of the shared metadata syntax checking is controlled by
%      a configuration file, which contains information about which model
%      fields to check and any parameters required for the checks.
%   -> The content for the LSS model file specific checks is controlled by
%      a mixture of configuration and rules which are hard-coded in the
%      functions below.
%
% NOTES:
%   -> See <> for more details of MAPS LSS model creation.
%   -> See also <> for a description of the LSS model file syntax checking
%      rules.
%
% This version: 18/06/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Complete some basic checks on the input, including that the number of
% input arguments is correct.
if nargin < 4
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(FileContents)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif ~isstruct(FileKeywords)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);
elseif ~isstruct(FileLineNumbers)
    errId = ['MAPS:',mfilename,':BadInput3'];
    generate_and_throw_MAPS_exception(errId);
elseif ~strcmp(class(ModelFileSyntaxE),'MException')
    errId = ['MAPS:',mfilename,':BadInput4'];
    generate_and_throw_MAPS_exception(errId);
end

%% GET LSS MODEL FILE SYNTAX CHECKS CONFIGS
% Get the configuration information for the metadata syntax checks (eg
% mnemonics must be unique) and the LSS specific syntax checks included as
% sub-functions below.
[metadataSyntaxChecksConfig,LSSmodelSyntaxChecksConfig] = ...
    get_LSS_model_file_syntax_checks_configs;

%% CHECK METADATA
% Call the shared MAPS model file metadata syntax checker to check all of
% the standard MAPS model file metadata syntax rules (like mnemonics must 
% be unique etc). This function will add causes to the exception passed in
% if any are found.
ModelFileSyntaxE = check_MAPS_model_file_metadata_syntax(...
    ModelFileSyntaxE,FileContents,FileKeywords,FileLineNumbers,...
    metadataSyntaxChecksConfig);

%% CHECK LSS MODEL FILE SPECIFIC SYNTAX
% Run through each of the LSS model file specific syntax checks (which are
% coded as sub-functions below) and catch any exceptions encountered as
% causes in the master exception input.
nLSSchecks = size(LSSmodelSyntaxChecksConfig,1);
for iCheck = 1:nLSSchecks
    try
        iCheckFun = str2func(LSSmodelSyntaxChecksConfig{iCheck,1});
        iCheckFun(FileContents,FileKeywords,FileLineNumbers,...
            LSSmodelSyntaxChecksConfig{iCheck,2});
    catch SyntaxFunE
        ModelFileSyntaxE = addCause(ModelFileSyntaxE,SyntaxFunE);
    end
end

%% THROW THE MASTER EXCEPTION IF ANY CHECKS FAIL
% If the master exception contains any causes, throw it out of this
% function.
if ~isempty(ModelFileSyntaxE.cause)
    throw(ModelFileSyntaxE)
end

end

%% FUNCTION TO CHECK CONDITIONALITY OF FILE CONTENT
function check_conditionality_of_file_content(...
    FileContents,FileKeywords,~,conditionCheckConfig)                       %#ok<DEFNU>
% This function validates conditionality of MAPS LSS model file content.
% It checks for fields that should exist in the model if other fields
% exist in the model file.
%
% INPUTS:
%   -> FileContents: structure containing all the information in the model
%      file deconstructed into its constituent parts
%   -> FileKeywords: structure (with the same fields as the above) 
%      containing the keywords used in the model file
%   -> conditionCheckConfig: configuration for the conditionality check as
%      an nConditions*2 cell array of 1*2 cell arrays with the field names
%      of content and the keywords under which they should appear
%
% OUTPUTS:
%   -> none
%
% CALLS:
%   -> generate_MAPS_exception
%   -> generate_MAPS_exception_and_add_as_cause

%% CREATE MASTER EXCEPTION
masterErrId = ['MAPS:',mfilename,':ContentConditionError'];
ContentConditionE = generate_MAPS_exception(masterErrId);

%% CHECK CONDITIONALITY OF CONTENT
% For each content condition violated add an exception as cause explaining
% which expected content was missing (i.e. the condition).
nChecks = size(conditionCheckConfig,1);
for iCheck = 1:nChecks
    if isfield(FileContents,conditionCheckConfig{iCheck,1}{1}) && ...
            ~isfield(FileContents,conditionCheckConfig{iCheck,2}{1})
        errId = [masterErrId,':Instance'];
        errArgs = cell(1,4);
        errArgs{1} = conditionCheckConfig{iCheck,1}{2};
        errArgs{2} = FileKeywords.(conditionCheckConfig{iCheck,1}{1});
        errArgs{3} = conditionCheckConfig{iCheck,2}{2};
        errArgs{4} = conditionCheckConfig{iCheck,2}{3};
        ContentConditionE = generate_MAPS_exception_and_add_as_cause(...
            ContentConditionE,errId,errArgs);       
    end
end

%% THROW EXCEPTION
% Throw the exception out of this function if any causes were added.
if ~isempty(ContentConditionE.cause)
    throw(ContentConditionE);
end

end

%% FUNCTION TO CHECK CONDITIONALITY OF FILE OBJECT NUMBERS
function check_conditionality_of_object_numbers(...
    FileContents,FileKeywords,~,numbersCheckConfig)                         %#ok<DEFNU>
% This function validates numbers in MAPS LSS model file objects.
% It checks that the numbers of objects in particular fields are as
% expected given the numbers of other objects in other particular fields.
%
% INPUTS:
%   -> FileContents: structure containing all the information in the model
%      file deconstructed into its constituent parts
%   -> FileKeywords: structure (with the same fields as the above) 
%      containing the keywords used in the model file
%   -> numbersCheckConfig: configuration for the conditionality check as
%      an nConditions*3 cell array with a string describing the type of 
%      numbers check and two 1*2 cell arrays with the field names
%      of content and a description of them
%
% OUTPUTS:
%   -> none
%
% CALLS:
%   -> generate_MAPS_exception
%   -> generate_MAPS_exception_and_add_as_cause

%% CREATE MASTER EXCEPTION
masterErrId = ['MAPS:',mfilename,':NumbersConditionError'];
NumbersConditionE = generate_MAPS_exception(masterErrId);

%% CHECK CONDITIONALITY OF NUMBERS
% For each number condition violated add an exception as cause explaining 
% which condition was violated.
nChecks = size(numbersCheckConfig,1);
for iCheck = 1:nChecks
    if isfield(FileContents,numbersCheckConfig{iCheck,2}{1}) && ...
            isfield(FileContents,numbersCheckConfig{iCheck,3}{1})
        errorFound = false;
        if strcmp(numbersCheckConfig{iCheck,1},'equal')
            if size(FileContents.(numbersCheckConfig{iCheck,2}{1}),1) ~=...
                    size(FileContents.(numbersCheckConfig{iCheck,3}{1}),1)
                errorFound = true;                
            end
        else
            if size(FileContents.(numbersCheckConfig{iCheck,2}{1}),1) > ...
                    size(FileContents.(numbersCheckConfig{iCheck,3}{1}),1)
                errorFound = true;                
            end           
        end
        if errorFound
            errId = [masterErrId,':Instance'];
            errArgs = cell(1,5);
            errArgs{1} = numbersCheckConfig{iCheck,2}{2};
            errArgs{2} = FileKeywords.(numbersCheckConfig{iCheck,2}{1});
            errArgs{3} = numbersCheckConfig{iCheck,1};
            errArgs{4} = numbersCheckConfig{iCheck,3}{2};
            errArgs{5} = FileKeywords.(numbersCheckConfig{iCheck,3}{1});
            NumbersConditionE = ...
                generate_MAPS_exception_and_add_as_cause(...
                NumbersConditionE,errId,errArgs);
        end
    end
end

%% THROW EXCEPTION
% Throw the exception out of this function if any causes were added.
if ~isempty(NumbersConditionE.cause)
    throw(NumbersConditionE);
end

end

%% FUNCTION TO CHECK MODEL EQUATION SYNTAX
function check_model_equation_syntax(...
    FileContents,FileKeywords,FileLineNumbers,xEqsCheckConfig)              %#ok<DEFNU>
% This function validates LSS model equations and their content.
% Model equations should only contain particular variable types (with the
% correct time subscripts) and they should be valid equations in there own
% right.
%
% INPUTS:
%   -> FileContents: structure containing all the information in the model
%      file deconstructed into its constituent parts
%   -> FileKeywords: structure (with the same fields as the above) 
%      containing the keywords used in the model file
%   -> FileLineNumbers: structure (with the same fields as the above) 
%      containing the line numbers in the file from which the information
%      was taken
%   -> xEqsCheckConfig: configuration for the model equations content check
%
% OUTPUTS:
%   -> none
%
% CALLS:
%   -> generate_MAPS_exception
%   -> check_model_file_equation_syntax

%% CHECK FILE CONTENTS FOR EQUATION INFO
% If the equation information is not part of the file contents, exit this
% sub-function.
if ~isfield(FileContents,xEqsCheckConfig{1})
    return
end

%% SETUP A MASTER EXCEPTION
% Setup a master exception to add causes to as encountered below. This
% exception includes a description of the syntax rules as they relate to
% LSS model equations and the keyword used in the file.
errId = ['MAPS:',mfilename,':ModelEquationSyntaxErrors'];
errArgs = {FileKeywords.(xEqsCheckConfig{1})};
ModelEqSyntaxE = generate_MAPS_exception(errId,errArgs);

%% CHECK EQUATIONS
% Call a MAPS model file equation checking helper to check that the
% equations are valid and have the correct content. 
ModelEqSyntaxE = check_model_file_equation_syntax(...
    ModelEqSyntaxE,FileContents,FileLineNumbers,xEqsCheckConfig);

%% THROW EXCEPTION
% Throw the exception out of this function if any causes were added.
if ~isempty(ModelEqSyntaxE.cause)
    throw(ModelEqSyntaxE);
end
    
end

%% FUNCTION TO CHECK MEASUREMENT EQUATION SYNTAX
function check_measurement_equation_syntax(...
    FileContents,FileKeywords,FileLineNumbers,YeqsCheckConfig)              %#ok<DEFNU>
% This function validates LSS measurement equations and their content. It
% validates that: they are valid equations; they contain only recognised
% variables/parameters with the correct time subscripts; the model 
% observables are uniquely identified across the set of model observables;
% there is only one model variable per equations.
%
% INPUTS:
%   -> FileContents: structure containing all the information in the model
%      file deconstructed into its constituent parts
%   -> FileKeywords: structure (with the same fields as the above) 
%      containing the keywords used in the model file
%   -> FileLineNumbers: structure (with the same fields as the above) 
%      containing the line numbers in the file from which the information
%      was taken
%   -> YeqsCheckConfig: configuration for the measurement equations content
%      check
%
% OUTPUTS:
%   -> none
%
% CALLS:
%   -> generate_MAPS_exception
%   -> check_model_file_equation_syntax
%   -> check_for_var_uniqueness_across_model_file_equations

%% CHECK FILE CONTENTS FOR EQUATION INFO
% If the equation information is not part of the file contents, exit this
% sub-function.
if ~isfield(FileContents,YeqsCheckConfig{1})
    return
end

%% SETUP A MASTER EXCEPTION
% Setup a master exception to add causes to as encountered below. This
% exception includes a description of the syntax rules as they relate to
% LSS measurement equations and the keyword used in the file.
masterErrId = ['MAPS:',mfilename,':MeasurementEquationSyntaxErrors'];
errArgs = {FileKeywords.(YeqsCheckConfig{1})};
MeasurementEqSyntaxE = generate_MAPS_exception(masterErrId,errArgs);

%% CHECK EQUATIONS
% Call a MAPS model file equation checking helper to check that the
% equations are valid and have the correct content. 
YeqsCheckConfigEqSyntax = [YeqsCheckConfig(1) YeqsCheckConfig{2}];
MeasurementEqSyntaxE = check_model_file_equation_syntax(...
    MeasurementEqSyntaxE,FileContents,FileLineNumbers,...
    YeqsCheckConfigEqSyntax);

%% CHECK MODEL OBSERVABLE UNIQUENESS ACROSS EQUATIONS
% The complete set of model observables must be uniquely identified across
% the left-hand-sides of the set of measurement equations.
errId = [masterErrId,':NonUniqueModObsErrors'];
NonUniqueModObsE = generate_MAPS_exception(errId);
YeqsCheckConfigVarRep = [YeqsCheckConfig(1) YeqsCheckConfig{3}];
NonUniqueModObsE = ...
    check_for_var_uniqueness_across_model_file_equations(...
    NonUniqueModObsE,FileContents,FileLineNumbers,YeqsCheckConfigVarRep);
if ~isempty(NonUniqueModObsE.cause)
    MeasurementEqSyntaxE = addCause(MeasurementEqSyntaxE,NonUniqueModObsE);
end

%% CHECK MODEL VARIABLE USAGE
% Only one model variable should appear on the right-hand-side of each
% measurement equation and there should be no repetition of model variables
% across the set of measurement equations.
errId = [masterErrId,':NonUniqueModVarErrors'];
NonUniqueModVarE = generate_MAPS_exception(errId);
YeqsCheckConfigModVars = [YeqsCheckConfig(1) YeqsCheckConfig{4}];
NonUniqueModVarE = ...
    check_for_var_uniqueness_across_model_file_equations(...
    NonUniqueModVarE,FileContents,FileLineNumbers,YeqsCheckConfigModVars);
if ~isempty(NonUniqueModVarE.cause)
    MeasurementEqSyntaxE = addCause(MeasurementEqSyntaxE,NonUniqueModVarE);
end

%% THROW EXCEPTION
% Throw the exception out of this function if any causes were added.
if ~isempty(MeasurementEqSyntaxE.cause)
    throw(MeasurementEqSyntaxE);
end
    
end

%% FUNCTION TO CHECK DATA TRANSFORMATIONS SYNTAX
function check_data_transformations_syntax(...
    FileContents,FileKeywords,FileLineNumbers,YtildeTransCheckConfig)       %#ok<DEFNU>
% This function validates LSS data transformations and their content.
% It validates that: they contain only recognised parameters/variables;
% they are valid mathematical expressions; the raw observables are uniquely
% identified across the set of data transformations; they contain only one
% "diff" operator/
%
% INPUTS:
%   -> FileContents: structure containing all the information in the model
%      file deconstructed into its constituent parts
%   -> FileKeywords: structure (with the same fields as the above) 
%      containing the keywords used in the model file
%   -> FileLineNumbers: structure (with the same fields as the above) 
%      containing the line numbers in the file from which the information
%      was taken
%   -> YtildeTransCheckConfig: configuration for the data transformations
%      content check
%
% OUTPUTS:
%   -> none
%
% CALLS:
%   -> generate_MAPS_exception
%   -> check_model_file_equation_syntax
%   -> check_for_var_uniqueness_across_model_file_equations
%   -> check_usage_of_diff_operator_in_data_transformations (sub-function)

%% CHECK FILE CONTENTS FOR EQUATION INFO
% If the equation information is not part of the file contents, exit this
% sub-function.
if ~isfield(FileContents,YtildeTransCheckConfig{1})
    return
end

%% SETUP A MASTER EXCEPTION
% Setup a master exception to add causes to as encountered below. This
% exception includes a description of the syntax rules as they relate to
% LSS data transformations and the keyword used in the file.
masterErrId = ['MAPS:',mfilename,':DataTransformationSyntaxErrors'];
errArgs = {FileKeywords.(YtildeTransCheckConfig{1})};
DataTransSyntaxE = generate_MAPS_exception(masterErrId,errArgs);

%% CHECK EQUATIONS
% Call a MAPS model file equation checking helper to check that the
% equations are valid and have the correct content.
YtildeTransCheckConfigEqSyntax = ...
    [YtildeTransCheckConfig(1) YtildeTransCheckConfig{2}];
DataTransSyntaxE = check_model_file_equation_syntax(...
    DataTransSyntaxE,FileContents,FileLineNumbers,...
    YtildeTransCheckConfigEqSyntax);

%% CHECK VARIABLE UNIQUENESS ACROSS EQUATIONS
% The complete set of raw observables must be identified uniquely across
% the data transformations.
errId = [masterErrId,':NonUniqueRawObsErrors'];
NonUniqueRawObsE = generate_MAPS_exception(errId);
YtildeTransConfigVarRep = ...
    [YtildeTransCheckConfig(1) YtildeTransCheckConfig{3}];
NonUniqueRawObsE = check_for_var_uniqueness_across_model_file_equations(...
    NonUniqueRawObsE,FileContents,FileLineNumbers,YtildeTransConfigVarRep);
if ~isempty(NonUniqueRawObsE.cause)
    DataTransSyntaxE = addCause(DataTransSyntaxE,NonUniqueRawObsE);
end

%% CHECK "DIFF" OPERATOR USAGE
% Check that the "diff" operators is used at most once in any data
% transformation.
DataTransSyntaxE = check_usage_of_diff_operator_in_data_transformations(...
    DataTransSyntaxE,FileContents,FileLineNumbers,...
    YtildeTransCheckConfig{1});

%% THROW EXCEPTION
% Throw the exception out of this function if any causes were added.
if ~isempty(DataTransSyntaxE.cause)
    throw(DataTransSyntaxE);
end
    
end

%% FUNCTION TO CHECK STEADY STATE DEFINITIONS SYNTAX
function check_steady_state_definitions_syntax(...
    FileContents,FileKeywords,FileLineNumbers,ssDefsCheckConfig)            %#ok<DEFNU>
% This function validates steady states & parameter transformations. It
% validates that they contain only recognised variables/parameters and that
% they are valid mathematical expressions.
%
% INPUTS:
%   -> FileContents: structure containing all the information in the model
%      file deconstructed into its constituent parts
%   -> FileKeywords: structure (with the same fields as the above) 
%      containing the keywords used in the model file
%   -> FileLineNumbers: structure (with the same fields as the above) 
%      containing the line numbers in the file from which the information
%      was taken
%   -> ssDefsCheckConfig: configuration for the steady state & parameter
%      transformations content check
%
% OUTPUTS:
%   -> none
%
% CALLS:
%   -> generate_MAPS_exception
%   -> check_model_file_equation_syntax

%% CHECK FILE CONTENTS FOR EQUATION INFO
% If the equation information is not part of the file contents, exit this
% sub-function.
if ~isfield(FileContents,ssDefsCheckConfig{1})
    return
end

%% SETUP A MASTER EXCEPTION
% Setup a master exception to add causes to as encountered below. This
% exception includes a description of the syntax rules as they relate to
% LSS steady state expressions and the keyword used in the file.
errId = ['MAPS:',mfilename,':SteadyStateDefinitionSyntaxErrors'];
errArgs = {FileKeywords.(ssDefsCheckConfig{1})};
SSdefSyntaxE = generate_MAPS_exception(errId,errArgs);

%% CHECK EQUATIONS
% Call a MAPS model file equation checking helper to check that the
% equations are valid and have the correct content.
SSdefSyntaxE = check_model_file_equation_syntax(...
    SSdefSyntaxE,FileContents,FileLineNumbers,ssDefsCheckConfig);

%% THROW EXCEPTION
% Throw the exception out of this function if any causes were added.
if ~isempty(SSdefSyntaxE.cause)
    throw(SSdefSyntaxE);
end
    
end

%% FUNCTION TO CHECK USAGE OF "DIFF" OPERATOR IN DATA TRANSFORMATIONS
function DataTransSyntaxE = ...
    check_usage_of_diff_operator_in_data_transformations(...
    DataTransSyntaxE,FileContents,FileLineNumbers,...
    YtildeTransFieldName)
% This function checks usage of the "diff" operator in data transformation.
% The diff operator can be used at most once in each data transformation.
% This function validates that.
%
% INPUTS:
%   -> DataTransSyntaxE: data transformations exception to add causes to
%   -> FileContents: structure containing all the information in the model
%      file deconstructed into its constituent parts
%   -> FileLineNumbers: structure (with the same fields as the above) 
%      containing the line numbers in the file from which the information
%      was taken
%   -> YtildeTransFieldName: field name of data transformations
%
% OUTPUTS:
%   -> none
%
% CALLS:
%   -> generate_MAPS_exception_and_add_as_cause

%% UNPACK DATA TRANSFORMATIONS & LINE NUMBERS
YtildeTransformations = FileContents.(YtildeTransFieldName);
YtildeTransformationLineNumbers = FileLineNumbers.(YtildeTransFieldName);

%% RUN THROUGH CHECK
% Split each transformation using MAPS' split equation helper. Check that
% each transformation's split out terms contain at most one diff operator.
% If not, add an exception as cause.
nYtildeTransformations = size(YtildeTransformations,1);
for iTrans = 1:nYtildeTransformations
    iTtransTerms = split_equation(YtildeTransformations{iTrans});
    if sum(strcmp('diff',iTtransTerms)) > 1
       errId = ['MAPS:',mfilename,':TooManyDiffOperators'];
       errArgs = {YtildeTransformations{iTrans} ...
           num2str(YtildeTransformationLineNumbers(iTrans))};
       DataTransSyntaxE = generate_MAPS_exception_and_add_as_cause(...
           DataTransSyntaxE,errId,errArgs);
    end
end

end