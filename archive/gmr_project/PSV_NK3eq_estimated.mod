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
	r = rho*r(-1) + (1-rho) * (phi_pi * pi + phi_y * y) + s_r;
    % Growth definition
    %g = y - y(-1);


	% shocks
	s_D = rho_D*s_D(-1) + e_D;
	s_S = rho_S*s_S(-1) + e_S;
	s_r = rho_R*s_r(-1) + e_R;
end;

%----------------------------------------------------------------
% 4. Estimation
%----------------------------------------------------------------

varobs r y pi;

estimated_params;
    sigma, gamma_PDF,2,0.2 ;
    //beta, 0.99, 0.98, 1 ;
    theta, beta_PDF,0.75,0.03 ;
    phi, gamma_PDF,1,0.1 ;
    rho, beta_PDF,0.7,0.1 ;
    phi_pi, normal_PDF,2,0.2;
    phi_y, normal_PDF,0.05,0.01 ;
    rho_D, beta_PDF,0.2,0.1 ;
    rho_S, beta_PDF,0.2,0.1 ;
    rho_R, beta_PDF,0.7,0.1 ;
    stderr e_D, uniform_PDF,,,0,2 ;
    stderr e_S, uniform_PDF,,,0,2 ;
    stderr e_R, uniform_PDF,,,0,2 ;
end;

estimated_params_init;

sigma, 2 ;
theta, 0.75 ;
phi, 1 ;
rho, 0.7 ;
phi_pi, 2 ;
phi_y, 0.05 ;
rho_D, 0.2;
rho_S, 0.2;
rho_R, 0.7;

end;

estimation(datafile = 'data_detrended.xls', mode_compute = 5, presample = 0, prefilter=0, mh_replic = 0000, mh_nblocks = 1, mh_jscale = 0.2, mh_drop = 0.2, order = 1, plot_priors = 0, lik_init = 2, mode_check);

check ;

shock_decomposition(parameter_set = posterior_mode) r y pi ;
