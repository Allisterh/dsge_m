function LSSmodelStruct = get_LSS_model_structure_config
% This config contains info about the structure of MAPS linear models.
% It associates each individual component of MAPS linear state space models
% with a location in MAPS linear model object structures.
%
% INPUTS:
%   -> none
%
% OUTPUTS:
%   -> LSSmodelStruct: structure detailing the configuration of MAPS 
%      linear state space models
%
% CALLS:
%   -> none
%
% DETAILS:  
%   -> This configuration function is used by the modules within the 
%      linear state space model creater macro to package the MAPS linear 
%      model object. 
%   -> It can also be used in conjunction with the unpack_model and 
%      pack_model helpers to unpack & pack or repack individual 
%      components of the model.
%   -> Each of the fields in the structure below is a recognised name for
%      a particular component of a MAPS linear model (eg xMnems are model 
%      variable mnemonics).  The string to the right of the equal sign
%      describes where information about that model component "lives" in
%      the model object.
%
% NOTES:
%   -> See XXXXX for a description of MAPS linear state space model 
%      objects.
%
% This version: 29/01/2013
% Author(s): Matt Waldron & Kate Reinold

%% LIST OF MODEL CONSTRUCTOR DEFINITIONS
% Define the configuration information about each compoenent of MAPS linear
% model object structures.
LSSmodelStruct.metadataFields = 'Model.Info.Metadata.metadataFields';
LSSmodelStruct.metadataDescriptors = 'Model.Info.Metadata.metadataDescriptors';
LSSmodelStruct.xMnems = 'Model.Info.Variables.ModelVariables.mnemonics';
LSSmodelStruct.xNames = 'Model.Info.Variables.ModelVariables.names';
LSSmodelStruct.zMnems = 'Model.Info.Variables.Shocks.mnemonics';
LSSmodelStruct.zNames = 'Model.Info.Variables.Shocks.names';
LSSmodelStruct.Ymnems = 'Model.Info.Variables.ModelObservables.mnemonics';
LSSmodelStruct.Ynames = 'Model.Info.Variables.ModelObservables.names';
LSSmodelStruct.YtildeTransformations = 'Model.Info.Variables.ModelObservables.dataTransformations';
LSSmodelStruct.wMnems = 'Model.Info.Variables.MeasurementErrors.mnemonics';
LSSmodelStruct.wNames = 'Model.Info.Variables.MeasurementErrors.names';
LSSmodelStruct.YtildeMnems = 'Model.Info.Variables.RawObservables.mnemonics';
LSSmodelStruct.YtildeNames = 'Model.Info.Variables.RawObservables.names';
LSSmodelStruct.ssMnems = 'Model.Info.Variables.SteadyStates.mnemonics';
LSSmodelStruct.ssNames = 'Model.Info.Variables.SteadyStates.names';
LSSmodelStruct.etatMnems = 'Model.Info.Variables.TimeVaryingTrends.mnemonics';
LSSmodelStruct.etatNames = 'Model.Info.Variables.TimeVaryingTrends.names';
LSSmodelStruct.thetaMnems = 'Model.Info.Parameters.mnemonics';
LSSmodelStruct.thetaNames = 'Model.Info.Parameters.names';
LSSmodelStruct.xEqStrs = 'Model.Info.Equations.Model.strings';
LSSmodelStruct.xEqNames = 'Model.Info.Equations.Model.names';
LSSmodelStruct.YeqStrs = 'Model.Info.Equations.Measurement.strings';
LSSmodelStruct.YeqNames = 'Model.Info.Equations.Measurement.names';
LSSmodelStruct.ssDefs = 'Model.Info.Equations.SteadyState.definitions';
LSSmodelStruct.ssEqStrs = 'Model.Info.Equations.SteadyState.strings';
LSSmodelStruct.ssEqNames = 'Model.Info.Equations.SteadyState.names';
LSSmodelStruct.YtildeEqStrs = 'Model.Info.Equations.DataTransformation.strings';
LSSmodelStruct.YtildeEqNames = 'Model.Info.Equations.DataTransformation.names';
LSSmodelStruct.modelIsLinearStateSpace = 'Model.Type.Class.isLinearStateSpace';
LSSmodelStruct.modelIsForwardLooking = 'Model.Type.Class.isForwardLooking';
LSSmodelStruct.modelHasDataTransformationEqs = 'Model.Type.Characteristics.hasDataTransformationEquations';
LSSmodelStruct.modelHasTimeVaryingTrends = 'Model.Type.Characteristics.hasTimeVaryingTrends';
LSSmodelStruct.modelHasMeasurementEqs = 'Model.Type.Characteristics.hasMeasurementEquations';
LSSmodelStruct.modelHasMeasurementErrors = 'Model.Type.Characteristics.hasMeasurementErrors';
LSSmodelStruct.modelHasSteadyStateEqs = 'Model.Type.Characteristics.hasSteadyStateEquations';
LSSmodelStruct.modelHasDecompAddOn = 'Model.Type.AddOns.hasDecompostionsAddOn';
LSSmodelStruct.modelName = 'Model.Metadata.name';
LSSmodelStruct.modelDescription = 'Model.Metadata.description';
LSSmodelStruct.modelAuthor = 'Model.Metadata.author';
LSSmodelStruct.modelCreationDate = 'Model.Metadata.creationDate';
LSSmodelStruct.HBfunHandle = 'Model.Symbolics.ModelEquations.backwardLoadings';
LSSmodelStruct.HCfunHandle = 'Model.Symbolics.ModelEquations.contemporaneousLoadings';
LSSmodelStruct.HFfunHandle = 'Model.Symbolics.ModelEquations.forwardLoadings';
LSSmodelStruct.PSIfunHandle = 'Model.Symbolics.ModelEquations.shockLoadings';
LSSmodelStruct.DfunHandle = 'Model.Symbolics.MeasurementEquations.constants';
LSSmodelStruct.GfunHandle = 'Model.Symbolics.MeasurementEquations.modelVariableLoadings';
LSSmodelStruct.VfunHandle = 'Model.Symbolics.MeasurementEquations.measurementErrorLoadings';
LSSmodelStruct.SSfunHandle = 'Model.Symbolics.SteadyStateEquations';
LSSmodelStruct.DTfunHandle = 'Model.Symbolics.DataTransformations.rawToModelObservables';
LSSmodelStruct.RTfunHandle = 'Model.Symbolics.DataTransformations.modelToRawObservables';
LSSmodelStruct.theta = 'Model.Numerics.parameters';
LSSmodelStruct.HB = 'Model.Numerics.ModelEquations.backwardLoadings';
LSSmodelStruct.HC = 'Model.Numerics.ModelEquations.contemporaneousLoadings';
LSSmodelStruct.HF = 'Model.Numerics.ModelEquations.forwardLoadings';
LSSmodelStruct.PSI = 'Model.Numerics.ModelEquations.shockLoadings';
LSSmodelStruct.D = 'Model.Numerics.MeasurementEquations.constants';
LSSmodelStruct.G = 'Model.Numerics.MeasurementEquations.modelVariableLoadings';
LSSmodelStruct.V = 'Model.Numerics.MeasurementEquations.measurementErrorLoadings';
LSSmodelStruct.B = 'Model.Numerics.Solution.backwardLoadings';
LSSmodelStruct.F = 'Model.Numerics.Solution.forwardLoadings';
LSSmodelStruct.PHI = 'Model.Numerics.Solution.shockLoadings';
LSSmodelStruct.ss = 'Model.Numerics.Solution.steadyState';
LSSmodelStruct.P = 'Model.Numerics.Solution.varianceCovariance';
LSSmodelStruct.HBdecomp = 'Model.Numerics.ModelEquations.backwardLoadings';
LSSmodelStruct.HCdecomp = 'Model.Numerics.ModelEquations.contemporaneousLoadings';
LSSmodelStruct.HFdecomp = 'Model.Numerics.ModelEquations.forwardLoadings';
LSSmodelStruct.PSIdecomp = 'Model.Numerics.ModelEquations.shockLoadings';
LSSmodelStruct.xDecompMnems = 'Model.Info.Variables.ModelVariables.mnemonics';
LSSmodelStruct.xEqDecompNames = 'Model.Info.Equations.Model.names';
LSSmodelStruct.xEqDecompStrs = 'Model.Info.Equations.Model.strings';

end