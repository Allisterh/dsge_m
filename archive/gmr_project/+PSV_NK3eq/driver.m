%
% Status : main Dynare file
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

if isoctave || matlab_ver_less_than('8.6')
    clear all
else
    clearvars -global
    clear_persistent_variables(fileparts(which('dynare')), false)
end
tic0 = tic;
% Define global variables.
global M_ options_ oo_ estim_params_ bayestopt_ dataset_ dataset_info estimation_info ys0_ ex0_
options_ = [];
M_.fname = 'PSV_NK3eq';
M_.dynare_version = '4.6.1';
oo_.dynare_version = '4.6.1';
options_.dynare_version = '4.6.1';
%
% Some global variables initialization
%
global_initialization;
diary off;
diary('PSV_NK3eq.log');
M_.exo_names = cell(3,1);
M_.exo_names_tex = cell(3,1);
M_.exo_names_long = cell(3,1);
M_.exo_names(1) = {'e_D'};
M_.exo_names_tex(1) = {'e\_D'};
M_.exo_names_long(1) = {'e_D'};
M_.exo_names(2) = {'e_S'};
M_.exo_names_tex(2) = {'e\_S'};
M_.exo_names_long(2) = {'e_S'};
M_.exo_names(3) = {'e_R'};
M_.exo_names_tex(3) = {'e\_R'};
M_.exo_names_long(3) = {'e_R'};
M_.endo_names = cell(6,1);
M_.endo_names_tex = cell(6,1);
M_.endo_names_long = cell(6,1);
M_.endo_names(1) = {'y'};
M_.endo_names_tex(1) = {'y'};
M_.endo_names_long(1) = {'y'};
M_.endo_names(2) = {'pi'};
M_.endo_names_tex(2) = {'pi'};
M_.endo_names_long(2) = {'pi'};
M_.endo_names(3) = {'r'};
M_.endo_names_tex(3) = {'r'};
M_.endo_names_long(3) = {'r'};
M_.endo_names(4) = {'s_D'};
M_.endo_names_tex(4) = {'s\_D'};
M_.endo_names_long(4) = {'s_D'};
M_.endo_names(5) = {'s_S'};
M_.endo_names_tex(5) = {'s\_S'};
M_.endo_names_long(5) = {'s_S'};
M_.endo_names(6) = {'s_r'};
M_.endo_names_tex(6) = {'s\_r'};
M_.endo_names_long(6) = {'s_r'};
M_.endo_partitions = struct();
M_.param_names = cell(11,1);
M_.param_names_tex = cell(11,1);
M_.param_names_long = cell(11,1);
M_.param_names(1) = {'beta'};
M_.param_names_tex(1) = {'beta'};
M_.param_names_long(1) = {'beta'};
M_.param_names(2) = {'sigma'};
M_.param_names_tex(2) = {'sigma'};
M_.param_names_long(2) = {'sigma'};
M_.param_names(3) = {'phi'};
M_.param_names_tex(3) = {'phi'};
M_.param_names_long(3) = {'phi'};
M_.param_names(4) = {'chi'};
M_.param_names_tex(4) = {'chi'};
M_.param_names_long(4) = {'chi'};
M_.param_names(5) = {'rho'};
M_.param_names_tex(5) = {'rho'};
M_.param_names_long(5) = {'rho'};
M_.param_names(6) = {'phi_pi'};
M_.param_names_tex(6) = {'phi\_pi'};
M_.param_names_long(6) = {'phi_pi'};
M_.param_names(7) = {'phi_y'};
M_.param_names_tex(7) = {'phi\_y'};
M_.param_names_long(7) = {'phi_y'};
M_.param_names(8) = {'theta'};
M_.param_names_tex(8) = {'theta'};
M_.param_names_long(8) = {'theta'};
M_.param_names(9) = {'rho_D'};
M_.param_names_tex(9) = {'rho\_D'};
M_.param_names_long(9) = {'rho_D'};
M_.param_names(10) = {'rho_S'};
M_.param_names_tex(10) = {'rho\_S'};
M_.param_names_long(10) = {'rho_S'};
M_.param_names(11) = {'rho_R'};
M_.param_names_tex(11) = {'rho\_R'};
M_.param_names_long(11) = {'rho_R'};
M_.param_partitions = struct();
M_.exo_det_nbr = 0;
M_.exo_nbr = 3;
M_.endo_nbr = 6;
M_.param_nbr = 11;
M_.orig_endo_nbr = 6;
M_.aux_vars = [];
M_.Sigma_e = zeros(3, 3);
M_.Correlation_matrix = eye(3, 3);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = true;
M_.det_shocks = [];
options_.linear = true;
options_.block = false;
options_.bytecode = false;
options_.use_dll = false;
options_.linear_decomposition = false;
M_.nonzero_hessian_eqs = [];
M_.hessian_eq_zero = isempty(M_.nonzero_hessian_eqs);
M_.orig_eq_nbr = 6;
M_.eq_nbr = 6;
M_.ramsey_eq_nbr = 0;
M_.set_auxiliary_variables = exist(['./+' M_.fname '/set_auxiliary_variables.m'], 'file') == 2;
M_.epilogue_names = {};
M_.epilogue_var_list_ = {};
M_.orig_maximum_endo_lag = 1;
M_.orig_maximum_endo_lead = 1;
M_.orig_maximum_exo_lag = 0;
M_.orig_maximum_exo_lead = 0;
M_.orig_maximum_exo_det_lag = 0;
M_.orig_maximum_exo_det_lead = 0;
M_.orig_maximum_lag = 1;
M_.orig_maximum_lead = 1;
M_.orig_maximum_lag_with_diffs_expanded = 1;
M_.lead_lag_incidence = [
 0 5 11;
 0 6 12;
 1 7 0;
 2 8 0;
 3 9 0;
 4 10 0;]';
