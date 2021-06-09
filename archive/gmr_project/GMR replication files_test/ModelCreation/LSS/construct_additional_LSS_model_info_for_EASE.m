function UpdatedModel = construct_additional_LSS_model_info_for_EASE(Model)
% This module adds information required by EASE to LSS models.
% It augments the information already in a linear state space (LSS) model
% structure with additional information required by EASE.
%
% INPUTS:
%   -> Model: MAPS linear state space model structure
%
% OUTPUTS:
%   -> UpdatedModel: MAPS model structure with (updated) info for EASE
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> unpack_model
%   -> compute_equations_incidence_for_EASE (sub-function)
%   -> append_strings
%   -> compute_equations_incidence_matrix_in_string_format
%
% DETAILS:
%   -> This model creation function creates all additional information
%      required by EASE that is not already in the LSS model structure.
%   -> First, it computes incidence information that relates all the
%      variables and parameters in the model with all the equations in the
%      model. This information is used in the model manager section of 
%      EASE. 
%   -> Second, it computes incidence information that defines a valid set
%      of decompositions for the model (i.e. a list of model variable and
%      model equation name pairs for decompositions of model variables
%      using the model equations and model observables using measurement
%      equations.
%
% NOTES:
%   -> See <> for a description of MAPS linear models and their creation.
%
% This version: 24/05/2011
% Author(s): Matt Waldron

%% CHECK INPUT
% Complete a basic check on the number and type of inputs passed in.
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)})
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId)
end

%% VALIDATE MODEL CLASS
% Determine if the model input is linear state space (LSS). If not, throw
% an exception.
modelIsLinearStateSpace = unpack_model(Model,{'modelIsLinearStateSpace'});
if ~modelIsLinearStateSpace
    errId = ['MAPS:',mfilename,':BadModelClass'];
    generate_and_throw_MAPS_exception(errId);
end

%% UNPACK MODEL CHARACTERISTICS INFORMATION
% Unpack model characteristics, which will determine the actions that are
% carries out in this function.
[modelHasMeasurementEqs,modelHasMeasurementErrors,...
    modelHasDataTransformationEqs,modelHasTimeVaryingTrends,...
    modelHasSteadyStateEqs] = unpack_model(Model,...
    {'modelHasMeasurementEqs','modelHasMeasurementErrors',...
    'modelHasDataTransformationEqs','modelHasTimeVaryingTrends',...
    'modelHasSteadyStateEqs'});

%% UNPACK MODEL COMPONENTS REQUIRED
% Unpack mnemonics, equation strings & names required for this function. 
[xEqStrs,xEqNames,xMnems,zMnems,thetaMnems] = unpack_model(...
    Model,{'xEqStrs','xEqNames','xMnems','zMnems','thetaMnems'});
if modelHasMeasurementEqs
    [YeqStrs,YeqNames,Ymnems] = unpack_model(...
        Model,{'YeqStrs','YeqNames','Ymnems'});
    if modelHasMeasurementErrors
        wMnems = unpack_model(Model,{'wMnems'});
    end
end
if modelHasDataTransformationEqs
    [YtildeEqStrs,YtildeEqNames,YtildeMnems] = unpack_model(...
        Model,{'YtildeEqStrs','YtildeEqNames','YtildeMnems'});
    if modelHasTimeVaryingTrends
        etatMnems = unpack_model(Model,{'etatMnems'});        
    end
end
if modelHasSteadyStateEqs
    [ssEqStrs,ssEqNames,ssMnems] = unpack_model(...
        Model,{'ssEqStrs','ssEqNames','ssMnems'});
end

%% SETUP OUTPUT
% Set the updated model output equal the input model, ready for the
% symbolic information to be added.
UpdatedModel = Model;

%% COMPILE ALL MNEMONICS
% Compile a cell string array comprised of all the mnemonics in the model
% being used. These are used below to compute incidence matrices in string
% format for EASE consumption.
allMnems = [xMnems;zMnems;thetaMnems];
if modelHasMeasurementEqs
    allMnems = [allMnems;Ymnems];
    if modelHasMeasurementErrors
        allMnems = [allMnems;wMnems];
    end
end
if modelHasDataTransformationEqs
    allMnems = [allMnems;YtildeMnems];
    if modelHasTimeVaryingTrends
        allMnems = [allMnems;etatMnems];
    end
end
if modelHasSteadyStateEqs
    allMnems = [allMnems;ssMnems];
end

%% COMPILE INFO ABOUT PARAMETER TYPE MNEMONICS
% Compile information about the parameter type mnemonics. These are the
% parameters of the model and, if the model has them, steady states. Note
% that both are also given string names which are used to construct the
% incidence matrices computed below.
paramMnems = {thetaMnems};
paramMnemsName = {'parameter'};
if modelHasSteadyStateEqs
    paramMnems = [paramMnems,{ssMnems}];
    paramMnemsName = [paramMnemsName,{'steadyState'}];
end

