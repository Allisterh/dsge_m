%% Clear workspace
clc
clear all

%% Load auxilliary data
sheetName = 'panel';
load_model_and_aux_data_3obs

%% Load an NK model estimated in Dynare
load PSV_NK3eq_estimated_results
%D = [-0.00768234; -0.005591027; 0.001943254]; % matrix of averages (need later)

%[result, eigenvalue_modulo, A, B, C, D] = ABCD_test(M_, options_, oo_)

%% Extract the number of static (st), forward-looking (fw), predetermined (pd) and both (pf) variables
%n_st = M_.nstatic;
%n_fw = M_.nfwrd;
%n_pd = M_.npred;
%n_pf = M_.nboth;

%% Derive matrices for monthly state space form
% Ordering: st pd pf fw
%A = oo_.dr.ghx;
%B = oo_.dr.ghu;

A = [oo_.dr.ghx zeros(6, 3);
    zeros(1,6) 1];
B = [oo_.dr.ghu zeros(6, 1);
    zeros(1,3) 1];

%A_yq = [oo_.dr.ghx(1:n_st,:); oo_.dr.ghx((end-n_fw+1):end,:)];
%B_yq = [oo_.dr.ghu(1:n_st,:); oo_.dr.ghu((end-n_fw+1):end,:)];

%A_sq = [oo_.dr.ghx((n_st+1):(n_st+n_pd),:); oo_.dr.ghx((n_st+n_pd+1):(n_st+n_pd+n_pf),:)];
%B_sq = [oo_.dr.ghu((n_st+1):(n_st+n_pd),:); oo_.dr.ghu((n_st+n_pd+1):(n_st+n_pd+n_pf),:)];

%% Check that the cube root exists and is unique
%[V, Deig] = eig(A_sq);
[V, Deig] = eig(A);

% check existence
% check that V is invertible
if size(V, 1) > rank(V),
    disp('--------------------------------------------------------')
    disp('V does not have full rank')
    disp(['Size(V) = ', num2str(size(V, 1)), ' but rank(V) = ', num2str(rank(V))])
    
    return
end
% check unicity
if ~all(real(diag(Deig)) >= 0),
    %                 disp('--------------------------------------------------------')
    %                 disp('These eigenvalues lie in the negative part of the real axis')
    %                 Deig(real(diag(Deig))<0,real(diag(Deig))<0)
    if Deig(real(diag(Deig)) < 0, real(diag(Deig)) < 0) > 1e-10
        return
    end
end
Deig(abs(Deig) < 1e-10) = 0;

% Cube root
%A_sm = V * Deig.^(1/3) / V;
A_sm = V * Deig.^(1/3) / V;

if any(imag(A_sm) > 1e-8)
    error('This cube root is not real!')
else
    A_sm = real(A_sm);
end
if norm(A - A_sm^3)> 1e-10
    disp('--------------------------------------------------------')
    disp('The cube root of this matrix might not exist ')
    disp(norm(A - A_sm^3))
end
if any(any(A_sm)) > 1e3 || any(any(isnan(A_sm)))
    disp('--------------------------------------------------------')
    disp('Possible problem inverting V. Coefficients of B31 are too big or NaN')
end

%% Define new quarterly state space
% A - transition matrix for the "minimal state space" - quarterly system
%A_q = [A zeros(size(A, 1), 1) zeros(size(A, 1), 1)];
%A_q = [A zeros(size(A, 1), 1) zeros(size(A, 1), 1) zeros(size(A, 1), 1);
       %0 0 0 0 1 0 0];
A_q = [A zeros(7, 1);
       0 0 0 0 1 0 0 0];
%A_q = A;

% Q_q - covariance of the shocks in the transition equation - quarterly system
%B_q = B;
B_q = [B; zeros(1, size(B, 2))];
Q_q = B_q * B_q';

%C_q = zeros(3, size(A_q, 2)); % define the selection matrix for the observation equation
%C_q(1,1) = 1;
%C_q(2,5) = 1;
%C_q(3,6) = 1;
C_q = zeros(3, size(A_q, 2)); % define the selection matrix for the observation equation
C_q(1,1) = 1;
C_q(2,5) = 1;
C_q(2,7) = 1;
C_q(2,8) = -1;
C_q(3,6) = 1;

%% Set up monthly state space form
%x = (B_sq * B_sq');
%A_m = [A_sm; A_yq * inv(A_sq) * A_sm];
%B_sm = inv(eye(size(kron(A_sm, A_sm), 2)) + kron(A_sm, A_sm) + kron(A_sm^2, A_sm^2)) * x(:);
%B_sm = inv(eye(size(A_sm, 2)) + A_sm + A_sm^2) * B_sq;
%B_m = [B_sm; B_yq + A_yq * inv(A_sq) * (B_sm - B_sq)];
%B_mm = B_m;
%A_mm = A_m;

%A_m = A_sm;
%A_m = [A_mm zeros(6, 1) zeros(6, 1) zeros(6, 1) zeros(6, 1) zeros(6, 1);
%       0 0 0 0 1 0 0 0 0;
%       0 0 0 0 0 0 1 0 0;
%       0 0 0 0 0 0 0 1 0];
A_m = [A_sm zeros(7, 1) zeros(7, 1) zeros(7, 1);
       0 0 0 0 1 0 0 0 0 0;
       0 0 0 0 0 0 0 1 0 0;
       0 0 0 0 0 0 0 0 1 0];

BminMonthly = (A_sm^2+A_sm+eye(size(A_sm)))\(B);

%B_m = BminMonthly;
B_m = [BminMonthly; zeros(3, 4)];   

%B_m = [B_mm; zeros(1, size(B_mm, 2)); zeros(1, size(B_mm, 2)); zeros(1, size(B_mm, 2))];
Q_m  = B_m * B_m'; % covariance matrix of shocks

%C_m = zeros(3, size(A_m, 2)); % define the selection matrix for the observation equation
%C_m(1,1) = 1;
%C_m(2,5) = 1;
%C_m(3,6) = 1;

C_m = zeros(3, size(A_m, 2)); % define the selection matrix for the observation equation
C_m(1,1) = 1;
C_m(2,5) = 1;
C_m(2,7) = 1;
C_m(2,10) = -1;
C_m(3,6) = 1;

% END OF MODEL-SPECIFIC SECTION
