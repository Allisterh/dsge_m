function [HBsym,HCsym,HFsym,PSIsym,Dsym,Gsym,Vsym] = ...
    create_LSS_structural_symbolic_matrices(...
    Model,xEqStrs,xMnems,zMnems,thetaAndSSmnems,YeqStrs,Ymnems,wMnems)
% This LSS model creation helper creates symbolic structural matrices.
% It uses the MATLAB symbolic toolbox to create symbolic structural 
% matrices associated with the model and measurement equations of MAPS 
% linear state space (LSS) models.
%
% INPUTS:
%   -> Model: MAPS linear model object
%   -> xEqStrs (optional): model equations
%   -> xMnems (optional): model variable mnemonics 
%   -> zMnems (optional): shock mnemonics 
%   -> thetaAndSSmnems (optional): cell array of parameter mnemonics & 
%      steady state mnemonics (model dependent) 
%   -> YeqStrs (optional): measurement equations
%   -> Ymnems (optional): model observable mnemonics
%   -> wMnems (optional & model dependent): measurement error mnemonics
%
% OUTPUTS:  
%   -> HBsym: Jacobian of model equations wrt lagged model variables
%   -> HCsym: Jacobian of model equations wrt cont. model variables
%   -> HFsym: Jacobian of model equations wrt lead model variables
%   -> HBsym: Jacobian of model equations wrt shocks
%   -> Dsym: Constant in measurement equations
%   -> Gsym: Jacobian in measurement equations wrt model variables
%   -> Vsym: Jacobian in measurement equations wrt measurement errors
%
% CALLS:
%   -> generate_and_throw_MAPS_exception
%   -> unpack_model
%   -> create_lag_mnemonics
%   -> create_lead_mnemonics
%   -> replace_time_subscripts_in_equations
%   -> reorder_equations
%   -> create_symbolic_mnemonics
%   -> create_symbolic_equations
%   -> validate_model_equation_symbolics
%   -> validate_masurement_equation_symbolics
%
% DETAILS:  
%   -> This helper creates the symbolic structural matrices assoicated with 
%      MAPS model and measurement equations.
%   -> These are associated with the following structural form for the 
%      model:   HB*x{t-1}+HC*x{t}+HF*x{t+1} = PSI*z{t}
%               Y{t} = D+G*x{t}+V*w{t}
%   -> It assumes that there are only one lead and one lag of the model
%      variables so, if necessary, any lead and lag identities must be
%      created outside of this function.
%   -> The symbolic matrices are in MATLAB symbolic toolbox form. To aid
%      evaluation speed it is recommended that you convert them to function
%      handles using the appropriate MAPS function. 
%   -> The symbolic matrices associated with the measurement equations
%      should only be included in the calling output argument list if the
%      model has measurement equations. If it does not and they are
%      included, then this function throws an error. Similarly, the
%      measurement errors symbolic matrix should not be included in the
%      output argument list if the model does not have measurement errors.
%   -> This function can be used in two input modes. In the first, the only
%      input is the model, in which case the content required to generate
%      the symbolic matrices is unpacked from the model consistent with its
%      type and the output arguments requested. In the second, all the
%      information required to compute the symbolic matrices should be
%      provided as separate input arguments consistent with the output
%      argument list and the model being used. The second mode allows this
%      function to be used when the mnemonic and equation information
%      required to compute the symbolic matrices does not live in the
%      expected place in the model (eg in the construction of new equations
%      in decompositions). This is known as "overloading" a function'
%      inputs.
%
% NOTES:
%   -> See <> for information about the format & construction of MAPS 
%      linear models.
%
% This version: 10/06/2011
% Author(s): Matt Waldron

