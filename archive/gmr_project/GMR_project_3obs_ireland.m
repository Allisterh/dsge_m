%% Clear workspace
clc
clear all

%% Load auxilliary data
sheetName = 'panel';
load_model_and_aux_data_3obs_ireland

%% Load an NK model estimated in Dynare
load ireland_results
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
% g z y r a e x pi
A = [oo_.dr.ghx zeros(8, 4)];
B = oo_.dr.ghu;

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
A_q = [A zeros(6, 1);
       0 0 0 0 1 0 0];
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
C_q(2,7) = -1;
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
A_m = [A_sm zeros(6, 1) zeros(6, 1) zeros(6, 1);
       0 0 0 0 1 0 0 0 0;
       0 0 0 0 0 0 1 0 0;
       0 0 0 0 0 0 0 1 0];

BminMonthly = (A_sm^2+A_sm+eye(size(A_sm)))\(B);

%B_m = BminMonthly;
B_m = [BminMonthly; zeros(3, 3)];   

%B_m = [B_mm; zeros(1, size(B_mm, 2)); zeros(1, size(B_mm, 2)); zeros(1, size(B_mm, 2))];
Q_m  = B_m * B_m'; % covariance matrix of shocks

%C_m = zeros(3, size(A_m, 2)); % define the selection matrix for the observation equation
%C_m(1,1) = 1;
%C_m(2,5) = 1;
%C_m(3,6) = 1;

C_m = zeros(3, size(A_m, 2)); % define the selection matrix for the observation equation
C_m(1,1) = 1;
C_m(2,5) = 1;
C_m(2,9) = -1;
C_m(3,6) = 1;

% END OF MODEL-SPECIFIC SECTION

%% Initialize forecasting block
start_y = 2011; start_m = 3; %% Starting dates for the out-of-sample evaluation
end_y   = 2020;   end_m = 12; %% Ending dates for the out-of-sample evaluation
start_sample = find((time(:,1)==start_y) & (time(:,2)==start_m));
end_sample = find((time(:,1)==end_y) & (time(:,2)==end_m));
%start_sampleSPF = find((URSPF(:,1)==start_y)&(URSPF(:,2)==start_m/3));
%end_sampleSPF = find((URSPF(:,1)==end_y)&(URSPF(:,2)==end_m/3));

forecastEvalWindow = (end_sample-start_sample+3)/3;
%nForecasts = 7;
nForecasts = 4;
    
    NOWGDP = zeros(forecastEvalWindow,nForecasts);
    FOR1GDP = zeros(forecastEvalWindow-3,nForecasts);
    FOR2GDP = zeros(forecastEvalWindow-6,nForecasts);
    FOR3GDP = zeros(forecastEvalWindow-9,nForecasts);
    FOR4GDP = zeros(forecastEvalWindow-12,nForecasts);
    %NOWUR = zeros(forecastEvalWindow,nForecasts); 
    %NOWPI =zeros(forecastEvalWindow,nForecasts);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ESTIMATION AND FORECASTING PROCEDURE
