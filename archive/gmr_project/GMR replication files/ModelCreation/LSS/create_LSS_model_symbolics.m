function UpdatedModel = create_LSS_model_symbolics(Model)
% This module converts linear model text info into symbolic info.
% It converts string information about model equations, measurement
% equations, data transformation equations and all variable types using a
% mixture of the MATLAB symbolic toolbox and string manipulation. It then 
% converts that symbolic information to function handles which be quickly 
% evaluated numerically in solving the model with substantial performance 
% improvements over MATLAB symbolic evaluation.
%
% INPUTS:
%   -> Model: MAPS linear model structure with string model info
%
% OUTPUTS:
%   -> UpdatedModel: MAPS model structure with (updated) symbolic info
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> unpack_model
%   -> create_lag_mnemonics
%   -> append_strings_and_create_comma_separated_list
%   -> append_strings
%   -> create_LSS_structural_symbolic_matrices
%   -> convert_symbolic_matrices_to_function_handles
%   -> pack_model
%   -> solve_recursive_system_of_equations
%   -> generate_MAPS_exception_add_cause_and_throw
%   -> convert_equations_to_model_ordered_function_handle
%   -> expand_data_transformation_equations_shorthand (sub-function)
%   -> replace_time_subscripts_in_equations
%   -> invert_data_transformation_equations (sub-function)
%
% DETAILS:
%   -> This model creation function creates all symbolic information
%      required for solving MAPS models including the structural matrices
%      in the model equations and measurement equations, the steady state
%      (and parameter transformation) equations and the data transformation 
%      equations.
%   -> It examines the content of the model and only operates on sets of
%      equations that form part of the model input.
%   -> It uses the MATLAB symbolic toolbox to compute the matrices (in
%      symbolic form) associated with the model and measurement equations.
%      It uses direct string manipulation to produce the symbolic set of
%      equations associated with steady states (and parameter 
%      transformations) and data transformations. In both cases, it creates 
%      a set of function handles which can be evaluated at run-time much 
%      more quickly than the symbolic toolbox equivalents.
%
% NOTES:
%   -> This function needs to be upgraded to include the creation of lag 
%      and lead identities.
%   -> This function would also need to be upgraded to permit non-recursive
%      steady state systems of equations.
%   -> Further enhancements could also include additional string
%      manipulations (like derivative computations) which would eliminate
%      the symbolic toolbox altogether.
%   -> See <> for a description of MAPS linear models and their creation.
%
% This version: 11/02/2011
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
    generate_and_throw_MAPS_exception(ModelUnpackE,errId);
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
% Unpack mnemonics and equation strings required for this function.
thetaMnems = unpack_model(Model,{'thetaMnems'});
if modelHasMeasurementEqs
    Ymnems = unpack_model(Model,{'Ymnems'});
end
if modelHasDataTransformationEqs
    [YtildeEqStrs,YtildeMnems] = unpack_model(...
        Model,{'YtildeEqStrs','YtildeMnems'});
    YtildeLagMnems = create_lag_mnemonics(YtildeMnems);
    if modelHasTimeVaryingTrends
        etatMnems = unpack_model(Model,{'etatMnems'});
        etatLagMnems = create_lag_mnemonics(etatMnems);
    end
end
if modelHasSteadyStateEqs
    [ssEqStrs,ssMnems] = unpack_model(Model,{'ssEqStrs','ssMnems'});
end

%% SETUP OUTPUT
% Set the updated model output equal the input model, ready for the
% symbolic information to be added.
UpdatedModel = Model;

%% CREATE SYMBOLIC STATE SPACE MATRICES
% Call a utility function to create the linear state space symbolic 
% structural matrices (using the MATLAB symbolic toolbox). The state space 
% structural matrices created satisfy the following equations symbolically:
% HB*x{t-1}+HC*x{t}+HF*x{t+1} = PSI*z{t}
% Y{t} = D+G*x{t}+V*w{t}
% The symbolic matrices associatd with the measurement equations are only
% computed if the model has measurement equations. If it does, the loadings
% on the measurement errors are only computed if the model has measurement
% errors. Convert the symbolic matrices to function handles that can be 
% evaluated using numeric vector(s). For example, if the model has steady 
% state equations (and/or paramater transformation equations), then a
% numeric vector for the parameters, theta, and steady states / parameter 
% transformations, ss, could be used to evaluate the symbolic function 
% handles (e.g. HB = HBfunHandle(theta,ss)).
mats = {'HB','HC','HF','PSI'};
if modelHasMeasurementEqs
    mats = [mats,{'D','G'}];
    if modelHasMeasurementErrors
        mats = [mats,{'V'}];
    end
