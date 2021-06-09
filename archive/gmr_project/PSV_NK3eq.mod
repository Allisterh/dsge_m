% The analytics of the New Keynesian 3-equation Model (2015)
% code by Gauthier Vermandel

%----------------------------------------------------------------
% 0. Housekeeping (close all graphic windows)
%----------------------------------------------------------------

close all;

%----------------------------------------------------------------
% 1. Defining variables
%----------------------------------------------------------------

var y pi r s_D s_S s_r;

varexo e_D e_S e_R;

parameters beta sigma phi chi rho phi_pi phi_y theta rho_D rho_S rho_R;

%----------------------------------------------------------------
% 2. Calibration
%----------------------------------------------------------------

beta    	= 0.99;				% discount factor
sigma		= 1;				% risk aversion consumption
phi			= 1;				% labor disutility
theta		= 3/4;				% new keynesian Philips Curve, forward term
epsilon		= 6;				% subsituability/mark-up on prices
rho			= 0;				% MPR Smoothing
phi_pi		= 1.5;				% MPR Inflation
phi_y		= 0.5/4;			% MPR GDP

% shock processes
rho_D   = 0.9;
rho_S   = 0.9;
rho_R 	= 0.4;

% steady states
R		= 1/beta;
H		= 1/3;
MC		= (epsilon-1)/epsilon;
W		= MC;
Y		= H;
chi		= W*Y^-sigma*H^-phi;

%----------------------------------------------------------------
% 3. Model
%----------------------------------------------------------------

model(linear); 
	% IS curve
	y = y(+1) - 1/sigma*(r-pi(+1)) + s_D;
	% AS curve
	pi = beta*pi(+1) + ((1-theta)*(1-beta*theta)/theta)*(sigma+phi)*y + s_S;
	% Monetary Policy Rule
	r = rho*r(-1) + (1-rho)*( phi_pi*pi + phi_y*y ) + s_r;
	
	% shocks
	s_D = rho_D*s_D(-1) + e_D;
	s_S = rho_S*s_S(-1) + e_S;
	s_r = rho_R*s_r(-1) + e_R;
end;
