function xGrowth = ytypct(x)
% Function calculates the annual percentage change along the rows of matrix
% Takes an n x t matrix and calculates the annual growth rate.
%
% INPUTS:
%   -> x: real two dimensional numeric matrix with series along the rows,
%   and time along the columns
%
% OUTPUTS:
%   -> xGrowth: two dimensional matrix with annual growth rates of series 
%   along the rows and time along the columns. 
%
% NOTES:
%   -> Calculates annual growth rates on a two dimensional matrix, with the
%   series along the rows, and time along the columns. The output has the
%   same dimensions as the input, but with NaNs in the first 4 columns.
%   -> Only works with quarterly data.
%
% This version: 6th June 2013
% Author(s): Richard Harrison, Kate Reinold & Matt Waldron

%% CHECK INPUTS
if nargin<1
    errId = ['MAPS:',mfilename,':BadNargin'];
    generate_and_throw_MAPS_exception(errId,{num2str(nargin)});
elseif ~is_real_two_dimensional_numeric_matrix(x);
    errId = ['MAPS:',mfilename,':BadInput1'];
    generate_and_throw_MAPS_exception(errId);
end

%% ADDITIONAL TESTS FOR SUITABILITY OF MATRIX
% Function cannot work if the series contain any zeros, or if there are
% fewer than 5 periods of data.
zTest = find(x==0, 1);
[nRows,nCols] = size(x);
if ~isempty(zTest)
    errId = ['MAPS:',mfilename,':ContainsZeros'];
    generate_and_throw_MAPS_exception(errId);
elseif nCols<5
    errId = ['MAPS:',mfilename,':TooShort'];
    generate_and_throw_MAPS_exception(errId, {num2str(nCols)});
end

%% CALCULATE ANNUAL GROWTH RATE
xGrowth = [NaN(nRows,4) 100*(x(:,5:end)-x(:,1:end-4))./x(:,1:end-4)];
end