% we will produce forecasts with 3 different datasets:
% - only observables, quarterly series (the model's forecast)
% - only observables, monthly series
% - observables+auxiliaries, monthly series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %iPanel = 38; 
   %unb_M = logical(UnbPattern(:,:,iPanel));
    count=0;
    initxq = zeros(1,size(A_q,2))';
    initVq = eye(size(A_q,2))*10;
    
    initxm = zeros(1,size(A_m, 2))';
    initVm = eye(size(A_m, 2))*10;
    
    %t=start_sample;
    for t=start_sample:3:end_sample
        X = Xfin;
        [~,N]=size(X);
        
        x = X(1:t+3,:);
        x(t+3,2) = NaN;
        count=count+1;
        
        %% Handle outliers and unbalancedness
        clear xc
        for j = 1:N
            xc(:,j) = outliers_correction(x(:,j),5);
            if xc(:,j)~=x(:,j)
                keyboard
            end
        end;
        xc(isnan(x))=NaN;
        x = xc;
        tempx = x(end-5:end,:);
        %tempx(unb_M)=NaN;
        x(end-5:end,:) = tempx;
        
        % Add rows depending on the forecast horizon
        Xcurr=[x; NaN*ones(12,N)];
        
        % Separate the data between the observables of the model and the auxiliary data
        % and create quarterly series  for the estimation of the
        % coefficients that related the auxiliary variables to the
        % observables variables.
        Xm = Xcurr(:,nY+1:end);
        Ym = Xcurr(:,1:nY);
        Xq = Xcurr(3:3:end,nY+1:end);
        Yq = Xcurr(3:3:end,1:nY);
        
        % standardize quarterly data
        m = max(sum(isnan([Yq Xq])));
        yq = Yq(1:end-m,:); xq = Xq(1:end-m,:);
        My = mean(yq); Sy = std(yq); %ones(1,nY); %std(yq);
        Mx = mean(xq); Sx = std(xq);
        yq_std = (yq-ones(size(yq(:,1)))*My)*diag(1./Sy);
        xq_std = (xq-ones(size(xq(:,1)))*Mx)*diag(1./Sx);
        
        
        if t == start_sample
            %% estimate the coefficients relating the auxiliaries with the observables
            Gamma = ((yq_std'*yq_std)\yq_std'*xq_std)';
            R = diag(xq_std'*xq_std-xq_std'*yq_std*Gamma')/size(xq_std,1);
        end
        
        % standardize monthly data
        T = size(Xm,1);
        Xm_std = (Xm-ones(T,1)*Mx)./(ones(T,1)*Sx);
        Ym_std = (Ym-ones(T,1)*My)./(ones(T,1)*Sy);
        
        %the data
        Z = [Ym_std Xm_std];    %observables+auxiliaries, monthly frequency
        Z_np = Z(:,1:nY);         %only observables, monthly frequency
        Zq = Z(3:3:end,:);        %observables+auxiliaries, quarterly frequency
        Zq_np =Z(3:3:end,1:nY);   %only observables, quarterly frequency
        Tq = size(Zq_np,1);
        
        % condition quarterly model on existing monthly variables where possible
        %ConsRT = diag(Ym_std(end - sum(isnan(Ym_std(:,2))),2))';
        Zq_cond =Zq_np;
        %if iPanel>18, % If SPF released condition on those as well
        %    CondSPF = [GDPSPF(start_sampleSPF+count-1,3)/4-POPDATA(t/3-1)-D(1),...
        %        CSPF(start_sampleSPF+count-1,3)/4-POPDATA(t/3-1)+PGDPSPF(start_sampleSPF+count-1,3)/4-D(1),...
        %        PGDPSPF(start_sampleSPF+count-1,3)/4-D(5),...
        %        URSPF(start_sampleSPF+count-1,4)-D(7)];
        %    Zq_cond(end-4,[1:2 5 7])=CondSPF;
        %end
        Zq(:,1:nY) = Zq_cond;
         
        % Coefficients for the models that deal with quarterly data
        Cq=[C_q;Gamma*C_q];
        Rq=[1e-4*ones(nY,1);R];
        %Rq(4)=sigmaME^2;
        %if ~isempty(sigmaSPME),
        %    Rq(9)=(sigmaSPME^2);
        %end
        
        for jt = 1:Tq
            CCq(:,:,jt) = Cq;
            CCq_np(:,:,jt) = C_q;
            AAq(:,:,jt) = A_q;
            QQq(:,:,jt) = Q_q;
            Rtemp = Rq;
            Rtemp(isnan(Zq_np(jt,:))) = 1e+32;     %infinite variance -> zero weight on the missing datapoints
            RRq(:,:,jt) = diag(Rtemp);
            RRq_np(:,:,jt) = diag(Rtemp(1:nY));
            RRq_npb(:,:,jt) = RRq_np(:,:,jt);
            if find(RRq_np(1:nY,1:nY,jt)>=1e+30),
                RRq_npb(:,:,jt)=1e+32*eye(nY);    %infinite variance -> zero weight on the missing datapoints
            end
        end;
        Zq(isnan(Zq))=0;
        Zq_np(isnan(Zq_np))=0;
        Zq_cond(isnan(Zq_cond))=0;
        Tq = size(Zq_np(:,1),1);
        
        % Coefficients for the models that deal with monthly data
        % the cube root B31 if define above where I check existence and unicity
        T = size(Z,1);
        
        Cm = [C_m;Gamma*C_m];
        Rm = [1e-4*ones(nY,1);R];
        %Rm(4)=(sigmaME^2);
        %if ~isempty(sigmaSPME),
        %    Rm(9)=(sigmaSPME^2);
        %end
        
        for jt = 1:T
            CCm(:,:,jt) = Cm;
            CCm_np(:,:,jt) = C_m;
            AAm(:,:,jt) = A_m;
            QQm(:,:,jt) = Q_m;
            Rtemp = Rm; Rtemp(isnan(Z(jt,:)))=1e+32; %infinite variance -> zero weight on the missing datapoints
            RRm(:,:,jt) = diag(Rtemp);
            RRm_np(:,:,jt)=diag(Rtemp(1:nY));
        end;
        
        Z(isnan(Z))=0;
        Z_np(isnan(Z_np))=0;
        Mz = [My Mx]; Sz = [Sy Sx];
        
        % Forecasts - Kalman filters
        [xsmoothm, Vsmoothm, VVsmoothm, ~] = kalman_smoother(Z', AAm, CCm, QQm, RRm, initxm, initVm,'model', (1:T));
        %[xsmoothm_np, Vsmoothm_np, VVsmoothm_np, ~] = kalman_smoother(Z_np', AAm, CCm_np, QQm, RRm_np, initxm, initVm,'model', (1:T));
        %[xsmoothq_np, Vsmoothq_np, VVsmoothq_np, ~] = kalman_smoother(Zq_cond', AAq, CCq_np, QQq, RRq_np, initxq, initVq,'model', (1:Tq));
        [xsmoothq_npb, Vsmoothq_npb, VVsmoothq_npb, ~] = kalman_smoother(Zq_np', AAq, CCq_np, QQq, RRq_npb, initxq, initVq,'model', (1:Tq));
        
        %de-standardise the data and forecasts
        chim = xsmoothm'*CCm(:,:,1)'*diag(Sz)+ones(T,1)*Mz;
        %chim = xsmoothm'*CCm(:,:,1)';
        %chim_np = xsmoothm_np'*CCm_np(:,:,1)'*diag(Sy)+ones(T,1)*My;
        %chiq_np = xsmoothq_np'*CCq_np(:,:,1)'*diag(Sy)+ones(Tq,1)*My;
        chiq_npb = xsmoothq_npb'*CCq_np(:,:,1)'*diag(Sy)+ones(Tq,1)*My;
        %chiq_npb = xsmoothq_npb'*CCq_np(:,:,1)';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % monthly + panel
        GDP_m = chim(3:3:end,2);
        %UR_m = chim(3:3:end,7);
        %PI_m = chim(3:3:end,3);
       
        % quarterly no panel
        %GDP_qnp = chiq_np(1:end,1);
        %UR_qnp = chiq_np(1:end,7);
        %PI_qnp = chiq_np(1:end,5);
       
        % quarterly no panel b
        GDP_qnpb = chiq_npb(1:end,2);
        %UR_qnpb = chiq_npb(1:end,7);
        %PI_qnpb = chiq_npb(1:end,3);
        
        % monthly no panel
        %GDP_mnp = chim_np(3:3:end,2);
        %UR_mnp = chim_np(3:3:end,7);
        %PI_mnp = chim_np(3:3:end,3);
       
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %the nowcast
        %NOWGDP(t/3,:) = [dates(t) X(t,1) GDPSPF(start_sampleSPF+count-1,3)/4-POPDATA(t/3-1) GDP_qnpb(end-4,1)' GDP_qnp(end-4,1)' GDP_mnp(end-4,1)' GDP_m(end-4,1)'  ] ;
        %NOWGDP(t/3,:) = [dates(t) X(t,1) GDP_qnpb(end-4,1)' GDP_m(end-4,1)'] ;
        %NOWGDP(t/3,:) = [dates(t) (X(t+3,2)-My(2))/Sy(2) GDP_qnpb(end-4,1)' GDP_m(end-4,1)'] ;
        NOWGDP(t/3,:) = [dates(t) X(t+3,2) GDP_qnpb(end-4,1)' GDP_m(end-4,1)'] ;
        %NOWUR(t/3,:) = [dates(t) X(t,7) URSPF(start_sampleSPF+count-1,4) UR_qnpb(end-4,1)' UR_qnp(end-4,1)'   UR_mnp(end-4,1)' UR_m(end-4,1)' ] ;
        %NOWPI(t/3,:) = [dates(t) sum(X(t-9:3:t,5)) sum(X(t-9:3:t-2,5))+PGDPSPF(start_sampleSPF+count-1,3)/4 sum(X(t-9:3:t-2,5))+PI_qnpb(end-4,1) sum(X(t-9:3:t-2,5))+PI_qnp(end-4,1) sum(X(t-9:3:t-2,5))+PI_mnp(end-4,1) sum(X(t-9:3:t-2,5))+PI_m(end-4,1)  ];
        %NOWPI(t/3,:) = [dates(t) sum(X(t-9:3:t,5)) sum(X(t-9:3:t-2,5))+PGDPSPF(start_sampleSPF+count-1,3)/4 sum(X(t-9:3:t-2,5))+PI_qnpb(end-4,1) sum(X(t-9:3:t-2,5))+PI_qnp(end-4,1) sum(X(t-9:3:t-2,5))+PI_mnp(end-4,1) sum(X(t-9:3:t-2,5))+PI_m(end-4,1)  ];
        if t<=end_sample-2
                %FOR1GDP(t/3,:) = [dates(t+3) X(t+3,1) GDPSPF(start_sampleSPF+count-1,4)/4-POPDATA(t/3-1) GDP_qnpb(end-3,1)' GDP_qnp(end-3,1)'  GDP_mnp(end-3,1)' GDP_m(end-3,1)'  ] ;
                FOR1GDP(t/3,:) = [dates(t+3) X(t+6,2) GDP_qnpb(end-3,1)' GDP_m(end-3,1)'] ;
        end
        if t<=end_sample-5
                %FOR2GDP(t/3,:) = [dates(t+6) X(t+6,1) GDPSPF(start_sampleSPF+count-1,5)/4-POPDATA(t/3-1) GDP_qnpb(end-2,1)' GDP_qnp(end-2,1)'  GDP_mnp(end-2,1)' GDP_m(end-2,1)'  ];
                FOR2GDP(t/3,:) = [dates(t+6) X(t+9,2) GDP_qnpb(end-2,1)' GDP_m(end-2,1)'];
        end
        if t<=end_sample-8
                %FOR3GDP(t/3,:) =  [dates(t+9) X(t+9,1) GDPSPF(start_sampleSPF+count-1,6)/4-POPDATA(t/3-1) GDP_qnpb(end-1,1)' GDP_qnp(end-1,1)'  GDP_mnp(end-1,1)' GDP_m(end-1,1)' ];
                FOR3GDP(t/3,:) =  [dates(t+9) X(t+12,2) GDP_qnpb(end-1,1)' GDP_m(end-1,1)'];
        end
        if t<=end_sample-11
                 %FOR4GDP(t/3,:) = [dates(t+12) X(t+12,1) GDPSPF(start_sampleSPF+count-1,7)/4-POPDATA(t/3-1) GDP_qnpb(end,1)' GDP_qnp(end,1)'  GDP_mnp(end,1)' GDP_m(end,1)'  ];
                 FOR4GDP(t/3,:) = [dates(t+12) X(t+15,2) GDP_qnpb(end,1)' GDP_m(end,1)'];
        end
        
    end;
    
    %plot(NOWGDP(31:69,2:end),'DisplayName','NOWGDP(31:69,2:end)')
    
    MSFENOW=mean((NOWGDP(1:end-5,2)*ones(1,2)-NOWGDP(1:end-5,3:end)).^2);
    MSE_bench(:,:)=MSFENOW;
    disp('    MSFE of GDP NOWCASTS ')
    disp('    Qmodel   Mmodel+panel ')
    disp(MSE_bench(:,:))
    
    MSFENOW=mean((FOR1GDP(1:end-5,2)*ones(1,2)-FOR1GDP(1:end-5,3:end)).^2);
    MSE_bench(:,:)=MSFENOW;
    disp('    MSFE of GDP FORCASTS ON 1 QUARTERS AHEAD ')
    disp('    Qmodel   Mmodel+panel ')
    disp(MSE_bench(:,:))
    
    MSFENOW=mean((FOR2GDP(1:end-5,2)*ones(1,2)-FOR2GDP(1:end-5,3:end)).^2);
    MSE_bench(:,:)=MSFENOW;
    disp('    MSFE of GDP FORCASTS ON 2 QUARTERS AHEAD ')
    disp('    Qmodel   Mmodel+panel ')
    disp(MSE_bench(:,:))
    
    MSFENOW=mean((FOR3GDP(1:end-5,2)*ones(1,2)-FOR3GDP(1:end-5,3:end)).^2);
    MSE_bench(:,:)=MSFENOW;
    disp('    MSFE of GDP FORCASTS ON 3 QUARTERS AHEAD ')
    disp('    Qmodel   Mmodel+panel ')
    disp(MSE_bench(:,:))
    
    MSFENOW=mean((FOR4GDP(1:end-5,2)*ones(1,2)-FOR4GDP(1:end-5,3:end)).^2);
    MSE_bench(:,:)=MSFENOW;
    disp('    MSFE of GDP FORCASTS ON 4 QUARTERS AHEAD ')
    disp('    Qmodel   Mmodel+panel ')
    disp(MSE_bench(:,:))
    
    
    %disp('    MSFE of UR NOWCASTS ')
    %disp('      SPF     QmodelB   Qmodel+cond    Mmodel   Mmodel+panel ')
    %MSFENOWUR=mean((repmat(NOWUR(1:end,2),1,5)-NOWUR(1:end,3:end)).^2);
    %MSE_benchUR(:,:)=MSFENOWUR;
    %disp(MSE_benchUR)
    %disp('    MSFE of PI NOWCASTS ')
    %disp('      SPF     QmodelB   Qmodel+cond  Mmodel   Mmodel+panel ')
    %MSFENOWPI=mean((repmat(NOWPI(1:end,2),1,5)-NOWPI(1:end,3:end)).^2);
    %MSE_benchPI(:,:)=MSFENOWPI;
    %disp(MSE_benchPI)
    