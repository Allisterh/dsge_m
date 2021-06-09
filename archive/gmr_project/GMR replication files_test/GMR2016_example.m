%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% example file from "Incorporating Conjunctural Analysis in structural
% models",2016
% 
% by Domenico Giannone, Francesca Monti and Lucrezia Reichlin.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
addpath(genpath('ModelContentUtilities'))
addpath(genpath('ModelCreation'))
addpath(genpath('MiscUtilities'))
addpath(genpath('SymbolicMAPS'))
addpath(genpath('ExceptionHandling'))



%% AUXILIARY DATA
sheetName = 'panel';
load_model_and_aux_data
load('UnbPattern'); % In this example I used the information at the end of 
                    % the quarter, but unbPattern contains the ragged edge patterns 
                    % for the 38 information clusters we consider in the paper. 

%% LOAD MODEL 
load('EstimationOutput.mat');
M1 = UpdatedModel;


[B,PHI,G,D,xMnems,Ymnems,HB,HC,HF,theta,thetaMnems]=unpack_model(M1,{'B',...
    'PHI','G','D','xMnems','Ymnems','HB','HC','HF','theta','thetaMnems'});

nY = size(G,1);
sigmaME = theta(strcmp(thetaMnems,'sigmaME1'));
sigmaSPME = theta(strcmp(thetaMnems,'sigmaME3'));

%% DERIVE THE STATE SPACE REPRESENTATION WE WILL USE
% The transformation matrix equivalent to the indices is the rows of the
% transformation matrix that correspond to those indices.
% THIS PART OF THE CODE IS SPECIFIC TO THE MODEL YOU USE!

%
[HBsym,HCsym,HFsym,~,~,Gsym] = create_LSS_structural_symbolic_matrices(M1);
minStateLogicals = any(HBsym~=0);
minStateInds = find(minStateLogicals);
% Add u and the spread
minSInds = [minStateInds(1:8) 16  minStateInds(9:end) 47];


minStateInds = minSInds;
nx = size(HBsym,2);
nxeye = eye(nx);
minStateTransformMat = nxeye(minStateInds,:);
xMnemsMin = xMnems(minStateInds);

%% AND CHECK THAT THE CUBE ROOT EXISTS AND IS UNIQUE
Bmin = minStateTransformMat*B*minStateTransformMat';
[V,Deig]=eig(Bmin);

% check existence
% check that V is invertible
if size(V,1)>rank(V),
    disp('--------------------------------------------------------')
    disp('V does not have full rank')
    disp(['Size(V)=',num2str(size(V,1)),' but rank(V)=',num2str(rank(V))])
    
    return
end
% check unicity
if ~all(real(diag(Deig))>=0),
    %                 disp('--------------------------------------------------------')
    %                 disp('These eigenvalues lie in the negative part of the real axis')
    %                 Deig(real(diag(Deig))<0,real(diag(Deig))<0)
    if Deig(real(diag(Deig))<0,real(diag(Deig))<0)>1e-10
        return
    end
end
Deig(abs(Deig)<1e-10)=0;

% Cube root
B31 = V*Deig.^(1/3)/V;

if any(imag(B31)>1e-8)
    error('This cube root is not real!')
else
    B31 = real(B31);
end
if norm(Bmin-B31^3)> 1e-10
    disp('--------------------------------------------------------')
    disp('The cube root of this matrix might not exist ')
    disp(norm(Bmin-B31^3))
end
if any(any(B31))> 1e3 || any(any(isnan(B31)))
    disp('--------------------------------------------------------')
    disp('Possible problem inverting V. Coefficients of B31 are too big or NaN')
end
%% DEFINE NEW QUARTERLY STATE SPACE

% A - transition matrix for the "minimal state space" - quarterly system
A1 = Bmin;
nA1 = size(A1,2);
xMnemsA = [xMnemsMin;'y';'c';'i';'w'];
nDiff = 4;
A = [A1 zeros(nA1,nDiff);
    1 0 0 zeros(1,27);
    0 1 0 zeros(1,27);
    0 0 1 zeros(1,27);
    zeros(1,4) 1 zeros(1,25)];

% Q - covariance of the shocks in the transition equation - quarterly system
Bs = [minStateTransformMat*PHI; zeros(nDiff,size(PHI,2))];
Q = Bs*Bs';
Q1 = (minStateTransformMat*PHI)*(minStateTransformMat*PHI)';

% n_t = l_t-u_t = (1/phi)(w_t-z_t-eps_chi_t)-u_t
phi = theta(strcmp(thetaMnems,'phi'));