end
symMatsList = append_strings_and_create_comma_separated_list(mats,'sym');
funHandleMats = append_strings(mats,'funHandle');
funHandleMatsList = create_comma_separated_list(funHandleMats);
eval(['[',symMatsList,'] = create_LSS_structural_symbolic_matrices(',...
    'Model);']);
matsArgs = {'theta'};
if modelHasSteadyStateEqs
    matsArgs = [matsArgs,{'ss'}];
end
symMatsArgsList = append_strings_and_create_comma_separated_list(...
    matsArgs,'Mnems');
eval(['[',funHandleMatsList,'] = ',...
    'convert_symbolic_matrices_to_function_handles(',...
    'eval(''{',symMatsArgsList,'}''),matsArgs,',symMatsList,');']);
UpdatedModel = pack_model(...
    UpdatedModel,funHandleMats,eval(['{',funHandleMatsList,'}']));

%% CREATE STEADY STATE EQUATION SYMBOLICS
% Create the executable steady state expressions. Solve the recursive 
% steady state system so that the steady states (and parameter
% transformation) variables are functions of parameters (and numerical
% expressions) alone. If the system cannot be reduced in this way throw an
% exception because MAPS does not support non-analytical steady states
% (yet). Convert the equations to a model ordered function handle of steady 
% state and parameter transformation expressions and pack the result into 
% the model.
if modelHasSteadyStateEqs
    try
        ssEqSolvedStrs = solve_recursive_system_of_equations(...
            ssEqStrs,ssMnems);
    catch NonRecursiveEqsE
       errId = ['MAPS:',mfilename,':NonRecursiveSS'];
       generate_MAPS_exception_add_cause_and_throw(NonRecursiveEqsE,errId);        
    end
    SSfunHandle = convert_equations_to_model_ordered_function_handle(...
        ssEqSolvedStrs,ssMnems,{thetaMnems},{'theta'});
    UpdatedModel = pack_model(UpdatedModel,{'SSfunHandle'},{SSfunHandle});
end

