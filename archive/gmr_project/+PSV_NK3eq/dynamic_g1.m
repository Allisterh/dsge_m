function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
% function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double   vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double   vector of endogenous variables in the order stored
%                                                     in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double   matrix of exogenous variables (in declaration order)
%                                                     for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double   vector of steady state values
%   params        [M_.param_nbr by 1]        double   vector of parameter values in declaration order
%   it_           scalar                     double   time period for exogenous variables for which
%                                                     to evaluate the model
%   T_flag        boolean                    boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   g1
%

if T_flag
    T = PSV_NK3eq.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(6, 15);
g1(1,5)=1;
g1(1,11)=(-1);
g1(1,12)=(-(1/params(2)));
g1(1,7)=1/params(2);
g1(1,8)=(-1);
g1(2,5)=(-((1-params(8))*(1-params(1)*params(8))/params(8)*(params(2)+params(3))));
g1(2,6)=1;
g1(2,12)=(-params(1));
g1(2,9)=(-1);
g1(3,5)=(-((1-params(5))*params(7)));
g1(3,6)=(-((1-params(5))*params(6)));
g1(3,1)=(-params(5));
g1(3,7)=1;
g1(3,10)=(-1);
g1(4,2)=(-params(9));
g1(4,8)=1;
g1(4,13)=(-1);
g1(5,3)=(-params(10));
g1(5,9)=1;
g1(5,14)=(-1);
g1(6,4)=(-params(11));
g1(6,10)=1;
g1(6,15)=(-1);

end
