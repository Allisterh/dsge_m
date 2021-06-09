function validate_LSS_model(Model,modelFileName)
% This macro validates a MAPS linear state space model structure.
% It checks that the syntax in the model is valid (i.e. it passes all 
% linear state space (LSS) model syntax rules) and that the numerical 
% solution in a resolved model is identical (or almost identical) to the 
% one in the model input. 
%
% INPUTS:   
%   -> Model: MAPS model structure
%   -> modelFileName: full path string name of *.maps model file to create
%
% OUTPUTS:  
%   -> none
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> unpack_model
%   -> create_LSS_model_file
%   -> parse_LSS_model
%   -> create_printable_file_name_string
%   -> create_LSS_model_numerics
%   -> are_data_the_same
%   ->  
%
% DETAILS:  
%   -> This macro validates MAPS LSS model structures.
%   -> It checks that the syntax in the model meets MAPS LSS model rules.
%   -> It then checks that the model can be resolved and that the resolved 
%      model is within some tolerance identical to the content of the input
%      model.
%
% NOTES:
%   -> See <> for information about the format of MAPS LSS models.
%   -> If the model file name passed in as input already exists, this
%      function will overwrite that information with the information in the
%      model passed in.
%   -> This logic in this function places a burden on the flexible creation
%      of models that the content of any flexibly-created models must meet
%      the requirements of parsing and syntax checking.
%
% This version: 10/03/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of the inputs is as expected. If not,
% throw a MAPS exception.
if nargin < 2
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);    
elseif ~ischar(modelFileName)
    errId = ['MAPS:',mfilename,':BadInput2'];
    generate_and_throw_MAPS_exception(errId);    
end

%% VALIDATE MODEL CLASS
% Determine if the model input is linear state space (LSS). If not, throw
% an exception.
modelIsLinearStateSpace = unpack_model(Model,{'modelIsLinearStateSpace'});
if ~modelIsLinearStateSpace
    errId = ['MAPS:',mfilename,':BadModelClass'];
    generate_and_throw_MAPS_exception(ModelUnpackE,errId);
end

%% CREATE MAPS MODEL FILE
% Call the MAPS macro to create a MAPS model file from a MAPS model
% structure. Throw any exceptions encountered in creating that file.
try
    create_LSS_model_file(Model,modelFileName);
catch CreateFileE
    errId = ['MAPS:',mfilename,':ModelFileCreationFailure'];
    generate_MAPS_exception_add_cause_and_throw(CreateFileE,errId);
end

%% PARSE NEW MODEL
% Parse the model text file created above to check that it meets parsing
% and model syntax rules. Throw an exception if not.
try
    parse_LSS_model(modelFileName);
catch ParserE
    modelFileNamePrint = create_printable_file_name_string(modelFileName);
    errId = ['MAPS:',mfilename,':ParseFailure'];
    generate_MAPS_exception_add_cause_and_throw(...
        ParserE,errId,{modelFileNamePrint});
end

%% SOLVE MODEL
% Recreate the numeric model using the original model structure to check
% that the numeric model is consistent with the symbolic model.
try 
    NewModel = create_LSS_model_numerics(Model);
    numericCheckTol = 1e-4;
    numericsTheSame = are_data_the_same(...
        NewModel.Numerics,Model.Numerics,numericCheckTol);
    if ~numericsTheSame
        errId = ['MAPS:',mfilename,':ModelNumericsDifferences'];
        generate_and_throw_MAPS_exception(...
            errId,{num2str(numericCheckTol)});
    end
catch ModelSolveE
    errId = ['MAPS:',mfilename,':ModelNumericsProblem'];
    generate_MAPS_exception_add_cause_and_throw(ModelSolveE,errId);
end

%% CHECK EASE INFO
% Check that the EASE information can be reconstructed and that it is the 
% same as that in the model being checked.
%
% This is temporarily commented out because of the hacked decomp
% functionality.
%
% try
%     NewModel = construct_EASE_model_info(NewModel);
%     EASEinfoTheSame = compare_data(NewModel.EASE,Model.EASE,1e-6);
%     if ~EASEinfoTheSame
%         errId = ['MAPS:',mfilename,':EASEinfoProblem:Differences'];
%         generate_and_throw_MAPS_exception(errId);
%     end
% catch EASEinfoE
%     errId = ['MAPS:',mfilename,':EASEinfoProblem'];
%     generate_MAPS_exception_add_cause_and_throw(EASEinfoE,errId);    
% end

end