%% CHECK INPUTS
% Check that the number and shape of inputs is as expected.
if nargin<7 && ~(nargin==1||nargin==5)
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin > 1
    if ~is_column_cell_string_array(xEqStrs)
        errId = ['MAPS:',mfilename,':BadInput2'];
        generate_and_throw_MAPS_exception(errId);
    elseif ~is_column_cell_string_array(xMnems)
        errId = ['MAPS:',mfilename,':BadInput3'];
        generate_and_throw_MAPS_exception(errId);
    elseif ~is_column_cell_string_array(zMnems)
        errId = ['MAPS:',mfilename,':BadInput4'];
        generate_and_throw_MAPS_exception(errId);    
    elseif ~is_row_cell_array(thetaAndSSmnems) || ...
            size(thetaAndSSmnems,2)>2 || ~all(...
            cellfun(@is_column_cell_string_array,thetaAndSSmnems)) 
        errId = ['MAPS:',mfilename,':BadInput5'];
        generate_and_throw_MAPS_exception(errId);
    elseif nargin > 5
        if ~is_column_cell_string_array(YeqStrs)
            errId = ['MAPS:',mfilename,':BadInput6'];
            generate_and_throw_MAPS_exception(errId);
        elseif ~is_column_cell_string_array(Ymnems)
            errId = ['MAPS:',mfilename,':BadInput6'];
            generate_and_throw_MAPS_exception(errId);
        elseif nargin>7 && ~is_column_cell_string_array(wMnems)
            errId = ['MAPS:',mfilename,':BadInput6'];
            generate_and_throw_MAPS_exception(errId);
        end
    end
end

%% CHECK LINEAR MODEL INPUT
% Check that the model input is compatible with this function (ie it is a 
% linear model).
modelIsLinearStateSpace = unpack_model(Model,{'modelIsLinearStateSpace'});
if ~modelIsLinearStateSpace
    errId = ['MAPS:',mfilename,':BadModelClass'];
    generate_and_throw_MAPS_exception(errId);
end

%% UNPACK THE MODEL CHARACTERISTICS REQUIRED
% Unpack the model characteristics components required for this function.
[modelHasMeasurementEqs,modelHasMeasurementErrors,...
    modelHasSteadyStateEqs] = unpack_model(...
    Model,{'modelHasMeasurementEqs','modelHasMeasurementErrors',...
    'modelHasSteadyStateEqs'});

%% CHECK COMPATIBILITY OF INPUTS WITH OUTPUTS IN FUNCTION CALL
% If measurement equation symbolic matrices were requested in the output
% argument list and more than one input was passed in (input mode 2), check
% that the number of inputs provided is sufficient.
if nargout>4 && nargin>1
    if nargin<7
        errId = ['MAPS:',mfilename,':BadNarginMeasEqsNargout'];
        generate_and_throw_MAPS_exception(errId);
    elseif  modelHasMeasurementErrors && nargin<8
        errId = ['MAPS:',mfilename,':BadNarginMeasErsNargout'];
        generate_and_throw_MAPS_exception(errId);
    end
end

%% CHECK COMPATIBILITY OF OUTPUTS WITH THE FUNCTION CALL
% If the model input does not have measurement equations then it is clearly
% not possible to compute the symbolic structural matrices associated with
% the measurement equations. Similarly if the input model does not have
% measurement errors, it is not possible to compute the loadings on the 
% measurement errors in the measurement equations.
if ~modelHasMeasurementEqs && nargout>4
    errId = ['MAPS:',mfilename,':BadNargoutMeasEqs'];
    generate_and_throw_MAPS_exception(errId);
