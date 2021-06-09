function isYtildeStationary = ...
    determine_stationarity_of_raw_observables(Model)
% This LSS model content utility assertains wheter each RO is stationary.
% It uses information inherent in the input model's data transformation
% equations to determine whether each of the model's raw obsewrvables is
% stationary or not (in which case they may be trend or difference
% stationary).
% 
% INPUTS:
%   -> Model: LSS model structure
%
% OUTPUTS:
%   -> isYtildeStationary: nY*1 vector of logicals
%
% DETAILS:
%   -> This model content utility assertains whether each of the raw
%      observables in an LSS model is stationary or not.
%   -> It does that by computing a simulation journey base and then
%      examining the data in that base.
%   -> For example, any data transformation equation with the "diff"
%      operator in it is likely to be associated with a non-stationary
%      observable (eg GDP in COMPASS). Alternatively, those that map
%      variables in levels are likely to be stationary (eg interest rate in
%      COMPASS).
%
% NOTES:
%   -> It is possible that future versions of MAPS could store this
%      information on the model.
%
% This version: 09/12/2013
% Author(s): Matt Waldron

%% CHECK INPUT
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId);
elseif ~isstruct(Model)
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK MODEL IS LSS
modelIsLSS = unpack_model(Model,'modelIsLinearStateSpace');
if ~modelIsLSS
    errId = ['MAPS:',mfilename,':BadModelClass'];
    generate_and_throw_MAPS_exception(errId);
end

%% CHECK MODEL HAS RAW OBSERVABLES
modelHasRawObservables = unpack_model(...
    Model,'modelHasDataTransformationEqs');
if ~modelHasRawObservables
    errId = ['MAPS:',mfilename,':BadModelCharacteristic'];
    generate_and_throw_MAPS_exception(errId);
end

%% CREATE SIMULATION BASE
% The choice of a forecast horizon equal to 2 reflects that it is the
% minimum necessary to determine stationarity.
SimDataBase = create_simulation_journey_base(Model,2);

%% DETERMINE IF THE RO ARE STATIONARY
% They are treated as stationary if they have the same values over the
% forecast in the sim base.
YtildeBase = SimDataBase.Forecast.rawObservables;
diffYtildeBase = diff(YtildeBase,1,2);
isYtildeStationary = ~any(diffYtildeBase,2);

end