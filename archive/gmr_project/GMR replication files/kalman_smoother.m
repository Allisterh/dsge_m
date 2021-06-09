function [xsmooth, Vsmooth, VVsmooth, loglik] = kalman_smoother_diag(y, A, C, Q, R, init_x, init_V, varargin)
% Kalman/RTS smoother.
% [xsmooth, Vsmooth, VVsmooth, loglik] = kalman_smoother(y, A, C, Q, R, init_x, init_V, ...)
%
% The inputs are the same as for kalman_filter.
% The outputs are almost the same, except we condition on y(:, 1:T) (and u(:, 1:T) if specified),
% instead of on y(:, 1:t).

[os T] = size(y);
ss = size(A,1);

% set default params
model = ones(1,T);
u = [];
B = [];

args = varargin;
nargs = length(args);
for i=1:2:nargs
    switch args{i}
        case 'model', model = args{i+1};
        case 'u', u = args{i+1};
        case 'B', B = args{i+1};
        otherwise, error(['unrecognized argument ' args{i}])
    end
end

xsmooth = zeros(ss, T);
Vsmooth = zeros(ss, ss, T);
VVsmooth = zeros(ss, ss, T);

% Forward pass
[xfilt, Vfilt, VVfilt, loglik] = kalman_filter_diag(y, A, C, Q, R, init_x, init_V, ...
    'model', model, 'u', u, 'B', B);

% Backward pass
xsmooth(:,T) = xfilt(:,T);
Vsmooth(:,:,T) = Vfilt(:,:,T);
%VVsmooth(:,:,T) = VVfilt(:,:,T);


for t=T-1:-1:1
    m = model(t+1);
    if isempty(B)
        [xsmooth(:,t), Vsmooth(:,:,t), VVsmooth(:,:,t+1)] = ...
            smooth_update(xsmooth(:,t+1), Vsmooth(:,:,t+1), xfilt(:,t), Vfilt(:,:,t), ...
            Vfilt(:,:,t+1), VVfilt(:,:,t+1), A(:,:,m), Q(:,:,m), [], []);
        
    else
        [xsmooth(:,t), Vsmooth(:,:,t), VVsmooth(:,:,t+1)] = ...
            smooth_update(xsmooth(:,t+1), Vsmooth(:,:,t+1), xfilt(:,t), Vfilt(:,:,t), ...
            Vfilt(:,:,t+1), VVfilt(:,:,t+1), A(:,:,m), Q(:,:,m), B(:,:,m), u(:,t+1));
    end
end

VVsmooth(:,:,1) = zeros(ss,ss);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, V, VV, loglik] = kalman_filter_diag(y, A, C, Q, R, init_x, init_V, varargin)
% Kalman filter.
% [x, V, VV, loglik] = kalman_filter(y, A, C, Q, R, init_x, init_V, ...)
%
% INPUTS:
% y(:,t)   - the observation at time t
% A - the system matrix
% C - the observation matrix 
% Q - the system covariance 
% R - the observation covariance
% init_x - the initial state (column) vector 
% init_V - the initial state covariance 
%
% OPTIONAL INPUTS (string/value pairs [default in brackets])
% 'model' - model(t)=m means use params from model m at time t [ones(1,T) ]
%     In this case, all the above matrices take an additional final dimension,
%     i.e., A(:,:,m), C(:,:,m), Q(:,:,m), R(:,:,m).
%     However, init_x and init_V are independent of model(1).
% 'u'     - u(:,t) the control signal at time t [ [] ]
% 'B'     - B(:,:,m) the input regression matrix for model m
%
% OUTPUTS (where X is the hidden state being estimated)
% x(:,t) = E[X(:,t) | y(:,1:t)]
% V(:,:,t) = Cov[X(:,t) | y(:,1:t)]
% VV(:,:,t) = Cov[X(:,t), X(:,t-1) | y(:,1:t)] t >= 2
% loglik = sum{t=1}^T log P(y(:,t))
%
% If an input signal is specified, we also condition on it:
% e.g., x(:,t) = E[X(:,t) | y(:,1:t), u(:, 1:t)]
% If a model sequence is specified, we also condition on it:
% e.g., x(:,t) = E[X(:,t) | y(:,1:t), u(:, 1:t), m(1:t)]

