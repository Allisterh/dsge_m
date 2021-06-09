function xGrowth = pct(x)
% Calculates the quarterly percentage changes in a matrix of time series.
%
% INPUTS:
%   -> x: nSeries*T matrix of time series data
%
% OUTPUTS:
%   -> xGrowth: nSeries*T matrix of growth rates (with NaNs in 1st col)
%
% DETAILS:
%   -> Calculates quarterly growth rates of a set of time series.
%   -> The time series are assumed to be consistent with the MAPS
%      convention with series identified by row and time period identified
%      by column.
%   -> The quarterly growth rates in the first period are undefined and
%      this function returns NaNs in that period (which ensures the output
%      matrix is of the same dimension as the input matrix).
%
% NOTES:
%   -> Technically, this function computes one-period growth rates. These
%      are only interpretable as quarterly if the underlying data is
%      quarterly.
%   -> The naming convention for this function replicates the TSV naming
%      convention - see also "ytypct".
%
% This version: 07/04/2014
% Author(s): Matt Waldron

%% CHECK INPUTS
if nargin < 1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_real_two_dimensional_numeric_matrix(x);
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% COMPUTE DIMENSION OF INPUT DATA
[nx,T] = size(x);

%% TESTS SUITABILITY OF MATRIX
% In order to compute well-defined growth rates, the input time seris
% cannot contain any zeros and must span at least 2 periods of data.
if any(any(x==0))
    errId = ['MAPS:',mfilename,':ContainsZeros'];
    generate_and_throw_MAPS_exception(errId);
elseif T < 2
    errId = ['MAPS:',mfilename,':TooShort'];
    generate_and_throw_MAPS_exception(errId);
end

%% CALCULATE QUARTERLY (ONE-PERIOD) GROWTH RATE
xGrowth = NaN*ones(nx,T);
xGrowth(:,2:T) = 100*(x(:,2:T)-x(:,1:T-1))./x(:,1:T-1);

end