%% CREATE DATA TRANSFORMATION SYMBOLICS
% Unpack the data transformation equations and their components (raw 
% observable mnemonics, model observable mnemonics and, if they are part of 
% the model, time-varying determinstic trend mnemonics). Expand the 
% shorthand used in the data transformation equations so that they have the 
% same form as other equation types (ie. contemporaneous and lag variables 
% are identified with {t} and {t-1} subscripts and any "diff"  operators 
% are expanded out (this allows us to operate on them using the same code).
% Replace the time subscrpits in the equations and create lagged versions
% of the raw observables and, if they exist, time trends. Invert the 
% equations to create data retransformations so that raw observable 
% forecasts can be computed given model observable forecasts. Define the
% rhs arguments of the data transformation and data retransformation
% functions as well as the names for those arguments (which depends on 
% whether time trends are part of the model or not). Call a sub-function
% to create the data transformation function handle. If the model has time
% trends, then these have the form: Y = f(Ytilde,YtildeLag,etat,etatLag)
% Ytilde = f(Y,YtildeLag,etat,etatLag). If the model does not have time
% trends then both functions have only the first two arguments.
if modelHasDataTransformationEqs
    YtildeEqStrs = expand_data_transformation_equations_shorthand(...
        YtildeEqStrs);
    YtildeEqStrs = replace_time_subscripts_in_equations(YtildeEqStrs);  
    YtildeEqInvStrs = invert_data_transformation_equations(...
        YtildeEqStrs,YtildeMnems);
    YtildeEqRhsArgs = {YtildeMnems YtildeLagMnems};
    YtildeEqRhsArgNames = {'Ytilde' 'YtildeLag'};
    if modelHasTimeVaryingTrends                
        YtildeEqRhsArgs = [YtildeEqRhsArgs {etatMnems etatLagMnems}];
        YtildeEqRhsArgNames = [YtildeEqRhsArgNames {'etat' 'etatLag'}];
    end
    YtildeEqInvRhsArgs = YtildeEqRhsArgs;
    YtildeEqInvRhsArgNames = YtildeEqRhsArgNames;
    YtildeEqInvRhsArgs{1} = Ymnems;
    YtildeEqInvRhsArgNames{1} = 'Y';    
    DTfunHandle = convert_equations_to_model_ordered_function_handle(...
        YtildeEqStrs,Ymnems,YtildeEqRhsArgs,YtildeEqRhsArgNames);    
    RTfunHandle = convert_equations_to_model_ordered_function_handle(...
        YtildeEqInvStrs,YtildeMnems,YtildeEqInvRhsArgs,...
        YtildeEqInvRhsArgNames);    
    UpdatedModel = pack_model(UpdatedModel,...
        {'DTfunHandle','RTfunHandle'},{DTfunHandle,RTfunHandle});
end

end

%% EXPAND DATA TRANSFORMATION EQUATIONS SHORTHAND
function YtildeEqStrsExpanded = ...
    expand_data_transformation_equations_shorthand(YtildeEqStrs)
% This helper expands out the shorthand used in a transformation equations.
% In particular, it creates time subscripts for the variables and expands 
% out any difference, "diff", operator to be consistent with the format of 
% other types of MAPS model equation.
%
% INPUTS:
%   -> YtildeEqStrs: cell string array of data transformation equations 
%
% OUTPUTS:  
%   -> YtildeEqStrsExpanded: cell string array of rewritten expanded out 
%      data transformation equations
%
% CALLS:
%   -> expand_data_transformation_equation_shorthand

%% CREATE EXPANDED DATA TRANSFORMATION EQUATIONS
% Loop through the data transformation equations, expanding each one out
% with time subscripts and to eliminate the "diff" operator.
nYtildeEqs = size(YtildeEqStrs,1);
YtildeEqStrsExpanded = cell(nYtildeEqs,1);
for iEq = 1:nYtildeEqs
    YtildeEqStrsExpanded{iEq} = ...
        expand_data_transformation_equation_shorthand(YtildeEqStrs{iEq});
end

end

%% EXPAND DATA TRANSFORMATION EQUATION SHORTHAND
function YtildeEqStrExpanded = ...
    expand_data_transformation_equation_shorthand(YtildeEqStr)
% This helper expands out the shorthand used in a transformation equation.
% In particular, it creates time subscripts for the variables and expands 
% out any difference, "diff", operator to be consistent with the format of 
% other types of MAPS model equation.
%
% INPUTS:
%   -> YtildeEqStr: data transformation equation strings
%
% OUTPUTS:  
%   -> YtildeEqStrExpanded: rewritten expanded out data transformation 
%      equation string
%
% CALLS:
%   -> get_valid_mathematical_symbols_for_equations

%% SPLIT THE EQUATION
% Split the equation passed in by the standard mathematical operator
% delimiters.
validMathsSymbols = get_valid_mathematical_symbols_for_equations;
[YtildeEqDelims,YtildeEqSplit] = regexp(...
    YtildeEqStr,['[',validMathsSymbols,']'],'match','split');
YtildeEqSplit = strtrim(YtildeEqSplit);

%% ADD TIME SUBSCRIPTS
% Add time subscripts to the content of the data transformation equations
% (taking care to only add subscripts to variables only and not diff, log, 
% numeric  or "empty" terms in the split). Note that there is an assumption 
% here that the only permitted operators in the data transformation 
% equations are the mathematical symbols defined in the config above,  
% log/diff operators and numbers.
tSubscripts = repmat({'{t}'},size(YtildeEqSplit));
nonVarLogicals = strcmp('diff',YtildeEqSplit)|...
    strcmp('log',YtildeEqSplit)|...
    cellfun(@isempty,YtildeEqSplit)|...
    ~cellfun(@isempty,regexp(YtildeEqSplit,'\<\d+\>','match'));
tSubscripts(nonVarLogicals) = {''};
YtildeEqSplit = strcat(YtildeEqSplit,tSubscripts);

%% EXPAND THE DIFF OPERATOR
% The diff operator is only permitted for use in data transformation
% equations and is not recognised by MAPS' symbolic model creater function.
% This cell expands the diff operator out (if it exists) so that the lagged 
% term is written out explicitly. Note that this code relies on the
% equation being valid in the sense that the diff operator is followed by
% an opening paranthesis. This is consistent with the rules for data
% transformations laid out at the time of writing this code and would need
% to be changed to allow for more general representations (eg. with lagged
% time-varying trend terms).
diffInd = find(strcmp('diff',YtildeEqSplit));
if ~isempty(diffInd)
    outOpenParanInd = diffInd;
    outCloseParanInd = diffInd+find(...
        (cumsum(strcmp('(',YtildeEqDelims(diffInd+1:end)))-...
        cumsum(strcmp(')',YtildeEqDelims(diffInd+1:end))))==-1,1);   
    termToLagTerms = [YtildeEqSplit(outOpenParanInd+1:outCloseParanInd);
        YtildeEqDelims(outOpenParanInd+1:outCloseParanInd-1) {''}];
    termToLag = [termToLagTerms{:}];
    laggedTerm = strrep(termToLag,'{t}','{t-1}');
    YtildeEqSplit{outOpenParanInd} = termToLag;
    YtildeEqSplit{outCloseParanInd+1} = ['-(',laggedTerm,')'];
    if ~strcmp(YtildeEqDelims{diffInd-1},'=')
        YtildeEqSplit{outOpenParanInd} = ...
            ['(',YtildeEqSplit{outOpenParanInd}];
        YtildeEqSplit{outCloseParanInd+1} = ...
            [YtildeEqSplit{outCloseParanInd+1},')'];
    end
    YtildeEqSplit(outOpenParanInd+1:outCloseParanInd) = {''};
    YtildeEqDelims(outOpenParanInd:outCloseParanInd) = {''};
end

%% PUT THE EQUATION BACK TOGETHER
% Put the equation back together again for output.
YtildeEqExpandedTerms = [YtildeEqSplit;YtildeEqDelims {''}];
YtildeEqStrExpanded = [YtildeEqExpandedTerms{:}];

end

%% FUNCTION TO INVERT DATA TRANSFORMATION EQUATIONS
function YtildeEqInvStrs = invert_data_transformation_equations(...
    YtildeEqStrs,YtildeMnems)
% This helper can be used to invert the data transformation equations.
% This is used to create the set of equations that translate data in model
% observable space to raw observable space.
%
% INPUTS:
%   -> YtildeEqStrs: cell string array of data transformation equations
%   -> YtildeMnems: cell string array of raw observable mnemonics
%
% OUTPUTS:
%   -> YtildeEqInvStrs: new cell string array of data re-transformation
%      equations
%
% CALLS:
%   -> compute_equations_incidence_matrix
%   -> rearrange_equation

%% COMPUTE THE INCIDENCE MATRIX OF THE DATA TRANSFORMATION EQUATIONS
% Compute the incidence matrix with respect to the raw observable
% mnemonics (under the assumption that there is just one raw observable on
% the RHS of each equation - ie under the assumption that the equations are 
% valid data transformations).
YtildeEqYtildeIncMat = compute_equations_incidence_matrix(...
    YtildeEqStrs,YtildeMnems);

%% REARRANGE THE MNEMONICS
% Rearrange the mnemonics so that they are ordered as found in the
% equations.
nYtilde = size(YtildeMnems,1);
reorderInds = YtildeEqYtildeIncMat*(1:nYtilde)';
YtildeReMnems = YtildeMnems(reorderInds);

%% REARRANGE THE EQUATIONS
% Rearrange each equation so that the raw observable that appeared on the
% RHS is on the LEHS with all equation terms appropriately inverted.
nYtildeEqs = size(YtildeEqStrs,1);
YtildeEqInvStrs = cell(nYtildeEqs,1);
for iEq = 1:nYtildeEqs
    YtildeEqInvStrs{iEq} = rearrange_equation(...
        YtildeEqStrs{iEq},YtildeReMnems{iEq});
end

end