[os T] = size(y);
ss = size(A,1); % size of state space

% set default params
model = ones(1,T);
u = [];
B = [];
ndx = [];

args = varargin;
nargs = length(args);
for i=1:2:nargs
    switch args{i}
        case 'model', model = args{i+1};
        case 'u', u = args{i+1};
        case 'B', B = args{i+1};
        case 'ndx', ndx = args{i+1};
        otherwise, error(['unrecognized argument ' args{i}])
    end
end

x = zeros(ss, T);
V = zeros(ss, ss, T);
VV = zeros(ss, ss, T);

loglik = 0;
for t=1:T
   
    m = model(t);
    if t==1
        %prevx = init_x(:,m);
        %prevV = init_V(:,:,m);
        prevx = init_x;
        prevV = init_V;
        initial = 1;
    else
        prevx = x(:,t-1);
        prevV = V(:,:,t-1);
        initial = 0;
    end
    if isempty(u)
        [x(:,t), V(:,:,t), LL, VV(:,:,t)] = ...
            kalman_update_diag(A(:,:,m), C(:,:,m), Q(:,:,m), R(:,:,m), y(:,t), prevx, prevV, 'initial', initial);
    else
        if isempty(ndx)
            [x(:,t), V(:,:,t), LL, VV(:,:,t)] = ...
                kalman_update_diag(A(:,:,m), C(:,:,m), Q(:,:,m), R(:,:,m), y(:,t), prevx, prevV, ... 
                'initial', initial, 'u', u(:,t), 'B', B(:,:,m));
        else
            i = ndx{t};
            % copy over all elements; only some will get updated
            x(:,t) = prevx;
            prevP = inv(prevV);
            prevPsmall = prevP(i,i);
            prevVsmall = inv(prevPsmall);
            [x(i,t), smallV, LL, VV(i,i,t)] = ...
                kalman_update_diag(A(i,i,m), C(:,i,m), Q(i,i,m), R(:,:,m), y(:,t), prevx(i), prevVsmall, ...
                'initial', initial, 'u', u(:,t), 'B', B(i,:,m));
            smallP = inv(smallV);
            prevP(i,i) = smallP;
            V(:,:,t) = inv(prevP);
        end    
    end
    loglik = loglik + LL;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xnew, Vnew, loglik, VVnew] = kalman_update_diag(A, C, Q, R, y, x, V, varargin)
% KALMAN_UPDATE Do a one step update of the Kalman filter
% [xnew, Vnew, loglik] = kalman_update(A, C, Q, R, y, x, V, ...)
%
% INPUTS:
% A - the system matrix
% C - the observation matrix 
% Q - the system covariance 
% R - the observation covariance
% y(:)   - the observation at time t
% x(:) - E[X | y(:, 1:t-1)] prior mean
% V(:,:) - Cov[X | y(:, 1:t-1)] prior covariance
%
% OPTIONAL INPUTS (string/value pairs [default in brackets])
% 'initial' - 1 means x and V are taken as initial conditions (so A and Q are ignored) [0]
% 'u'     - u(:) the control signal at time t [ [] ]
% 'B'     - the input regression matrix
%
% OUTPUTS (where X is the hidden state being estimated)
%  xnew(:) =   E[ X | y(:, 1:t) ] 
%  Vnew(:,:) = Var[ X(t) | y(:, 1:t) ]
%  VVnew(:,:) = Cov[ X(t), X(t-1) | y(:, 1:t) ]
%  loglik = log P(y(:,t) | y(:,1:t-1)) log-likelihood of innovatio