M_.nstatic = 0;
M_.nfwrd   = 2;
M_.npred   = 4;
M_.nboth   = 0;
M_.nsfwrd   = 2;
M_.nspred   = 4;
M_.ndynamic   = 6;
M_.dynamic_tmp_nbr = [0; 0; 0; 0; ];
M_.equations_tags = {
  1 , 'name' , 'y' ;
  2 , 'name' , 'pi' ;
  3 , 'name' , 'r' ;
  4 , 'name' , 's_D' ;
  5 , 'name' , 's_S' ;
  6 , 'name' , 's_r' ;
};
M_.mapping.y.eqidx = [1 2 3 ];
M_.mapping.pi.eqidx = [1 2 3 ];
M_.mapping.r.eqidx = [1 3 ];
M_.mapping.s_D.eqidx = [1 4 ];
M_.mapping.s_S.eqidx = [2 5 ];
M_.mapping.s_r.eqidx = [3 6 ];
M_.mapping.e_D.eqidx = [4 ];
M_.mapping.e_S.eqidx = [5 ];
M_.mapping.e_R.eqidx = [6 ];
M_.static_and_dynamic_models_differ = false;
M_.has_external_function = false;
M_.state_var = [3 4 5 6 ];
M_.exo_names_orig_ord = [1:3];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(6, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(3, 1);
M_.params = NaN(11, 1);
M_.endo_trends = struct('deflator', cell(6, 1), 'log_deflator', cell(6, 1), 'growth_factor', cell(6, 1), 'log_growth_factor', cell(6, 1));
M_.NNZDerivatives = [23; 0; -1; ];
M_.static_tmp_nbr = [0; 0; 0; 0; ];
close all;
M_.params(1) = 0.99;
beta = M_.params(1);
M_.params(2) = 1;
sigma = M_.params(2);
M_.params(3) = 1;
phi = M_.params(3);
M_.params(8) = 0.75;
theta = M_.params(8);
epsilon		= 6;				
M_.params(5) = 0;
rho = M_.params(5);
M_.params(6) = 1.5;
phi_pi = M_.params(6);
M_.params(7) = 0.125;
phi_y = M_.params(7);
M_.params(9) = 0.9;
rho_D = M_.params(9);
M_.params(10) = 0.9;
rho_S = M_.params(10);
M_.params(11) = 0.4;
rho_R = M_.params(11);
R		= 1/beta;
H		= 1/3;
MC		= (epsilon-1)/epsilon;
W		= MC;
Y		= H;
M_.params(4) = W*Y^(-M_.params(2))*H^(-M_.params(3));
chi = M_.params(4);
save('PSV_NK3eq_results.mat', 'oo_', 'M_', 'options_');
if exist('estim_params_', 'var') == 1
  save('PSV_NK3eq_results.mat', 'estim_params_', '-append');
end
if exist('bayestopt_', 'var') == 1
  save('PSV_NK3eq_results.mat', 'bayestopt_', '-append');
end
if exist('dataset_', 'var') == 1
  save('PSV_NK3eq_results.mat', 'dataset_', '-append');
end
if exist('estimation_info', 'var') == 1
  save('PSV_NK3eq_results.mat', 'estimation_info', '-append');
end
if exist('dataset_info', 'var') == 1
  save('PSV_NK3eq_results.mat', 'dataset_info', '-append');
end
if exist('oo_recursive_', 'var') == 1
  save('PSV_NK3eq_results.mat', 'oo_recursive_', '-append');
end


disp(['Total computing time : ' dynsec2hms(toc(tic0)) ]);
if ~isempty(lastwarn)
  disp('Note: warning(s) encountered in MATLAB/Octave code')
end
diary off