C = [1 zeros(1,25) -1 0 0 0;
    0 1 0 0 1 zeros(1,22) -1 0 0;
    0 0 1 zeros(1,25) -1 0;
    0 0 0 0 1 zeros(1,24) -1;
    zeros(1,9) 1 zeros(1,20);
    zeros(1,4) (1/phi) 0 0 -(1/phi) -1 zeros(1,13) -(1/phi) zeros(1,7);
    zeros(1,8) 1 zeros(1,21);
    zeros(1,5) 1 zeros(1,24);
    zeros(1,25) 1 zeros(1,4)];

%% SET-UP MONTHLY STATE SPACE
AminMonthly = B31;
nAm = size(AminMonthly,2);
selectMonthlyLags = zeros(3*nDiff,nAm+3*nDiff);
selectMonthlyLags(1:nDiff,:)= [1 0 0 zeros(1,23) zeros(1,3*nDiff);
    0 1 0 zeros(1,23) zeros(1,3*nDiff) ;
    0 0 1 zeros(1,23) zeros(1,3*nDiff);
    zeros(1,4) 1 zeros(1,21) zeros(1,3*nDiff)];
selectMonthlyLags(nDiff+1:end,nAm+1:nAm+nDiff*2)=eye(2*nDiff);
Am = [AminMonthly zeros(nAm,3*nDiff);
    selectMonthlyLags];
BminMonthly = (AminMonthly^2+AminMonthly+eye(size(AminMonthly)))\(minStateTransformMat*PHI);

Bm = [BminMonthly; zeros(3*nDiff,size(PHI,2))];

Qm  = Bm*Bm';

Lambda = zeros(nY,nAm+3*nDiff);
Lambda(:,1:nAm) = C(:,1:nAm);
Lambda(:,nAm+nDiff*2+1:nAm+nDiff*3) = C(:,nAm+1:end);


% END OF MODEL-SPECIFIC SECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% IINITIALIZE
start_y = 1995; start_m = 3;  %% Starting dates for the out-of-sample evaluation
end_y   = 2014;   end_m = 6;%% Ending   dates for the out-of-sample evaluation
start_sample = find((time(:,1)==start_y) & (time(:,2)==start_m));
end_sample = find((time(:,1)==end_y) & (time(:,2)==end_m));
start_sampleSPF = find((URSPF(:,1)==start_y)&(URSPF(:,2)==start_m/3));
end_sampleSPF = find((URSPF(:,1)==end_y)&(URSPF(:,2)==end_m/3));

forecastEvalWindow = (end_sample-start_sample+3)/3;
nForecasts = 7;
    
    NOWGDP = zeros(forecastEvalWindow,nForecasts);
    FOR1GDP = zeros(forecastEvalWindow-3,nForecasts);FOR2GDP = zeros(forecastEvalWindow-6,nForecasts);
    FOR3GDP = zeros(forecastEvalWindow-9,nForecasts);FOR4GDP = zeros(forecastEvalWindow-12,nForecasts);
    NOWUR = zeros(forecastEvalWindow,nForecasts); 
    NOWPI =zeros(forecastEvalWindow,nForecasts);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ESTIMATION AND FORECASTING PROCEDURE