% set default params
u = [];
B = [];
initial = 0;

args = varargin;
for i=1:2:length(args)
    switch args{i}
        case 'u', u = args{i+1};
        case 'B', B = args{i+1};
        case 'initial', initial = args{i+1};
        otherwise, error(['unrecognized argument ' args{i}])
    end
end

%  xpred(:) = E[X_t+1 | y(:, 1:t)]
%  Vpred(:,:) = Cov[X_t+1 | y(:, 1:t)]

if initial
    if isempty(u)
        xpred = x;
    else
        xpred = x + B*u;
    end
    Vpred = V;
    
else
    if isempty(u)
        
        xpred = A*x;
        
    else
        xpred = A*x + B*u;
    end
    
    Vpred = A*V*A' + Q;
end
% size(y)
% size(C)
% size(xpred)
% pause
e = y - C*xpred; % error (innovation)
n = length(e);
ss = length(A);

d = size(e,1);

% size(C)
% size(Vpred)
% size(C*Vpred*C')
% size(R)
S = C*Vpred*C' + R;
GG = C'*diag(1./diag(R))*C;
Sinv = diag(1./diag(R)) - diag(1./diag(R))*C*inv(eye(ss)+Vpred*GG)*Vpred*C'*diag(1./diag(R));
detS = prod(diag(R))*det(eye(ss)+Vpred*GG);

%%%%%%%%%%%%%%%%%%%%%%

denom = (2*pi)^(d/2)*sqrt(abs(detS));
mahal = sum(e'*Sinv*e,2);
loglik = -0.5*mahal - log(denom);

%%%%%%%%%%%%%%%%%%%%%%%



K = Vpred*C'*Sinv; % Kalman gain matrix

% If there is no observation vector, set K = zeros(ss).
xnew = xpred + K*e;              %csi_est(t\t) formula 13.6. 5    
Vnew = (eye(ss) - K*C)*Vpred;    %P(t\t) formula 13.2.16 hamilton
VVnew = (eye(ss) - K*C)*A*V;

% xnew, pause
% Vnew, pause



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xsmooth, Vsmooth, VVsmooth_future] = smooth_update(xsmooth_future, Vsmooth_future, ...
    xfilt, Vfilt,  Vfilt_future, VVfilt_future, A, Q, B, u)
% One step of the backwards RTS smoothing equations.
% function [xsmooth, Vsmooth, VVsmooth_future] = smooth_update(xsmooth_future, Vsmooth_future, ...
%    xfilt, Vfilt,  Vfilt_future, VVfilt_future, A, B, u)
%
% INPUTS:
% xsmooth_future = E[X_t+1|T]
% Vsmooth_future = Cov[X_t+1|T]
% xfilt = E[X_t|t]
% Vfilt = Cov[X_t|t]
% Vfilt_future = Cov[X_t+1|t+1]
% VVfilt_future = Cov[X_t+1,X_t|t+1]
% A = system matrix for time t+1
% Q = system covariance for time t+1
% B = input matrix for time t+1 (or [] if none)
% u = input vector for time t+1 (or [] if none)
%
% OUTPUTS:
% xsmooth = E[X_t|T]
% Vsmooth = Cov[X_t|T]
% VVsmooth_future = Cov[X_t+1,X_t|T]

%xpred = E[X(t+1) | t]
if isempty(B)
    xpred = A*xfilt;
else
    xpred = A*xfilt + B*u;
end

Vpred = A*Vfilt*A' + Q; % Vpred = Cov[X(t+1) | t]
% Vfilt, pause
J = Vfilt * A' * pinv(Vpred); % smoother gain matrix
xsmooth = xfilt + J*(xsmooth_future - xpred);
Vsmooth = Vfilt + J*(Vsmooth_future - Vpred)*J';
VVsmooth_future = VVfilt_future + (Vsmooth_future - Vfilt_future)*pinv(Vfilt_future)*VVfilt_future;