%% CREATE MODEL EQUATION INCIDENCE MATRIX
% Compute the incidence matrix for the model equations. The sub-function
% used will return a three-column cell array. The first column will contain
% equation names, the second will contain mnemonic type identifiers -
% either 'varaibles', 'parameter' or 'steadyStates - and the third column
% will contain a mnemonic.
UpdatedModel.EASE.EquationComponents.model = ...
    compute_equations_incidence_for_EASE(...
    xEqStrs,allMnems,xEqNames,paramMnems,paramMnemsName);

%% CREATE MEASUREMENT EQUATION INCIDENCE MATRIX
% If the model has measurement equations, repeat the incidence computation
% as above but for measurement equations.
if modelHasMeasurementEqs
    UpdatedModel.EASE.EquationComponents.measurement = ...
        compute_equations_incidence_for_EASE(...
        YeqStrs,allMnems,YeqNames,paramMnems,paramMnemsName);
end
    
%% CREATE DATA TRANSFORMATION EQUATION INCIDENCE MATRIX
% If the model has data transformation equations, repeat the incidence 
% computation as above but for data transformation equations.
if modelHasDataTransformationEqs
    UpdatedModel.EASE.EquationComponents.dataTransformation = ...
        compute_equations_incidence_for_EASE(...
        YtildeEqStrs,allMnems,YtildeEqNames,paramMnems,paramMnemsName);
end

%% CREATE STEADY STATE EQUATION INCIDENCE MATRIX
% If the model has steady state equations, repeat the incidence 
% computation as above but for steady state equations.
if modelHasSteadyStateEqs
    UpdatedModel.EASE.EquationComponents.steadyState = ...
        compute_equations_incidence_for_EASE(...
        ssEqStrs,allMnems,ssEqNames,paramMnems,paramMnemsName);
end

%% CONSTRUCT DECOMPOSITION INFORMATION
% Construct the valid decomposition information for EASE as the incidence
% information for model variables in model equations and model observables
% in measurement equations. This incidence information is time subscript 
% sensitive because only variables with contemporaneous time subscripts 
% can be decomposed - this is captured in 4th logical input to the helper 
% and the appendage of time subscripts to the variables. See the MAPS 
% decomposition documnetation for more details.
xMnemsWithTimeSubs = append_strings(xMnems,'{t}');
validEquationDecomps = ...
    compute_equations_incidence_matrix_in_string_format(...
    xEqStrs,xMnemsWithTimeSubs,xEqNames,true);
if modelHasMeasurementEqs
    YmnemsWithTimeSubs = append_strings(Ymnems,'{t}');
    validMeasurementEquationDecomps = ...
        compute_equations_incidence_matrix_in_string_format(...
        YeqStrs,YmnemsWithTimeSubs,YeqNames,true);
    validEquationDecomps = [validEquationDecomps;...
        validMeasurementEquationDecomps];
end
validEquationDecomps(:,2) = strrep(validEquationDecomps(:,2),'{t}','');
UpdatedModel.EASE.validEquationDecomps = ...
    [validEquationDecomps(:,2) validEquationDecomps(:,1)];

end

%% FUNCTION TO COMPUTE EQUATION INCIDENCE FOR EASE
function eqIncForEASE = compute_equations_incidence_for_EASE(...
    eqStrs,allMnems,eqNames,paramMnems,paramMnemsName)
% This helper computes equation incidence matrix for EASE.
% It uses a symbolic MAPS function to compute the incidence matrix of the 
% equation with respect to the mnemonics in cell string format and then 
% augments that information with a mnemonic type identifier (i.e. 
% 'variable' or 'parameter').
%
% INPUTS:
%   -> eqStrs: set of equations
%   -> allMnems: all mnemonics in the model
%   -> eqNames: equation names
%   -> paramMnems: row cell array of parameter type mnemonics
%   -> paramMnemsName: row cell array of names for parameter type mnemonics
%
% OUTPUTS:
%   -> eqVarIncForEASE: cell string array incidence matrix for EASE
%
% CALLS:
%   -> compute_equations_incidence_matrix_in_string_format

%% COMPUTE EQUATIONS INCIDENCE MATRIX AS A CELL STRING ARRAY
% Use a symbolic MAPS helper to compute the incidence matrix for the system
% of equations as a two-column cell string array of equation name and
% mnemonic pairs.
eqInc = compute_equations_incidence_matrix_in_string_format(...
    eqStrs,allMnems,eqNames);

%% ADD VARIABLE IDENTIFIER
% Add a 'variable' identifier as a second column in each of the the rows.
nEqIncs = size(eqInc,1);
eqIncForEASE = [eqInc(:,1) repmat({'variable'},[nEqIncs 1]) eqInc(:,2)];

%% OVERWRITE VARIABLE IDENTIFIERS WITH PARAMETER IDENTIFIERS
% Overwrite the variable identifiers that correspond to parameters
% with appropriate identifiers corresponding to the parameter type
% (eg 'parameter' or 'steadyState'). 
nParamTypes = size(paramMnems,2);
for iType = 1:nParamTypes
    eqIncForEASE(ismember(eqIncForEASE(:,3),paramMnems{iType}),2) = ...
        paramMnemsName(iType);
end

end