elseif ~modelHasMeasurementErrors && nargout>6
    errId = ['MAPS:',mfilename,':BadNargoutMeasErs'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK COMPATIBILITY OF INPUTS WITH THE FUNCTION CALL
% If the model input does not have measurement equations then the inputs 
% should not include measurement equation information. Similarly, if the 
% input model does not have measurement errors, they should not include 
% measurement errors. And the parameter & steady states cell input should
% have dimension consistent with the presence or otherwise of steady states
% in the model input.
if ~modelHasMeasurementEqs && nargin>5
    errId = ['MAPS:',mfilename,':BadNarginMeasEqs'];
    generate_and_throw_MAPS_exception(errId);
elseif ~modelHasMeasurementErrors && nargin>7
    errId = ['MAPS:',mfilename,':BadNarginMeasErs'];
    generate_and_throw_MAPS_exception(errId);
elseif nargin > 1 
    if modelHasSteadyStateEqs
        if size(thetaAndSSmnems,2) ~= 2
            errId = ['MAPS:',mfilename,':TooFewThetaAndSS'];
            generate_and_throw_MAPS_exception(errId);
        end
    else
        if size(thetaAndSSmnems,2) ~= 1
            errId = ['MAPS:',mfilename,':TooManyThetaAndSS'];
            generate_and_throw_MAPS_exception(errId);
        end
    end
end

%% UNPACK MODEL
% If only one input was provided, unpack the equation strings and model 
% mnemonics required for this function as consistent with the number of 
% output arguments requested and the model type.
if nargin == 1
    [xEqStrs,xMnems,zMnems,thetaMnems] = unpack_model(...
        Model,{'xEqStrs','xMnems','zMnems','thetaMnems'});
    if modelHasSteadyStateEqs
        ssMnems = unpack_model(Model,{'ssMnems'});
    end
    if modelHasMeasurementEqs && nargout>4
        [YeqStrs,Ymnems] = unpack_model(Model,{'YeqStrs','Ymnems'});
        if modelHasMeasurementErrors
            wMnems = unpack_model(Model,{'wMnems'});
        end
    end
end

%% UNPACK PARAMETERS & STEADY STATE MNEMONICS
% If more than one input was passed in, unpack the parameter & steady state
% mnemonics as appropriate given the model type.
if nargin > 1
    thetaMnems = thetaAndSSmnems{1};
    if modelHasSteadyStateEqs
        ssMnems = thetaAndSSmnems{2};
    end
end

%% CREATE LAG AND LEAD MODEL VARIABLE MNEMONICS
% Create lag and lead model variable mnemonics in order to calculate the
% lead and lag derivatives of the model equation. 
xLagMnems = create_lag_mnemonics(xMnems);
xLeadMnems = create_lead_mnemonics(xMnems);

%% RESET SYMBOLIC ENGINE
% Reset the MATLAB symbolic engine. This command is a workaround to a
% possible memory leak in the MATLAB symbolic MuPaD engine (applying as of
% version 2009b) which results in the performance of the symbolic toolbox
% deteriorating over time (which without this command would result in
% approx. doubling of time in this function each time it was called in the 
% same MATLAB session).
reset(symengine);

%% CREATE SYMBOLIC MNEMONICS
% Create symbolic vector equivalents to the cell sring array mnemonics 
% unpacked above. If the model has steady state equations unpack steady
% state mnemonics and create the symbolci equivalent. Note that the call
% to the symbolic mnemonic creater function assigns the individual mnemonic
% symbolics into the workspace of this function. This is required to create
% the symbolic equations below. Note also that the parameter and steady
% state mnemonics are not needed as a vector in this function so the
% function calls in these two cases do not include an output argument (but
% the individual symbolic mnemonics are still required to create the
% symbolic equations).
create_symbolic_mnemonics(thetaMnems);
zSyms = create_symbolic_mnemonics(zMnems);
xSyms = create_symbolic_mnemonics(xMnems);
xLagSyms = create_symbolic_mnemonics(xLagMnems);
xLeadSyms = create_symbolic_mnemonics(xLeadMnems);
if modelHasSteadyStateEqs
    create_symbolic_mnemonics(ssMnems);
end
if modelHasMeasurementEqs  && nargout>4
    Ysyms = create_symbolic_mnemonics(Ymnems);
    if modelHasMeasurementErrors
        wSyms = create_symbolic_mnemonics(wMnems);
    end   
end

%% REPLACE TIME SUBSCRIPTS IN THE EQUATION STRINGS
% Replace the {t-1}, {t} and {t+1} time subscript identifiers used in the
% MAPS model file equations with '_b', '' and '_f' to identify the time
% subscripts because the symbolic toolbox cannot work with curly braces
% like the ones above.
xEqSymStrs = replace_time_subscripts_in_equations(xEqStrs);
if modelHasMeasurementEqs && nargout>4
    YeqSymStrs = replace_time_subscripts_in_equations(YeqStrs);
    try
        YeqReStrs = reorder_equations(YeqSymStrs,Ymnems);
    catch MeasEqsRorderE
        errId = ['MAPS:',mfilename,':MeasEqsReorderError'];
        generate_MAPS_exception_add_cause_and_throw(MeasEqsRorderE,errId);
    end
end

%% CREATE SYMBOLIC EQUATIONS
% Create the symbolic equations from the string equations and the symbolic
% mnemonics already created. Note that the equations are created in the
% workspace of this function reflecting that the symbolic mnemonics were
% also created in the workspace of this function. See the content of the
% create symbolic equations function for more details.
xEqSyms = create_symbolic_equations(xEqSymStrs);
if modelHasMeasurementEqs && nargout>4
    YeqSyms = create_symbolic_equations(YeqReStrs);
end

%% COMPUTE SYMBOLIC MATRICES
% Compute the symbolic matrices as the Jacobian (using the MATLAB symbolic 
% toolbox) of the symblic model equations with respect to the lagged model 
% variables, contemporaneous model variables, lead model variables and the 
% negative of the shocks. Compute the measurement equation symbolics (as
% appropriate for the output number and model type) in a similar way.
% Validate both using the sub-functions below.
HBsym = jacobian(xEqSyms,xLagSyms);
HCsym = jacobian(xEqSyms,xSyms);
HFsym = jacobian(xEqSyms,xLeadSyms);
PSIsym = -jacobian(xEqSyms,zSyms);
validate_model_equation_symbolics(HBsym,HCsym,HFsym,PSIsym,...
    xEqSyms,xSyms,xLagSyms,xLeadSyms,zSyms,...
    xEqStrs,xMnems,xLagMnems,xLeadMnems,zMnems);
if modelHasMeasurementEqs && nargout>4
    Gsym = jacobian(YeqSyms,xSyms);
    if modelHasMeasurementErrors
        Vsym = jacobian(YeqSyms,wSyms);
        Dsym = simplify(YeqSyms+Ysyms-Gsym*xSyms-Vsym*wSyms);
        validate_masurement_equation_symbolics(...
            Gsym,xMnems,YeqStrs,Vsym,wMnems);
    else
        Dsym = simplify(YeqSyms+Ysyms-Gsym*xSyms);
        validate_masurement_equation_symbolics(...
            Gsym,xMnems,YeqStrs);
    end   
end

end

%% FUNCTION TO VALIDATE MODEL EQUATION SYMBOLICS
function validate_model_equation_symbolics(HBsym,HCsym,HFsym,PSIsym,...
    xEqSyms,xSyms,xLagSyms,xLeadSyms,zSyms,xEqStrs,xMnems,xLagMnems,...
    xLeadMnems,zMnems)
% This helper validates the model equation symbolic matrices.
% It checks that they are both linear and mean zero (have no constants). If
% the symbolics fail validation, it throws an exception detailing the
% cause(s) of the validation failure.
%
% INPUTS:
%   -> HBsym: jacobian with respect to the lagged model variables
%   -> HCsym: jacobian with respect to the model variables
%   -> HCsym: jacobian with respect to the leads of model variables
%   -> PSIsym jacobian with respect to the shocks
%   -> xEqSyms: symbolic representations of the model equations 
%   -> xSyms: symbolic representations of the model variable mnemonics
%   -> xLagSyms: symbolic representations of the lagged variable mnemonics
%   -> xLeadSyms: symbolic representations of the variable mnemonic leads
%   -> zSyms: symbolic representations of the shock mnemonics
%   -> xEqStrs: model equation strings 
%   -> xMnems: model variable mnemonics 
%   -> xLagMnems: lagged model variable mnemonics 
%   -> xLeadMnems: model variable leads mnemonics 
%   -> zMnems: shock mnemonics
%
% OUTPUTS:  
%   -> none
%
% CALLS:
%   -> generate_MAPS_exception
%   -> check_for_non_linearity_in_symbolics (sub-function)
%   -> find_mnemonics_in_symbolic_matrix (sub-function)
%   -> generate_MAPS_exception_and_add_as_cause

%% SETUP MASTER EXCETPION
% The rules are that the model equations must be linear and cannot contain
% constants (i.e. must be mean zero).
masterErrId = ['MAPS:',mfilename,':BadlySpecifiedModelEqs'];
BadlySpecifiedModelEqsE = generate_MAPS_exception(masterErrId);

%% CHECK FOR NON-LINEARITIES
% Check for non-linearities in any of the equations. These show up as the
% Jacobians of the model equation with respect to any of the shocks, 
% contemporaneous, lag or lead model variables being functions of any of
% those variables being functions of any of those variable types (i.e. non-
% zero 2nd derivatives). If there are any, find the equations in which they
% appear and add causes to the master exception with those equations and 
% the terms in the non-linear functions using the sub-function below.
xEqArgMnems = [xMnems;xLagMnems;xLeadMnems;zMnems];
xEqSymMats = [HBsym HCsym HFsym PSIsym];
[BadlySpecifiedModelEqsE,nonLinearEqInds] = ...
    check_for_non_linearity_in_symbolics(...
    BadlySpecifiedModelEqsE,xEqStrs,xEqSymMats,xEqArgMnems);

%% CHECK FOR CONSTANTS
% Compute any constants left over in the model equations after the
% derivatives were taken. If there are any, construct an exception with the
% equations in which they appear and the terms involved. Notice that
% non-linearities will also show up as constants. To avoid any confusing
% errors, no exceptions are created for constants in equations that were
% also non-linear.
xEqConstantSyms = simplify(...
    xEqSyms-HBsym*xLagSyms-HCsym*xSyms-HFsym*xLeadSyms+PSIsym*zSyms);
if ~all(xEqConstantSyms==0)
    errId = [masterErrId,':ConstantInModelEq'];
    errArgs = cell(1,2);
    badEqInds = find(xEqConstantSyms~=0);
    nBadEqs = size(badEqInds,1);
    for iEq = 1:nBadEqs
        if any(badEqInds(iEq)==nonLinearEqInds)
            continue
        else
            iBadEqConstantStr = char(xEqConstantSyms(badEqInds(iEq),:));            
            errArgs{1} = xEqStrs{badEqInds(iEq)};
            errArgs{2} = iBadEqConstantStr;
            BadlySpecifiedModelEqsE = ...
                generate_MAPS_exception_and_add_as_cause(...
                BadlySpecifiedModelEqsE,errId,errArgs);
        end
    end 
end

%% THROW EXCEPTION
if ~isempty(BadlySpecifiedModelEqsE.cause)
    throw(BadlySpecifiedModelEqsE);
end

end

%% FUNCTION TO VALIDATE MEASUREMENT EQUATION SYMBOLICS
function validate_masurement_equation_symbolics(...
    Gsym,xMnems,YeqStrs,Vsym,wMnems)
% This helper validates the measurement equation symbolic matrices.
% It checks that they are linear with respect to model variables and any
% measurement errors.
%
% INPUTS:
%   -> Gsym: jacobian with respect to the model variables
%   -> xMnems: model variable mnemonics
%   -> YeqStrs: measurement equation strings
%   -> Vsym: jacobian with respect to any measurement errors
%   -> wMnems measurement error mnemonics
%
% OUTPUTS:  
%   -> none
%
% CALLS:
%   -> generate_MAPS_exception
%   -> check_for_non_linearity_in_symbolics (sub-function)

%% SETUP MASTER EXCETPION
% The rules are that the model equations must be linear.
masterErrId = ['MAPS:',mfilename,':BadlySpecifiedMeasEqs'];
BadlySpecifiedMeasEqsE = generate_MAPS_exception(masterErrId);

%% CHECK FOR NON-LINEARITIES
% Check for non-linearities in any of the equations. These show up as the
% Jacobians of the model equation with respect to the model variables or, 
% if applicable, the measurement errors being functions of those variable 
% types (i.e. non-zero 2nd derivatives). If there are any, find the 
% equations in which they appear and add causes to the master exception
% with those equations and the terms in the non-linear functions using the 
% sub-function below.
YeqSymMats = Gsym;
YeqArgMnems = xMnems;
if nargin == 5
    YeqSymMats = [YeqSymMats Vsym];
    YeqArgMnems = [YeqArgMnems;wMnems];
end
BadlySpecifiedMeasEqsE = check_for_non_linearity_in_symbolics(...
    BadlySpecifiedMeasEqsE,YeqStrs,YeqSymMats,YeqArgMnems);

%% THROW EXCEPTION
if ~isempty(BadlySpecifiedMeasEqsE.cause)
    throw(BadlySpecifiedMeasEqsE);
end

end

%% FUNCTION TO CHECK FOR NON-LINEARITY IN SYMBOLIC MATRICES
function [BadlySpecifiedEqsE,nonLinearEqInds] = ...
    check_for_non_linearity_in_symbolics(...
    BadlySpecifiedEqsE,eqStrs,eqSymMats,eqArgMnems)
% This helper validates that equations are linear in particular vars.
% It operates on symbolic Jacobian's of the equations that should be linear
% with respect to a particular set of variables.
%
% INPUTS:
%   -> BadlySpecifiedEqsE: exception to add causes to
%   -> eqStrs: equation strings
%   -> eqSymMats: symbolic matrices
%   -> eqArgMnems: equation mnemonic arguments (variables that should
%      appear linearly)
%
% OUTPUTS:  
%   -> BadlySpecifiedEqsE: updated exception
%   -> nonLinearEqInds: index numbers of non-linear equations
%
% CALLS:
%   -> find_mnemonics_in_symbolic_matrix (sub-function)
%   -> check_for_non_linearity_in_symbolics (sub-function)

%% EXTRACT MNEMONICS FROM THE SYMBOLIC MATRIX
% Use a sub-function to extract all the symbolic mnemonics as a column cell
% string array.
eqSymMnems = find_mnemonics_in_symbolic_matrix(eqSymMats);

%% SETUP A LOGICAL VECTOR FOR RECORD OF WHICH EQUATIONS WERE NON-LIENAR
nEqs = size(eqSymMats,1);
nonLinearEqLogicals = false(nEqs,1);

%% CHECK LINEARITY
% Validate that none of the symbolic variables appearing in the Jacobians
% form part of the list of variables that should be linear. If any do, add
% exceptions as cause to the exception passed in, outlining the equations
% which violate linearity and the non-linear terms found.
if any(ismember(eqSymMnems,eqArgMnems))
    masterErrId = ['MAPS:',mfilename,':NonLinearity'];
    errId = [masterErrId,':Instance'];
    for iEq = 1:nEqs
        iEqSymMnems = find_mnemonics_in_symbolic_matrix(eqSymMats(iEq,:));
        iEqNonLinearSymMnemInds = find(ismember(iEqSymMnems,eqArgMnems));
        if ~isempty(iEqNonLinearSymMnemInds)
            NonLinearityInEqsE = generate_MAPS_exception(...
                masterErrId,eqStrs(iEq));
            nonLinearEqLogicals(iEq) = true;
            nNonLinearInds = size(iEqNonLinearSymMnemInds,1);
            for iInd = 1:nNonLinearInds
                nonLinearMnem = add_time_subscript_to_mnemonic(...
                    iEqSymMnems{iEqNonLinearSymMnemInds(iInd)});
                NonLinearityInEqsE = ...
                    generate_MAPS_exception_and_add_as_cause(...
                    NonLinearityInEqsE,errId,{nonLinearMnem});
            end
            BadlySpecifiedEqsE = addCause(...
                BadlySpecifiedEqsE,NonLinearityInEqsE);
        end
    end
end

%% CONVERT LOGICAL RECORD TO INDICES
nonLinearEqInds = find(nonLinearEqLogicals);

end

%% FUNCTION TO EXTRACT VARIABLES FROM A SYMBOLIC MATRIX
function mnemsInSymMat = find_mnemonics_in_symbolic_matrix(symMat)
% This helper extracts symbolic variables from a symbolic matrix.
% It extracts all of the symbolic variables appearing anywhere in the input
% symbolic matrix as a column cell string array.
%
% INPUTS:
%   -> symMat: symbolic matrix
%
% OUTPUTS:  
%   -> mnemsInSymMat: column cell string array of variables
%
% CALLS:
%   -> none

%% EXTRCAT VARIABLES AS A LIST
% Use the symbolic toolbox command "findsym" to extract a single character
% array list of the symbolic variables in the matrix.
mnemsInSymMatList = symvar(symMat);
mnemsInSymMatList = char(mnemsInSymMatList);

%% EXTRACT VARIABLES FROM LIST
% Split the list into its constituent parts and transpose to a column cell
% string array.
mnemsInSymMat = regexp(mnemsInSymMatList,'','split')';

end

%% FUNCTION TO RE-ADD TIME SUBSCRIPTS
function nonLinearMnemWithTimesubs = add_time_subscript_to_mnemonic(...
    nonLinearMnem)
% This helper reverses the removal of time subscripts to re-add them.
% It re-adds time subscripts to a symbolic variable for display in error
% messages.
%
% INPUTS:
%   -> nonLinearMnem: mnemonic without time subscript
%
% OUTPUTS:  
%   -> nonLinearMnemWithTimesubs: mnemonic with time subscript
%
% CALLS:
%   -> none

%% RE-ADD TIME SUBSCRIPT
% Symbolic variables either have no time subscript if they are 
% contemporaneous or are appended with '_b' and '_f' if they are lags or
% leads.
if ~isempty(regexp(nonLinearMnem,'_b$','match'))
    nonLinearMnemWithTimesubs = [nonLinearMnem,'{t-1}'];
elseif ~isempty(regexp(nonLinearMnem,'_f$','match'))
    nonLinearMnemWithTimesubs = [nonLinearMnem,'{t+1}'];
else
    nonLinearMnemWithTimesubs = [nonLinearMnem,'{t}'];
end

end