% we will produce forecasts with 3 different datasets:
% - only observables, quarterly series (the model's forecast)
% - only observables, monthly series
% - observables+auxiliaries, monthly series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   iPanel = 38; 
   unb_M = logical(UnbPattern(:,:,iPanel));
    count=0;
    initxq = zeros(1,size(A,2))';
    initVq = eye(size(A,2))*10;
    
    initxm = zeros(1,nAm+nDiff*3)';
    initVm = eye(nAm+nDiff*3)*10;
    
    %t=start_sample
    for t=start_sample:3:end_sample
        X = Xfin;
        [~,N]=size(X);
        
        x = X(1:t,:);
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
        tempx(unb_M)=NaN;
        x(end-5:end,:) = tempx;
        
        % Add rows depending on the forecast horizion
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
        My = D'; Sy = ones(1,nY);%std(yq);
        Mx = mean(xq); Sx = std(xq);
        yq_std = (yq-ones(size(yq(:,1)))*My)*diag(1./Sy);
        xq_std = (xq-ones(size(xq(:,1)))*Mx)*diag(1./Sx);
        
        
        %% estimate the coefficients relating the auxiliaries with the observables
        Gamma = ((yq_std'*yq_std)\yq_std'*xq_std)';
        R = diag(xq_std'*xq_std-xq_std'*yq_std*Gamma')/size(xq_std,1);
        
        % standardize monthly data
        T = size(Xm,1);
        Xm_std = (Xm-ones(T,1)*Mx)./(ones(T,1)*Sx);
        Ym_std = (Ym-ones(T,1)*My)./(ones(T,1)*Sy);
        
        %the data
        Z = [Ym_std Xm_std];    %observables+auxiliaries, monthly frequency
        Z_np = Z(:,1:nY);         %only observables, monthly frequency
        Zq =Z(3:3:end,:);        %observables+auxiliaries, quarterly frequency
        Zq_np =Z(3:3:end,1:nY);   %only observables, quarterly frequency
        Tq = size(Zq,1);
        
        % condition quarterly model on existing monthly variables where possible
        ConsRT = diag(Ym_std(end - sum(isnan(Ym_std(:,2))),2))';
        Zq_cond =Zq_np;
        if iPanel>18, % If SPF released condition on those as well
            CondSPF = [GDPSPF(start_sampleSPF+count-1,3)/4-POPDATA(t/3-1)-D(1),...
                CSPF(start_sampleSPF+count-1,3)/4-POPDATA(t/3-1)+PGDPSPF(start_sampleSPF+count-1,3)/4-D(1),...
                PGDPSPF(start_sampleSPF+count-1,3)/4-D(5),...
                URSPF(start_sampleSPF+count-1,4)-D(7)];
            Zq_cond(end-4,[1:2 5 7])=CondSPF;
        end
         Zq(:,1:nY) = Zq_cond;
         
        % Coefficients for the models that deal with quarterly data
        Cq=[C;Gamma*C];
        Rq=[1e-4*ones(nY,1);R];Rq(4)=sigmaME^2;
        if ~isempty(sigmaSPME),
            Rq(9)=(sigmaSPME^2);
        end
        
        for jt = 1:Tq
            CCq(:,:,jt) = Cq;
            CCq_np(:,:,jt) = C;
            AAq(:,:,jt) = A;
            QQq(:,:,jt) = Q;
            Rtemp = Rq;
            Rtemp(isnan(Zq(jt,:))) = 1e+32;     %infinite variance -> zero weight on the missing datapoints
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
        Tq = size(Zq(:,1),1);
        
        % Coefficients for the models that deal with monthly data
        % the cube root B31 if define above where I check existence and unicity
        T = size(Z,1);
        
        Cm = [Lambda;Gamma*Lambda];
        Rm = [1e-4*ones(nY,1);R];Rm(4)=(sigmaME^2);
        if ~isempty(sigmaSPME),
            Rm(9)=(sigmaSPME^2);
        end
        
        for jt = 1:T
            CCm(:,:,jt) = Cm;
            CCm_np(:,:,jt) = Lambda;
            AAm(:,:,jt) = Am;
            QQm(:,:,jt) = Qm;
            Rtemp = Rm; Rtemp(isnan(Z(jt,:)))=1e+32; %infinite variance -> zero weight on the missing datapoints
            RRm(:,:,jt) = diag(Rtemp);
            RRm_np(:,:,jt)=diag(Rtemp(1:nY));
        end;
        
        Z(isnan(Z))=0;
        Z_np(isnan(Z_np))=0;
        Mz = [My Mx]; Sz = [Sy Sx];
      
        % Forecasts - Kalman filters
        [xsmoothm, Vsmoothm, VVsmoothm, ~] = kalman_smoother(Z', AAm, CCm, QQm, RRm, initxm, initVm,'model', (1:T));
        [xsmoothm_np, Vsmoothm_np, VVsmoothm_np, ~] = kalman_smoother(Z_np', AAm, CCm_np, QQm, RRm_np, initxm, initVm,'model', (1:T));
        [xsmoothq_np, Vsmoothq_np, VVsmoothq_np, ~] = kalman_smoother(Zq_cond', AAq, CCq_np, QQq, RRq_np, initxq, initVq,'model', (1:Tq));
        [xsmoothq_npb, Vsmoothq_npb, VVsmoothq_npb, ~] = kalman_smoother(Zq_np', AAq, CCq_np, QQq, RRq_npb, initxq, initVq,'model', (1:Tq));
        
        %de-standardise the data and forecasts
        chim = xsmoothm'*CCm(:,:,1)'*diag(Sz)+ones(T,1)*Mz;
        chim_np = xsmoothm_np'*CCm_np(:,:,1)'*diag(Sy)+ones(T,1)*My;
        chiq_np = xsmoothq_np'*CCq_np(:,:,1)'*diag(Sy)+ones(Tq,1)*My;
        chiq_npb = xsmoothq_npb'*CCq_np(:,:,1)'*diag(Sy)+ones(Tq,1)*My;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % monthly + panel
        GDP_m = chim(3:3:end,1);
        UR_m = chim(3:3:end,7);
         PI_m = chim(3:3:end,5);
       
        % quarterly no panel
        GDP_qnp = chiq_np(1:end,1);
        UR_qnp = chiq_np(1:end,7);
        PI_qnp = chiq_np(1:end,5);
       
        % quarterly no panel b
        GDP_qnpb = chiq_npb(1:end,1);
        UR_qnpb = chiq_npb(1:end,7);
        PI_qnpb = chiq_npb(1:end,5);
        
        % monthly no panel
        GDP_mnp = chim_np(3:3:end,1);
        UR_mnp = chim_np(3:3:end,7);
        PI_mnp = chim_np(3:3:end,5);
       
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %the nowcast
        NOWGDP(t/3,:) = [dates(t) X(t,1) GDPSPF(start_sampleSPF+count-1,3)/4-POPDATA(t/3-1) GDP_qnpb(end-4,1)' GDP_qnp(end-4,1)' GDP_mnp(end-4,1)' GDP_m(end-4,1)'  ] ;
        NOWUR(t/3,:) = [dates(t) X(t,7) URSPF(start_sampleSPF+count-1,4) UR_qnpb(end-4,1)' UR_qnp(end-4,1)'   UR_mnp(end-4,1)' UR_m(end-4,1)' ] ;
        NOWPI(t/3,:) = [dates(t) sum(X(t-9:3:t,5)) sum(X(t-9:3:t-2,5))+PGDPSPF(start_sampleSPF+count-1,3)/4 sum(X(t-9:3:t-2,5))+PI_qnpb(end-4,1) sum(X(t-9:3:t-2,5))+PI_qnp(end-4,1) sum(X(t-9:3:t-2,5))+PI_mnp(end-4,1) sum(X(t-9:3:t-2,5))+PI_m(end-4,1)  ];
         if t<=end_sample-2
                FOR1GDP(t/3,:) = [dates(t+3) X(t+3,1) GDPSPF(start_sampleSPF+count-1,4)/4-POPDATA(t/3-1) GDP_qnpb(end-3,1)' GDP_qnp(end-3,1)'  GDP_mnp(end-3,1)' GDP_m(end-3,1)'  ] ;
         end
        if t<=end_sample-5
                FOR2GDP(t/3,:) = [dates(t+6) X(t+6,1) GDPSPF(start_sampleSPF+count-1,5)/4-POPDATA(t/3-1) GDP_qnpb(end-2,1)' GDP_qnp(end-2,1)'  GDP_mnp(end-2,1)' GDP_m(end-2,1)'  ];
        end
        if t<=end_sample-8
                FOR3GDP(t/3,:) =  [dates(t+9) X(t+9,1) GDPSPF(start_sampleSPF+count-1,6)/4-POPDATA(t/3-1) GDP_qnpb(end-1,1)' GDP_qnp(end-1,1)'  GDP_mnp(end-1,1)' GDP_m(end-1,1)' ];
        end
        if t<=end_sample-11
                 FOR4GDP(t/3,:) = [dates(t+12) X(t+12,1) GDPSPF(start_sampleSPF+count-1,7)/4-POPDATA(t/3-1) GDP_qnpb(end,1)' GDP_qnp(end,1)'  GDP_mnp(end,1)' GDP_m(end,1)'  ];
        end
        
    end
    
    %MSFENOW=mean((NOWGDP(1:end,2)*ones(1,5)-NOWGDP(1:end,3:end)).^2);
    %MSE_bench(:,:)=MSFENOW;
    %disp('    MSFE of GDP NOWCASTS ')
    %disp('      SPF     QmodelB   Qmodel+cond  Mmodel   Mmodel+panel ')
    %disp(MSE_bench(:,:))
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
     
    
%% graphs

%figure, plot(squeeze(NOWGDP(:,1)),squeeze(NOWGDP(:,2)),squeeze(NOWGDP(:,1)),squeeze(NOWGDP(:,4)),squeeze(NOWGDP(:,1)),squeeze(NOWGDP(:,6)),...
%squeeze(NOWGDP(:,1)),squeeze(NOWGDP(:,7)), 'LineWidth',2),
%    legend('actual','QB','M','M+panel','Location','SouthWest'), datetick('x','QQ-YY'),axis([ 728720 735752 -2.5 1.5]),
%    hold on, patch([ 730910,730910,731185,731185],[[-2.5,1.5],[1.5, -2.5]],[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeColor','none'),hold on,
%    patch([733320,733320,733926,733926],[[-2.5,1.5],[1.5, -2.5]],[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeColor','none'),hold off,
%title('GDP nowcast')

