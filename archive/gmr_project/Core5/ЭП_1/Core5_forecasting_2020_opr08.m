function OUTPUT_CORE5 = Core5_forecasting_2020_opr07(Nforc,FH)
'____________________________________________CORE5 VV'
load INPUT

% load Res_core5Rus_forecast % !!!!!!!
load Res_core5VV_detr5_ikN60_forecast

oo_Hdpxf_ = oo_;
M_Hdpxf_ = M_;
% 
% load Res_core4_irf_dec_newtm
% load Mode_core4C_newtm
% load Res_core4_irf_dec
% load Mode_core4B

% load Res_core4Rus
% load Mode_core4RusB

% load Res_core4Rus_minus7
% load Mode_core4RusC_minus7

% load Res_core5Rus
% load Mode_core5RusA
load Mode_core5VV_detr5_ikN60
load Res_core5VV_detr5_ikN60

%___________________________LOADING ESTIMATED VALUES OF PARAMETERS FROM xparam1 file for Core4 model  



for j = 1:length(xparam1)
    if strncmp(char(parameter_names(j)),'eps',3) == 1
        eval(['var_' char(parameter_names(j)) '= xparam1(j)^2']);
    else
        eval([char(parameter_names(j)) '= xparam1(j)']);
    end
    
end

%____________________________________________________WORK with CORE MODEL____________________________________________________________ 
%____________________________________________________________________________________________________________________________________

%____________________________________________________FITTING of HISTORICAL DATA______________________________________________________ 

%________________________________________Business cycle component with CORE 

Nper=size(oo_.SmoothedShocks.eps_ik,1) % Number of periods in Core4 Bayesian estimation
% SHOCKS exo = [ "ik", "rp", "irp", "ystar", "pstar", "istar", "yn", "beta", "pxstar", "ir", "yh", "g", "w", "ik1", "rp1", "irp1", "ystar1", "pstar1", "istar1", "yn1", "beta1", "pxstar1", "ir1", "yh1", "g1", "w1" ]
%                  1    2      3       4         5         6     7     8        9       10    11    12   13    14    15      16       17        18        19      20      21        22       23      24    25    26
u=[oo_.SmoothedShocks.eps_ik'; oo_.SmoothedShocks.eps_rp'; oo_.SmoothedShocks.eps_irp'; oo_.SmoothedShocks.eps_ystar'; oo_.SmoothedShocks.eps_pstar'; oo_.SmoothedShocks.eps_istar'; oo_.SmoothedShocks.eps_yn'; oo_.SmoothedShocks.eps_beta'; oo_.SmoothedShocks.eps_pxstar'; oo_.SmoothedShocks.eps_ir'; oo_.SmoothedShocks.eps_yh'; oo_.SmoothedShocks.eps_g'; oo_.SmoothedShocks.eps_w'; zeros(13, length(oo_.SmoothedShocks.eps_ik))];
%                   1                        2                           3                             4                              5                             6                                 7                            8                            9                          10                             11                         12                         13    

A=[zeros(M_.endo_nbr,M_.nstatic) oo_.dr.ghx zeros(M_.endo_nbr,M_.endo_nbr-M_.nstatic-M_.npred-M_.nboth)];
B=oo_.dr.ghu;
% B_decl = B(oo_.dr.inv_order_var,:) ;

%________________________Matrices for forecasting


% Af=[zeros(M_C4f_.endo_nbr,M_C4f_.nstatic) oo_C4f_.dr.ghx zeros(M_C4f_.endo_nbr,M_C4f_.endo_nbr-M_C4f_.nstatic-M_C4f_.npred-M_C4f_.nboth)];
% Bf=oo_C4f_.dr.ghu;
% Bf_decl = Bf(oo_C4f_.dr.inv_order_var,:) ;

AHdpxf=[zeros(M_Hdpxf_.endo_nbr,M_Hdpxf_.nstatic) oo_Hdpxf_.dr.ghx zeros(M_Hdpxf_.endo_nbr,M_Hdpxf_.endo_nbr-M_Hdpxf_.nstatic-M_Hdpxf_.npred-M_Hdpxf_.nboth)];
BHdpxf=oo_Hdpxf_.dr.ghu;
BHdpxf_decl = BHdpxf(oo_Hdpxf_.dr.inv_order_var,:) ;

% ddpc_distar = Bf_decl(1,6)
% ddpc_dik = Bf_decl(1,1)

y=nan(M_.endo_nbr,Nper);
y_DR=nan(M_.endo_nbr,Nper);

% Initial condition definition
inv_order = oo_.dr.inv_order_var; 
% y_DR(:,1)=A * oo_.shock_decomposition(oo_.dr.order_var,14,1) + B * u(:,1); % 
y_DR(:,1)=oo_.shock_decomposition(oo_.dr.order_var,27,1); % THAT IS RIGHT VARIANT!!!!! Checked many times!!!!
for j=2:Nper

    y_DR(:,j)=A*y_DR(:,j-1)+B*u(:,j);

end

y=y_DR(inv_order,:);

%___________________Check for endogenous fact
y_fact_check=nan(M_.endo_nbr,Nper);
for j=1:M_.endo_nbr
    for k = 1:Nper
        y_fact_check(j,k)=oo_.shock_decomposition(j,28,k);
    end
end


%_______________________________Dynamics of y on the significance horizon (from Nper-Nsignif+1 till Nper)  

y_DR_sq = nan(M_.endo_nbr,Nsignif);

if Nsignif == Nper % Check whether it is the first observation. If it is, than standard decision
    % y_DR_sq(:,1) = A * oo_.shock_decomposition(oo_.dr.order_var,14,1) + B * u(:,1); % 
    y_DR_sq(:,1) = oo_.shock_decomposition(oo_.dr.order_var,27,1);
else
    y_DR_sq(:,1) = B * u(:,Nper-Nsignif+1);
end

for j=2:Nsignif
  
    y_DR_sq(:,j)=A*y_DR_sq(:,j-1)+B * u(:,Nper-Nsignif+j);

end

y_sq=y_DR_sq(oo_.dr.inv_order_var,:);
[y_sq(20,:)' y(20,:)' y_fact_check(20,:)']
%________________________________________________REVEALING SHOCKS on the forecasted horizon using BASELINE MODEL and available information  

y_DR_f = nan(M_.endo_nbr,Nforc);
y_f = nan(M_.endo_nbr,Nforc);


% y_DR_f(:,1) = y_DR(:,Nper);
% 
% y_DR_f(:,1) = zeros(M_.endo_nbr,1);

%__________FUTURE SHOCKS
uf = zeros(26,Nforc);

% CORE5  [ "ik", "rp", "irp", "ystar", "pstar", "istar", "yn", "beta", "pxstar", "ir", "yh", "g", "w", "ik1", "rp1", "irp1", "ystar1", "pstar1", "istar1", "yn1", "beta1", "pxstar1", "ir1", "yh1", "g1", "w1" ]
%            1    2      3       4         5         6     7     8        9       10    11    12   13    14    15      16       17        18        19      20      21        22       23      24    25    26
% CORE4  [ "ik", "rp", "irp", "ystar", "pstar", "istar", "y", "beta", "pxstar", "ir", "yfh", "g", "w"]
%            1     2      3       4        5        6      7     8         9      10     11   12   13
%  (lag1)    14    15     16      17       18       19     20    21        22     23     24   25   26
% 
% CORE5 [ "dpc", "dpn", "dpt", "dph", "dpf", "dpf_p", "pc", "pn", "pt", "ph", "pf", "pf_p", "c", "cn", "ct", "ch", "cf", "y", "yex", "i", "ik", "s", "rp", "mcn", "mch", "w", "n", "bstar", "ystar", "dpstar", "istar", "u_yn", "u_yh", "u_beta", "u_rp", "pxstar", "ir", "pstar", "g", "wp"] 
%           1      2      3      4      5       6      7     8     9     10    11    12      13   14    15    16    17    18    19    20   21    22   23    24     25     26   27    28        29       30        31      32      33       34       35       36      37     38      39   40            
% CORE4 [ "dpc", "dph", "dpf", "dpsh", "dpfh", "pc", "ph", "pf", "psh", "pfh", "c", "ch", "cf", "csh", "cfh", "y", "yex", "i", "ik", "s", "rp", "mcsh", "w", "n", "bstar", "dpcn", "dphn", "dpfn", "dpshn", "dpfhn", "pcn", "phn", "pfn", "pshn", "pfhn", "cn", "chn", "cfn", "cshn", "cfhn", "yn", "yexn", "in", "ikn", "sn", "rpn", "wn", "nn", "bstarn", "irp", "ystar", "dpstar", "istar", "eps", "epsfh", "u", "urp", "pxstar", "ir", "pstar", "g", "wp", "wpn", "uw"] 
%           1     2       3     4        5      6     7     8      9     10    11    12    13    14     15    16     17   18    19    20    21   22      23   24     25      26      27      28       29      30       31     32     33     34      35     36     37     38     39      40     41     42     43     44    45    46     47    48      49       50      51       52        53      54      55     56    57     58       59      60    61    62     63    64       


% load Res_Detr5Rus % Load detrended file estimation
% load Res_Detr5Rus_minus7 % Load detrended file estimation
load Res_Detr5VV_ikN60
% load Data10_19_detr5Rus dpc_s dpc gdp % Load raw data fore detrending file
load Data10_19_detr5VV dpc_s dpc grp_VV wp % Load raw data fore detrending file

Ndetr = length(dpc);  % Length of detrended series and number of periods of detrended observables

% rho_irp = oo_.posterior_mode.parameters.rho_irp ; 
rho_istar = M_Hdpxf_.params(16);
% rho_pxstar = oo_.posterior_mode.parameters.rho_pxstar;
rho_pxstar = M_.params(22);
%__________________________________________SETTING SHOCKS from OBSERVABLE DATA and FORCASTED SERIES  

% ________________________________ REVEALING oil price shocks


uf(9, 1) = log(PX_1q20) - log(PX_Long) - rho_pxstar * y(36,Nper) ;
uf(22, 1) = log(PX_q1E2q20) - log(PX_Long) - rho_pxstar * (log(PX_1q20) - log(PX_Long)) ;
uf(9, 2) = log(PX_2q20) - log(PX_Long) - rho_pxstar * (log(PX_1q20) - log(PX_Long)) - uf(22, 1);
uf(9, 3) = log(PX_3q20) - log(PX_Long) - rho_pxstar * (log(PX_2q20) - log(PX_Long));
uf(9, 4) = log(PX_4q20) - log(PX_Long) - rho_pxstar * (log(PX_3q20) - log(PX_Long));

% _________________________________REAVILING internal risk premium shock
% i_VV_4q18 = 0.1061 / 4 ; % Tarasenko
% uf(3, 2) = (i_VV_act_4q18 - oo_Detr2.posterior_mode.parameters.a0_i_VV) - 0.5 * (y(13, Nper) + (0.0775/4 - 0.0175))  - rho_irp * y(20, Nper); 
% uf(3, 3) = (i_VV_act_1q19 - oo_Detr2.posterior_mode.parameters.a0_i_VV) - 0.5 * ((0.0775/4 - 0.0175) + (0.0775/4 - 0.0175)) - rho_irp * (i_VV_act_4q18 - oo_Detr2.posterior_mode.parameters.a0_i_VV - 0.5 * (y(13, Nper) + (0.0775/4 - 0.0175))); 
% uf(3, 4) = (i_VV_act_2q19 - oo_Detr2.posterior_mode.parameters.a0_i_VV) - 0.5 * ((0.075/4 - 0.0175) + (0.0775/4 - 0.0175)) - rho_irp * (i_VV_act_1q19 - oo_Detr2.posterior_mode.parameters.a0_i_VV - 0.5 * ((0.0775/4 - 0.0175) + (0.0775/4 - 0.0175))); 
% i_3q19 = i_VV_act_3q19 - M_Detr4_ikN60.params(8);
% i_4q19 = i_VV_act_4q19 - M_Detr4_ikN60.params(8);
i_1q20 = i_VV_act_1q20 - M_Detr5.params(8); % -0.005/4 corresponds to ikN=5.5%
i_2q20 = i_VV_act_2q20 - M_Detr5.params(8); % -0.005/4 corresponds to ikN=5.5%
i_3q20 = i_VV_act_3q20 - M_Detr5.params(8); % -0.005/4 corresponds to ikN=5.5%
i_4q20 = i_VV_forecast_4q20 - M_Detr5.params(8); % -0.005/4 corresponds to ikN=5.5%


% uf(6, 1) = (istar_actual_3q19 - istar_LR) / 400 - rho_istar * y(53,Nper) ;
% uf(6, 2) = (istar_actual_4q19 - istar_LR) / 400 - rho_istar * (istar_actual_3q19 - istar_LR) / 400 ;

uf(6, 1) = (istar_actual_1q20 - istar_LR) / 400 - rho_istar * y(31,Nper) ;
uf(6, 2) = (istar_actual_2q20 - istar_LR) / 400 - rho_istar * (istar_actual_1q20 - istar_LR) / 400 ;
uf(19, 2) = (istar_q2E3q20 - istar_LR) / 400 - rho_istar * (istar_actual_2q20 - istar_LR) / 400 ;
uf(19, 3) = (istar_q3E4q20 - istar_LR) / 400 - rho_istar * (istar_q2E3q20 - istar_LR) / 400 ;
uf(19, 4) = (istar_q4E1q21 - istar_LR) / 400 - rho_istar * (istar_q3E4q20 - istar_LR) / 400 ;

%________________________________Foregign inflation and foreign output shocks are also might be taken 
% uf(3,4) = 0;

%________________________OPR07
% uf(4, 1) = -0.01;
% uf(17, 1) = -0.01;
% uf(4, 2) = -0.07;
% uf(17, 2) = -0.05;
% uf(17, 3) = -0.03;

%_______________________OPR08
uf(4, 1) = -0.01;
uf(17, 1) = -0.01;
uf(4, 2) = -0.07;
uf(17, 2) = -0.04;
uf(17, 3) = -0.022;
uf(17, 4) = -0.01;

rho_g = M_Hdpxf_.params(33);

uf(12,1) = dG_YoY1q20;
uf(12,2) = dG_YoY2q20 - rho_g * dG_YoY1q20; 
uf(12,3) = dG_YoY3q20 - rho_g * dG_YoY2q20;
uf(25,3) = dG_YoY4q20 - rho_g * dG_YoY3q20;


%_____________________________________________FITTING ACTUAL INFLATION, EXCHANGE RATE AND KEY RATE BY SHOCKS IN Q4:2018 

%___________________________________ REVEALING actual business cycle compenent of VV inflation  in Q4:2018
% dp_VV_act_4q18 = 0.043; % YoY
% dp_VV = dp_VV_F * 0.37456 + dp_VV_M * 0.35234 + dp_VV_S * (1 - 0.37456 - 0.35234) ; % Aggregate inflation in VV
% dp_VV_4q18 = dp_VV_act_4q18 - (dp_VV(Ndetr) + dp_VV(Ndetr-1) + dp_VV(Ndetr-2)) ; % Actual aggregate inflation in VV in Q4:2018
% dp_VV_s_4q18 = oo_Detr2.SmoothedVariables.dp_VV_F_s(Ndetr-3) * 0.37456 + oo_Detr2.SmoothedVariables.dp_VV_M_s(Ndetr-3) * 0.35234 + oo_Detr2.SmoothedVariables.dp_VV_S_s(Ndetr-3) * (1 - 0.37456 - 0.35234);  % Aggregate seasonal component of VV inflation in Q4:2018
% 

% b0_F=oo_Detr3.posterior_mode.parameters.b0_F;
% b1_F=oo_Detr3.posterior_mode.parameters.b1_F;
% b0_M=oo_Detr3.posterior_mode.parameters.b0_M;
% b1_M=oo_Detr3.posterior_mode.parameters.b1_M;
% b0_S=oo_Detr3.posterior_mode.parameters.b0_S;
% b1_S=oo_Detr3.posterior_mode.parameters.b1_S;
% 
% t=[1:Ndetr]'; % t = trend
% invt=1./t; % invt = 1/t
% %________ALL trends starts from 2009 so in forecasting trend series
% %start from period=5
% dpF_tr = 0.01+b0_F*(1/20)^b1_F+b0_F*b1_F*(1/20)^(b1_F-1)* invt; % t=39 here is the period around which Detrending model was linearized  
% dpM_tr = 0.01+b0_M*(1/20)^b1_M+b0_M*b1_M*(1/20)^(b1_M-1)* invt;
% dpS_tr = 0.01+b0_S*(1/20)^b1_S+b0_S*b1_S*(1/20)^(b1_S-1)* invt;
% 
% dpc_tr = dpF_tr * 0.37456 + dpM_tr * 0.35234 + dpS_tr * (1 - 0.37456 - 0.35234);
dpc_tr=0.25 * log(1 + 0.04);
% dpc = dpF * 0.37456 + dpM * 0.35234 + dpS * (1 - 0.37456 - 0.35234);

%___________________________________ REVEALING short term ACTUAL business cycle compenent of VV inflation  in Q3:2019  

% % dp_VV_act_1q19 = 0.0515; % Actual in VV YoY in 04.03.2019
% dp_VV_3q19 = dp_VV_actYoY_3q19 -  (dpc(Ndetr) + dpc(Ndetr-1) +  dpc(Ndetr-2))  % Actual aggregate inflation in VV in Q3:2019
% % dp_VV_3q19_check = -0.002569; % Exact figure from dp_vvgu file created by Alexandr Eliseev
% dpc_s_3q19 = -0.005706  % Exact figure from dp_vvgu file created by Alexandr Eliseev: it is not the same as  dpc_s_3q19 = dpc_s(length(dpc_s)-3) because deseasoning was done for q3:2019
% 
% dpc_3q19 = dp_VV_3q19 - dpc_s_3q19 - dpc_tr;  % business cycle component of the inflation
% 
% %__________________________________Actual bus-cycl compon of VV inflation in Q4:2019   
% dp_VV_4q19 = dp_VV_actYoY_4q19 - (dp_VV_3q19 + dpc(Ndetr) + dpc(Ndetr-1));  % Actual aggregate inflation in VV in Q4:2019
% dpc_s_4q19 = dpc_s(length(dpc_s)-2)
% dpc_4q19 = dp_VV_4q19 - dpc_s_4q19 - dpc_tr;  % business cycle component of the inflation

%__________________________________Actual bus-cycl compon of VV inflation in Q1:2020   
dp_VV_1q20 = dp_VV_actYoY_1q20 - (dpc(Ndetr) + dpc(Ndetr-1) +  dpc(Ndetr-2));  % Forecasted aggregate inflation in VV in Q1:2020
% dpc_s_1q20 = 0.005331;
dpc_s_1q20 = 0.0046;
dpc_1q20 = dp_VV_1q20 - dpc_s_1q20 - dpc_tr;  % business cycle component of the inflation

%__________________________________Forecasted bus-cycl compon of VV inflation in Q2:2020   
dp_VV_2q20 = dp_VV_actYoY_2q20 - (dp_VV_1q20 + dpc(Ndetr) + dpc(Ndetr-1));  % Forecasted aggregate inflation in VV in Q1:2020
% dpc_s_2q20 = dpc_s(length(dpc_s)-2) - (dpc_s_1q20 - dpc_s(length(dpc_s)-3))/3;  % Aggregate seasonal component of VV inflation in Q2:2019 
dpc_s_2q20 = -0.0008;
dpc_2q20 = dp_VV_2q20 - dpc_s_2q20 - dpc_tr;  % business cycle component of the inflation

%__________________________________Forecasted bus-cycl compon of VV inflation in Q3:2020   
dp_VV_3q20 = dp_VV_actYoY_3q20 - (dp_VV_2q20 + dp_VV_1q20 + dpc(Ndetr));  % Forecasted aggregate inflation in VV in Q1:2020
% dpc_s_3q20 = dpc_s(length(dpc_s)-1) - (dpc_s_1q20 - dpc_s(length(dpc_s)-3))/3;  % Aggregate seasonal component of VV inflation in Q2:2019 
dpc_s_3q20 = -0.0049;
dpc_3q20 = dp_VV_3q20 - dpc_s_3q20 - dpc_tr;  % business cycle component of the inflation

%__________________________________Forecasted bus-cycl compon of VV inflation in Q4:2020   
dp_VV_4q20 = dp_VV_STforecastYoY_4q20 - (dp_VV_3q20 + dp_VV_2q20 + + dp_VV_1q20);  % Forecasted aggregate inflation in VV in Q1:2020
% dpc_s_4q20 = dpc_s(length(dpc_s));  % Aggregate seasonal component of VV inflation in Q2:2019 
% dpc_s_4q20 = -(dpc_s_1q20 + dpc_s_2q20 + dpc_s_3q20);
dpc_s_4q20 = 0.0011;
dpc_4q20 = dp_VV_4q20 - dpc_s_4q20 - dpc_tr;  % business cycle component of the inflation

%__________________________________Forecasted bus-cycl compon of VV inflation in Q1:2021   
dp_VV_1q21 = dp_VV_STforecastYoY_1q21 - (dp_VV_4q20 + dp_VV_3q20 + + dp_VV_2q20);  % Forecasted aggregate inflation in VV in Q1:2020
% dpc_s_4q20 = dpc_s(length(dpc_s));  % Aggregate seasonal component of VV inflation in Q2:2019 
% dpc_s_4q20 = -(dpc_s_1q20 + dpc_s_2q20 + dpc_s_3q20);
% dpc_s_1q21 = dpc_s_1q20;
dpc_s_1q21 = 0.004;
dpc_1q21 = dp_VV_1q21 - dpc_s_1q21 - dpc_tr;  % business cycle component of the inflation

%__________________________________Forecasted bus-cycl compon of VV inflation in Q2:2021   
dp_VV_2q21 = dp_VV_STforecastYoY_2q21 - (dp_VV_1q21 + dp_VV_4q20 + + dp_VV_3q20);  % Forecasted aggregate inflation in VV in Q1:2020
% dpc_s_4q20 = dpc_s(length(dpc_s));  % Aggregate seasonal component of VV inflation in Q2:2019 
% dpc_s_4q20 = -(dpc_s_1q20 + dpc_s_2q20 + dpc_s_3q20);
% dpc_s_1q21 = dpc_s_1q20;
dpc_s_2q21 = - 0.0002;
dpc_2q21 = dp_VV_2q21 - dpc_s_2q21 - dpc_tr;  % business cycle component of the inflation

%______________________SEASONAL COMPONENT in forecasted series_____________

dpc_s_f = zeros(Nforc,1);

dpc_s_f(1) = dpc_s_1q20;
dpc_s_f(2) = dpc_s_2q20;
dpc_s_f(3) = dpc_s_3q20;
dpc_s_f(4) = dpc_s_4q20;

dpc_s_f(5) = dpc_s_1q21;
dpc_s_f(6) = dpc_s_2q21;
dpc_s_f(7) = dpc_s_3q20 - ((dpc_s_2q21 + dpc_s_1q21) - (dpc_s_2q20 + dpc_s_1q20))/2;
dpc_s_f(8) = dpc_s_4q20 - ((dpc_s_2q21 + dpc_s_1q21) - (dpc_s_2q20 + dpc_s_1q20))/2;
for j = 1:4
for n = 1:fix(Nforc/4 - 1)
    dpc_s_f(j + n*4) = dpc_s_f(4 + j);
end
end

%___________________________________REVEALNG of business cycle component of exchange rate
% s_tr = a0_s + (0.01 - a1_Pstar) * t

% s_3q19 = log(S_actual_3q19) - (oo_Detr4_ikN60.SmoothedVariables.s_tr(Ndetr) + 1*(0.01-oo_Detr4_ikN60.posterior_mode.parameters.a1_pstar));
% s_4q19 = log(S_actual_4q19) - (oo_Detr4_ikN60.SmoothedVariables.s_tr(Ndetr) + 2*(0.01-oo_Detr4_ikN60.posterior_mode.parameters.a1_pstar));
s_1q20 = log(S_actual_1q20) - (oo_Detr5.SmoothedVariables.s_tr(Ndetr) + 1*(0.01-oo_Detr5.posterior_mode.parameters.a1_pstar));
s_2q20 = log(S_actual_2q20) - (oo_Detr5.SmoothedVariables.s_tr(Ndetr) + 2*(0.01-oo_Detr5.posterior_mode.parameters.a1_pstar));
s_3q20 = log(S_actual_3q20) - (oo_Detr5.SmoothedVariables.s_tr(Ndetr) + 3*(0.01-oo_Detr5.posterior_mode.parameters.a1_pstar));
s_4q20 = log(S_actual_4q20) - (oo_Detr5.SmoothedVariables.s_tr(Ndetr) + 4*(0.01-oo_Detr5.posterior_mode.parameters.a1_pstar));

%___________________________________REVEALING  business cycle component of key rate  
% ik_actual = 7.75;

% ik_3q19 = ik_actual_3q19/400 - ik_Neutral;
% ik_4q19 = ik_actual_4q19/400 - ik_Neutral;
ik_1q20 = ik_actual_1q20/400 - ik_Neutral;
ik_2q20 = ik_bl_2q20/400 - ik_Neutral;
ik_3q20 = ik_bl_3q20/400 - ik_Neutral;
ik_4q20 = ik_bl_4q20/400 - ik_Neutral;
ik_1q21 = ik_bl_1q21/400 - ik_Neutral;

%___________________________________REVEALING  business cycle component of output  

% y_actual_4q18 = rgdp(Ndetr-3) + log(1 + dY_YoY4q18_actual/100) ;
% y_4q18 = y_actual_4q18 - oo_y_filt.SmoothedVariables.rgdp_s(31-3) - oo_y_filt.posterior_mode.parameters.a0 - M_y_filt.params(2) * 40;
% 
% y_actual_1q19 = rgdp(Ndetr-2) + log(1 + dY_YoY1q19_actual/100) ;
% y_1q19 = y_actual_1q19 - oo_y_filt.SmoothedVariables.rgdp_s(31-2) - oo_y_filt.posterior_mode.parameters.a0 - M_y_filt.params(2) * 41;
% 
% y_actual_2q19 = rgdp(Ndetr-1) + log(1 + dY_YoY2q19_actual/100) ;
% y_2q19 = y_actual_2q19 - oo_y_filt.SmoothedVariables.rgdp_s(31-1) - oo_y_filt.posterior_mode.parameters.a0 - M_y_filt.params(2) * 38 - 0.015;

% load grp_VV

dy_tr = 0.25 * log(1 + 0.015);

% y_actual_3q19 = grp_VV(Ndetr-3) + log(1 + dY_YoY3q19_actual/100) ;
% y_3q19 = y_actual_3q19 - (oo_Detr4_ikN60.SmoothedVariables.y_tr(Ndetr) + dy_tr);
% y_actual_4q19 = grp_VV(Ndetr-2) + log(1 + dY_YoY4q19_actual/100) ;
% y_4q19 = y_actual_4q19 - (oo_Detr4_ikN60.SmoothedVariables.y_tr(Ndetr) + 2 * dy_tr);

y_actual_1q20 = grp_VV(Ndetr-3) + log(1 + dY_YoY1q20_actual/100) ;
y_1q20 = y_actual_1q20 - (oo_Detr5.SmoothedVariables.y_tr(Ndetr) + dy_tr);

y_actual_2q20 = grp_VV(Ndetr-2) + log(1 + dY_YoY2q20_actual/100) ;
y_2q20 = y_actual_2q20 - (oo_Detr5.SmoothedVariables.y_tr(Ndetr) + 2 * dy_tr - log(1.02)); %  - log(1.02) c corresponds to trend reduction on 2% in 2q2020 

y_actual_3q20 = grp_VV(Ndetr-1) + log(1 + dY_YoY3q20_actual/100) ;
y_3q20 = y_actual_3q20 - (oo_Detr5.SmoothedVariables.y_tr(Ndetr) + 3 * dy_tr - log(1.02)); %  - log(1.02) 

y_forecast_4q20 = grp_VV(Ndetr) + log(1 + dY_YoY4q20_forecast/100) ;
y_4q20 = y_forecast_4q20 - (oo_Detr5.SmoothedVariables.y_tr(Ndetr) + 4 * dy_tr - log(1.02)); %  - log(1.02)

y_forecast_1q21 = y_actual_1q20 + log(1 + dY_YoY1q21_forecast/100) ;
y_1q21 = y_forecast_1q21 - (oo_Detr5.SmoothedVariables.y_tr(Ndetr) + 5 * dy_tr - log(1.02)); %  - log(1.02)

% REAL WAGES
dwp_tr = 0.25 * log(1 + 0.020);

wp_actual_1q20 = wp(Ndetr-3) + log(1 + dwp_YoY1q20_actual/100) ;
wp_1q20 = wp_actual_1q20 - (oo_Detr5.SmoothedVariables.wp_tr(Ndetr) + dwp_tr);

wp_actual_2q20 = wp(Ndetr-2) + log(1 + dwp_YoY2q20_actual/100) ;
wp_2q20 = wp_actual_2q20 - (oo_Detr5.SmoothedVariables.wp_tr(Ndetr) + 2 * dwp_tr);

wp_actual_3q20 = wp(Ndetr-1) + log(1 + dwp_YoY3q20_actual/100) ;
wp_3q20 = wp_actual_3q20 - (oo_Detr5.SmoothedVariables.wp_tr(Ndetr) + 3 * dwp_tr);

wp_forecast_4q20 = wp(Ndetr) + log(1 + dwp_YoY4q20_forecast/100) ;
wp_4q20 = wp_forecast_4q20 - (oo_Detr5.SmoothedVariables.wp_tr(Ndetr) + 4 * dwp_tr);



%____________________ FITTING FOR 1q20_____________________________________
%__________________________________________________________________________

% z=z0 + D*w;
% z0 is y without such shocks

z_1q20 = [dpc_1q20; ik_1q20; s_1q20; i_1q20; y_1q20; wp_1q20];

% CORE5  [ "ik", "rp", "irp", "ystar", "pstar", "istar", "yn", "beta", "pxstar", "ir", "yh", "g", "w", "ik1", "rp1", "irp1", "ystar1", "pstar1", "istar1", "yn1", "beta1", "pxstar1", "ir1", "yh1", "g1", "w1" ]
%            1    2      3       4         5         6     7     8        9       10    11    12   13    14    15      16       17        18        19      20      21        22       23      24    25    26

%___________Shares of different shocks are set exogenously
beta_share_1q20 = 0; % Beta is used to explain observables
nontrad_share_1q20 = 0.5;
trad_share_1q20 = 1 - beta_share_1q20 - nontrad_share_1q20;


%________D_1 corresponds to eps_y (sticky home goods supply shock)

y_DR_f(:,1) = AHdpxf*y_DR_sq(:,Nsignif) + BHdpxf*uf(:,1);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

dpc0 = y_f(1, 1);
ik0 = y_f(21, 1);
s0 = y_f(22, 1);
i0 = y_f(20, 1);
y0 = y_f(18, 1);
wp0 = y_f(40, 1);
z0_1q20_1 = [dpc0; ik0; s0; i0; y0; wp0] ;
%__________________without w shocks

D_1 = BHdpxf_decl([1 21 22 20 18 40],[7 1 2 3 8 13]);
w_1 = D_1^(-1) * (z_1q20 - z0_1q20_1) % calculated shocks to fit observables in 1q20

uf(7, 1) =  nontrad_share_1q20 / (1 - beta_share_1q20) * w_1(1); % sticky home supply shock 

%________D_2 corresponds to eps_yfh (flexible home goods supply shock)

y_DR_f(:,1) = AHdpxf*y_DR_sq(:,Nsignif) + BHdpxf*uf(:,1);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

dpc0 = y_f(1, 1);
ik0 = y_f(21, 1);
s0 = y_f(22, 1);
i0 = y_f(20, 1);
y0 = y_f(18, 1);
wp0 = y_f(40, 1);
z0_1q20_2 = [dpc0; ik0; s0; i0; y0; wp0] ;
%__________________without w shocks

D_2 = BHdpxf_decl([1 21 22 20 18 40],[11 1 2 3 8 13]);
w_2 = D_2^(-1) * (z_1q20 - z0_1q20_2) % calculated shocks to fit observables in 3q19

uf(11, 1) = w_2(1); % flexible home supply shock
uf(1, 1) = w_2(2); % external risk premium shock
uf(2, 1) = w_2(3); % key rate shock
uf(3, 1) = w_2(4);
uf(8, 1) = w_2(5);
uf(13, 1) = w_2(6);

%__________________________________________________________________________

y_DR_f(:,1) = AHdpxf*y_DR_sq(:,Nsignif) + BHdpxf*uf(:,1);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
%__________________________________________________________________________
%__________________________________________________________________________

%____________________ FITTING FOR 2q20_____________________________________
%__________________________________________________________________________
% z=z0 + D*w;
% z0 is y without such shocks

z_2q20 = [dpc_2q20; ik_2q20; s_2q20; i_2q20; y_2q20; wp_2q20];

% SHOCKS: [ "ik", "rp", "irp", "ystar", "pstar", "istar", "y", "beta", "pxstar", "ir", "yfh", "g", "w"]
%            1     2      3       4        5        6      7     8         9      10     11   12   13  

%___________Shares of different shocks are set exogenously
beta_share_2q20 = 0; % Beta is used to explain observables
nontrad_share_2q20 = 0.5;
trad_share_2q20 = 1 - beta_share_2q20 - nontrad_share_2q20;


%________D_1 corresponds to eps_y (sticky home goods supply shock)

y_DR_f(:,2) = AHdpxf*y_DR_f(:,1) + BHdpxf*uf(:,2);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

dpc0 = y_f(1, 2);
ik0 = y_f(21, 2);
s0 = y_f(22, 2);
i0 = y_f(20, 2);
y0 = y_f(18, 2);
wp0 = y_f(40, 2);
z0_2q20_1 = [dpc0; ik0; s0; i0; y0; wp0] ;
%__________________without w shocks

D_1 = BHdpxf_decl([1 21 22 20 18 40],[7 1 2 3 8 13]);
w_1 = D_1^(-1) * (z_2q20 - z0_2q20_1) % calculated shocks to fit observables in 3q19

uf(7,2) =  nontrad_share_2q20 / (1 - beta_share_2q20) * w_1(1); % sticky home supply shock 

%________D_2 corresponds to eps_yfh (flexible home goods supply shock)

y_DR_f(:,2) = AHdpxf*y_DR_f(:,1) + BHdpxf*uf(:,2);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

dpc0 = y_f(1, 2);
ik0 = y_f(21, 2);
s0 = y_f(22, 2);
i0 = y_f(20, 2);
y0 = y_f(18, 2);
wp0 = y_f(40, 2);

z0_2q20_2 = [dpc0; ik0; s0; i0; y0; wp0] ;
%__________________without w shocks

D_2 = BHdpxf_decl([1 21 22 20 18 40],[11 1 2 3 8 13]);
w_2 = D_2^(-1) * (z_2q20 - z0_2q20_2) % calculated shocks to fit observables in 3q19

uf(11, 2) = w_2(1); % 
uf(1, 2) = w_2(2); % 
uf(2, 2) = w_2(3); % key rate shock
uf(3, 2) = w_2(4);
uf(8, 2) = w_2(5);
uf(13, 2) = w_2(6);

%__________________________________________________________________________

y_DR_f(:,2) = AHdpxf*y_DR_f(:,1) + BHdpxf*uf(:,2);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
%__________________________________________________________________________
%__________________________________________________________________________

% 
% %__________________________________________________________________________
% %______________________NO KSP 2q20_________________________________________
% 
% z_2q20_1 = [ik_2q20; s_2q20; i_2q20; y_2q20];
% uf_noKSP = uf;
% uf_noKSP([1 2 3 7 8 11],2) = [0; 0; 0; 0; 0; 0]; % Obnulenie of KSP shocks
% y_DR_f(:,2) = AHdpxf*y_DR_f(:,1) + BHdpxf*uf_noKSP(:,2);
% y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
% ik0 = y_f(21, 2);
% s0 = y_f(22, 2);
% i0 = y_f(20, 2); 
% y0 = y_f(18, 2);
% z0_2q20_4 = [ik0; s0; i0; y0];
% w_4 = BHdpxf_decl([21 22 20 18],[1 2 3 8])^(-1) * (z_2q20_1 - z0_2q20_4);
% uf_noKSP(1,2) = w_4(1);
% uf_noKSP(2,2) = w_4(2);
% uf_noKSP(3,2) = w_4(3);
% uf_noKSP(8,2) = w_4(4);


% %____________________ FITTING FOR 3q20___________________________________
% %________________________________________________________________________
% 
% z_3q20 = [ik_3q20];
% 
% y_DR_f(:,2) = AHdpxf*y_DR_f(:,1) + BHdpxf*uf(:,2);
% y_DR_f(:,3) = AHdpxf*y_DR_f(:,2) + BHdpxf*uf(:,3);
% y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
% ik0 = y_f(19, 3);
% z0_3q20 = [ik0];
% D = BHdpxf_decl([19],[1]);
% w_5 = D^(-1) * (z_3q20 - z0_3q20);
% uf(1, 3) = w_5;
% uf_noKSP(1, 3) = w_5;
% 
% y_DR_f(:,3) = AHdpxf*y_DR_f(:,2) + BHdpxf*uf(:,3);
% y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

%____________________ FITTING FOR 3q20_____________________________________
%__________________________________________________________________________

z_3q20 = [dpc_3q20; ik_3q20; s_3q20; i_3q20; y_3q20; wp_3q20];

%___________Shares of different shocks are set exogenously
beta_share_3q20 = 0.5;
nontrad_share_3q20 = 0.25;
trad_share_3q20 = 1 - beta_share_3q20 - nontrad_share_3q20;

%__________________________________________________________________________
%_________D_1 corresponds to eps_beta shock
y_DR_f(:,2) = AHdpxf*y_DR_f(:,1) + BHdpxf*uf(:,2);
y_DR_f(:,3) = AHdpxf*y_DR_f(:,2) + BHdpxf*uf(:,3);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
%________D_1 corresponds to eps_yn

dpc0 = y_f(1, 3);
ik0 = y_f(21, 3);
s0 = y_f(22, 3);
i0 = y_f(20, 3);
y0 = y_f(18, 3);
wp0 = y_f(40, 3);
z0_3q20_1 = [dpc0; ik0; s0; i0; y0; wp0] ;

D_1 = BHdpxf_decl([1 21 22 20 18 40],[7 1 2 3 8 13]);
w_1 = D_1^(-1) * (z_3q20 - z0_3q20_1) % calculated shocks to fit observables in 3q20

uf(7,3) =  nontrad_share_3q20 / (1 - beta_share_3q20) * w_1(1); % sticky home supply shock 

%________D_2 corresponds to eps_yt (flexible home goods supply shock)

y_DR_f(:,3) = AHdpxf*y_DR_f(:,2) + BHdpxf*uf(:,3);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

dpc0 = y_f(1, 3);
ik0 = y_f(21, 3);
s0 = y_f(22, 3);
i0 = y_f(20, 3);
y0 = y_f(18, 3);
wp0 = y_f(40, 3);

z0_3q20_2 = [dpc0; ik0; s0; i0; y0; wp0] ;
%__________________without w shocks

D_2 = BHdpxf_decl([1 21 22 20 18 40],[11 1 2 3 8 13]);
w_2 = D_2^(-1) * (z_3q20 - z0_3q20_2) % calculated shocks to fit observables in 3q19

uf(11, 3) = w_2(1); % 
uf(1, 3) = w_2(2); % 
uf(2, 3) = w_2(3); % key rate shock
uf(3, 3) = w_2(4);
uf(8, 3) = w_2(5);
uf(13, 3) = w_2(6);
%__________________________________________________________________________

y_DR_f(:,3) = AHdpxf*y_DR_f(:,2) + BHdpxf*uf(:,3);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
%__________________________________________________________________________
%__________________________________________________________________________
% 
% %__________________________________________________________________________
% %______________________NO KSP (both inflation and output) 3q20_____________
% 
% z_3q20_1 = [ik_3q20; s_3q20; i_3q20];
% 
% uf_noKSP = uf;
% uf_noKSP([1 2 3 7 8 11],3) = [0; 0; 0; 0; 0; 0]; % Obnulenie of KSP shocks
% 
% y_DR_f_noKSP = y_DR_f;
% 
% y_DR_f_noKSP(:,3) = AHdpxf*y_DR_f_noKSP(:,2) + BHdpxf*uf_noKSP(:,3);
% y_f_noKSP = y_DR_f_noKSP(oo_Hdpxf_.dr.inv_order_var,:);
% 
% ik0 = y_f_noKSP(21, 3);
% s0 = y_f_noKSP(22, 3);
% i0 = y_f(20, 3);
% 
% z0_3q20_4 = [ik0; s0; i0];
% w_4 = BHdpxf_decl([21 22 20],[1 2 3])^(-1) * (z_3q20_1 - z0_3q20_4);
% uf_noKSP(1,3) = w_4(1);
% uf_noKSP(2,3) = w_4(2);
% uf_noKSP(3,3) = w_4(3);
% 
% y_DR_f_noKSP(:,3) = AHdpxf*y_DR_f_noKSP(:,2) + BHdpxf*uf_noKSP(:,3);
% y_f_noKSP = y_DR_f_noKSP(oo_Hdpxf_.dr.inv_order_var,:);

% %____________________ FITTING FOR 4q20_____________________________________
% %__________________________________________________________________________
% 
% z_4q20 = [dpc_4q20; ik_4q20; s_4q20; y_4q20];
% 
% %___________Shares of different shocks are set exogenously
% beta_share_4q20 = 0.5;
% nontrad_share_4q20 = 0.25;
% trad_share_4q20 = 1 - beta_share_4q20 - nontrad_share_4q20;
% 
% %__________________________________________________________________________
% %_________D_1 corresponds to eps_beta shock
% y_DR_f(:,4) = AHdpxf*y_DR_f(:,3) + BHdpxf*uf(:,4);
% y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
% %________D_1 corresponds to eps_yn
% 
% dpc0 = y_f(1, 4);
% ik0 = y_f(21, 4);
% s0 = y_f(22, 4);
% %i0 = y_f(20, 4);
% y0 = y_f(18, 4);
% z0_4q20_1 = [dpc0; ik0; s0; y0] ;
% 
% D_1 = BHdpxf_decl([1 21 22 18],[7 1 2 8]);
% w_1 = D_1^(-1) * (z_4q20 - z0_4q20_1) % calculated shocks to fit observables in 4q20
% 
% uf(7, 4) =  nontrad_share_4q20 / (1 - beta_share_4q20) * w_1(1); % sticky home supply shock 
% 
% %________D_2 corresponds to eps_yfh (flexible home goods supply shock)
% 
% y_DR_f(:,4) = AHdpxf*y_DR_f(:,3) + BHdpxf*uf(:,4);
% y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
% 
% dpc0 = y_f(1, 4);
% ik0 = y_f(21, 4);
% s0 = y_f(22, 4);
% % i0 = y_f(20, 4);
% y0 = y_f(18, 4);
% 
% z0_4q20_2 = [dpc0; ik0; s0; y0] ;
% %__________________without w shocks
% 
% D_2 = BHdpxf_decl([1 21 22 18],[11 1 2 8]);
% w_2 = D_2^(-1) * (z_4q20 - z0_4q20_2) % calculated shocks to fit observables in 3q19
% 
% uf(11, 4) = w_2(1); % 
% uf(1, 4) = w_2(2); % 
% uf(2, 4) = w_2(3); % key rate shock
% % uf(3, 4) = w_2(4);
% uf(8, 4) = w_2(4);
% %__________________________________________________________________________
% 
% y_DR_f(:,4) = AHdpxf*y_DR_f(:,3) + BHdpxf*uf(:,4);
% y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
% %__________________________________________________________________________
% %__________________________________________________________________________


% %____________________ FITTING FOR 4q20 (only dpc and ik)_________________
% %__________________________________________________________________________
% 
% z_4q20 = [dpc_4q20; ik_4q20];
% 
% beta_share_4q20 = 0.5;
% nontrad_share_4q20 = 0.25;
% % trad_share_4q20 = 1 - beta_share_1q20 - sticky_share_1q20;
% 
% %_________D_1 corresponds to eps_beta shock
% 
% y_DR_f(:,4) = AHdpxf*y_DR_f(:,3) + BHdpxf*uf(:,4);
% y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
% 
% dpc0 = y_f(1, 4);
% ik0 = y_f(21, 4);
% 
% z0_4q20_1 = [dpc0; ik0];
% D_1 = BHdpxf_decl([1 21],[8 1]);
% 
% w_5_1 = D_1^(-1) * (z_4q20 - z0_4q20_1);
% uf(8, 4) = beta_share_4q20 * w_5_1(1);
% 
% %________D_2 corresponds to eps_y (sticky home goods supply shock)
% 
% y_DR_f(:,4) = AHdpxf*y_DR_f(:,3) + BHdpxf*uf(:,4);
% y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
% 
% dpc0 = y_f(1, 4);
% ik0 = y_f(21, 4);
% 
% z0_4q20_2 = [dpc0; ik0];
% D_2 = BHdpxf_decl([1 21],[7 1]);
% 
% w_5_2 = D_2^(-1) * (z_4q20 - z0_4q20_2);
% uf(7, 4) = nontrad_share_4q20 / (1 - beta_share_4q20) * w_5_2(1);
% 
% %________D_3 corresponds to eps_yfh (flexible home goods supply shock)
% 
% y_DR_f(:,4) = AHdpxf*y_DR_f(:,3) + BHdpxf*uf(:,4);
% y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
% 
% dpc0 = y_f(1, 4);
% ik0 = y_f(21, 4);
% 
% z0_4q20_3 = [dpc0; ik0];
% D_3 = BHdpxf_decl([1 21],[11 1]);
% 
% w_5_3 = D_3^(-1) * (z_4q20 - z0_4q20_3);
% uf(11, 4) = w_5_3(1);
% uf(1, 4) = w_5_3(2);
% 
% y_DR_f(:,4) = AHdpxf*y_DR_f(:,3) + BHdpxf*uf(:,4);
% y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
% 

%____________________ FITTING FOR 4q20_____________________________________
%__________________________________________________________________________

z_4q20 = [dpc_4q20; ik_4q20; s_4q20; i_4q20; y_4q20; wp_4q20];

%___________Shares of different shocks are set exogenously
beta_share_4q20 = 0.5;
nontrad_share_4q20 = 0.25;
trad_share_4q20 = 1 - beta_share_4q20 - nontrad_share_4q20;

%__________________________________________________________________________
%_________D_1 corresponds to eps_beta shock
y_DR_f(:,4) = AHdpxf*y_DR_f(:,3) + BHdpxf*uf(:,4);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
%________D_1 corresponds to eps_yn

dpc0 = y_f(1, 4);
ik0 = y_f(21, 4);
s0 = y_f(22, 4);
i0 = y_f(20, 4);
y0 = y_f(18, 4);
wp0 = y_f(40, 4);
z0_4q20_1 = [dpc0; ik0; s0; i0; y0; wp0] ;

D_1 = BHdpxf_decl([1 21 22 20 18 40],[7 1 2 3 8 13]);
w_1 = D_1^(-1) * (z_4q20 - z0_4q20_1) % calculated shocks to fit observables in 4q20

uf(7,4) =  nontrad_share_4q20 / (1 - beta_share_4q20) * w_1(1); % sticky home supply shock 

%________D_2 corresponds to eps_yt (flexible home goods supply shock)

y_DR_f(:,4) = AHdpxf*y_DR_f(:,3) + BHdpxf*uf(:,4);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

dpc0 = y_f(1, 4);
ik0 = y_f(21, 4);
s0 = y_f(22, 4);
i0 = y_f(20, 4);
y0 = y_f(18, 4);
wp0 = y_f(40, 4);

z0_4q20_2 = [dpc0; ik0; s0; i0; y0; wp0] ;
%__________________without w shocks

D_2 = BHdpxf_decl([1 21 22 20 18 40],[11 1 2 3 8 13]);
w_2 = D_2^(-1) * (z_4q20 - z0_4q20_2) % calculated shocks to fit observables in 4q19

uf(11, 4) = w_2(1); % 
uf(1, 4) = w_2(2); % 
uf(2, 4) = w_2(3); % key rate shock
uf(3, 4) = w_2(4);
uf(8, 4) = w_2(5);
uf(13, 4) = w_2(6);
%__________________________________________________________________________

y_DR_f(:,4) = AHdpxf*y_DR_f(:,3) + BHdpxf*uf(:,4);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
%__________________________________________________________________________
%__________________________________________________________________________


%__________________________________________________________________________
%________NO KSP (inflatioin, output, wages, interst rate) 4q20_____________

z_4q20_1 = [ik_4q20; s_4q20];
uf_noKSP = uf;
uf_noKSP([1 2 3 7 8 11 13],4) = [0; 0; 0; 0; 0; 0; 0]; % Obnulenie of KSP shocks

y_DR_f_noKSP = y_DR_f;

y_DR_f_noKSP(:,4) = AHdpxf*y_DR_f_noKSP(:,3) + BHdpxf*uf_noKSP(:,4);
y_f_noKSP = y_DR_f_noKSP(oo_Hdpxf_.dr.inv_order_var,:);

ik0 = y_f_noKSP(21, 4);
s0 = y_f_noKSP(22, 4);

z0_4q20_4 = [ik0; s0];
w_6 = BHdpxf_decl([21 22],[1 2])^(-1) * (z_4q20_1 - z0_4q20_4);
uf_noKSP(1, 4) = w_6(1);
uf_noKSP(2, 4) = w_6(2);

y_DR_f_noKSP(:,4) = AHdpxf*y_DR_f_noKSP(:,3) + BHdpxf*uf_noKSP(:,4);
y_f_noKSP = y_DR_f_noKSP(oo_Hdpxf_.dr.inv_order_var,:);

%____________________ FITTING FOR 1q21_____________________________________
%__________________________________________________________________________

z_1q21 = [dpc_1q21; ik_1q21; y_1q21];

%___________Shares of different shocks are set exogenously
beta_share_1q21 = 0.5;
nontrad_share_1q21 = 0.25;
trad_share_1q21 = 1 - beta_share_1q21 - nontrad_share_1q21;

%__________________________________________________________________________
%_________D_1 corresponds to eps_beta shock
y_DR_f(:,5) = AHdpxf*y_DR_f(:,4) + BHdpxf*uf(:,5);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
%________D_1 corresponds to eps_yn

dpc0 = y_f(1, 5);
ik0 = y_f(21, 5);
% s0 = y_f(22, 5);
%i0 = y_f(20, 5);
y0 = y_f(18, 5);
z0_1q21_1 = [dpc0; ik0; y0];

D_1 = BHdpxf_decl([1 21 18],[7 1 8]);
w_1 = D_1^(-1) * (z_1q21 - z0_1q21_1) % calculated shocks to fit observables in 4q20

uf(7, 5) =  nontrad_share_1q21 / (1 - beta_share_1q21) * w_1(1); % sticky home supply shock 

%________D_2 corresponds to eps_yfh (flexible home goods supply shock)

y_DR_f(:,5) = AHdpxf*y_DR_f(:,4) + BHdpxf*uf(:,5);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

dpc0 = y_f(1, 5);
ik0 = y_f(21, 5);
% s0 = y_f(22, 5);
% i0 = y_f(20, 5);
y0 = y_f(18, 5);

z0_1q21_2 = [dpc0; ik0; y0] ;
%__________________without w shocks

D_2 = BHdpxf_decl([1 21 18],[11 1 8]);
w_2 = D_2^(-1) * (z_1q21 - z0_1q21_2) % calculated shocks to fit observables in 3q19

uf(11, 5) = w_2(1); % 
uf(1, 5) = w_2(2); % 
% uf(2, 5) = w_2(3); % key rate shock
% uf(3, 4) = w_2(4);
uf(8, 5) = w_2(3);
%__________________________________________________________________________

y_DR_f(:,5) = AHdpxf*y_DR_f(:,4) + BHdpxf*uf(:,5);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
%__________________________________________________________________________
%__________________________________________________________________________

%__________________________________________________________________________
%________NO KSP (inflatioin, output, wages, interst rate) 1q21_____________

z_1q21_1 = [ik_1q21];
% uf_noKSP = uf;
uf_noKSP([1 2 3 7 8 11 13],5) = [0; 0; 0; 0; 0; 0; 0]; % Obnulenie of KSP shocks

% y_DR_f_noKSP = y_DR_f;

y_DR_f_noKSP(:,5) = AHdpxf*y_DR_f_noKSP(:,4) + BHdpxf*uf_noKSP(:,5);
y_f_noKSP = y_DR_f_noKSP(oo_Hdpxf_.dr.inv_order_var,:);

ik0 = y_f_noKSP(21, 5);
% s0 = y_f_noKSP(22, 4);

z0_1q21_4 = [ik0];
w_6 = BHdpxf_decl([21],[1])^(-1) * (z_1q21_1 - z0_1q21_4);
uf_noKSP(1, 5) = w_6(1);
% uf_noKSP(2, 4) = w_6(2);

y_DR_f_noKSP(:,5) = AHdpxf*y_DR_f_noKSP(:,4) + BHdpxf*uf_noKSP(:,5);
y_f_noKSP = y_DR_f_noKSP(oo_Hdpxf_.dr.inv_order_var,:);

%__________________________________________________________________________
%__________________________________________________________________________

% %___________excersize_________ FITTING FOR 2q21 (only dpc)_______________
%__________________________________________________________________________

z_2q21 = [dpc_2q21];

beta_share_2q21 = 0.5;
nontrad_share_2q21 = 0.25;
% trad_share_4q20 = 1 - beta_share_1q20 - sticky_share_1q20;

%_________D_1 corresponds to eps_beta shock

y_DR_f(:,6) = AHdpxf*y_DR_f(:,5) + BHdpxf*uf(:,6);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

dpc0 = y_f(1, 6);
% ik0 = y_f(21, 4);

z0_2q21_1 = [dpc0];
D_1 = BHdpxf_decl([1],[8]);

w_5_1 = D_1^(-1) * (z_2q21 - z0_2q21_1);
uf(8, 6) = beta_share_2q21 * w_5_1(1);

%________D_2 corresponds to eps_y (sticky home goods supply shock)

y_DR_f(:,6) = AHdpxf*y_DR_f(:,5) + BHdpxf*uf(:,6);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

dpc0 = y_f(1, 6);
% ik0 = y_f(21, 6);

z0_2q21_2 = [dpc0];
D_2 = BHdpxf_decl([1],[7]);

w_5_2 = D_2^(-1) * (z_2q21 - z0_2q21_2);
uf(7, 6) = nontrad_share_2q21 / (1 - beta_share_2q21) * w_5_2(1);

%________D_3 corresponds to eps_yfh (flexible home goods supply shock)

y_DR_f(:,6) = AHdpxf*y_DR_f(:,5) + BHdpxf*uf(:,6);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);

dpc0 = y_f(1, 6);
% ik0 = y_f(21, 4);

z0_2q21_3 = [dpc0];
D_3 = BHdpxf_decl([1],[11]);

w_5_3 = D_3^(-1) * (z_2q21 - z0_2q21_3);
uf(11, 6) = w_5_3(1);
% uf(1, 4) = w_5_3(2);

y_DR_f(:,6) = AHdpxf*y_DR_f(:,5) + BHdpxf*uf(:,6);
y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
%__________________________________________________________________________


%_______________SO we have revealed structural shocks + set eps_ik which fit observable, expert evaluated and short term forecasted variables_______________________   
% 
% uf(12,1) = dG_YoY1q20;
% uf(12,2) = dG_YoY2q20 - rho_g * dG_YoY1q20; 
% uf(12,3) = dG_YoY3q20 - rho_g * dG_YoY2q20;
% uf(25,3) = dG_YoY4q20 - rho_g * dG_YoY3q20;

%__________________Setting structual shocks
uf_bl = uf;
uf_noepsik = uf;
uf_loose = uf;
uf_tight = uf;

uf_noepsik(1,5:Nforc) = zeros(1,Nforc-4); 
uf_loose(1,5) = uf(1,5) - 0.005 /4 /  BHdpxf_decl(21,1); % Tight monetary policy = + 0.25% 
uf_tight(1,5) = uf(1,5) + 0.005 /4 /  BHdpxf_decl(21,1); % Tight monetary policy = + 0.25%

% _______________________________________________________________FORECASTING FOR ALL PERIODS and ALL Scenarios ______________________%

y_DR_f_bl = nan(M_.endo_nbr,Nforc);
y_f_bl = nan(M_.endo_nbr,Nforc);
y_DR_f_noepsik = nan(M_.endo_nbr,Nforc);
y_f_noepsik = nan(M_.endo_nbr,Nforc);
y_DR_f_loose = nan(M_.endo_nbr,Nforc);
y_f_loose = nan(M_.endo_nbr,Nforc);
y_DR_f_tight = nan(M_.endo_nbr,Nforc);
y_f_tight = nan(M_.endo_nbr,Nforc);
y_DR_f_noKSP = nan(M_.endo_nbr,Nforc);
y_f_noKSP = nan(M_.endo_nbr,Nforc);

% y_DR_f_bl(:,1) = y_DR_sq(:,Nsignif);
% y_DR_f_noepsik(:,1) = y_DR(:,Nper);
% y_DR_f_loose(:,1) = y_DR(:,Nper);
% y_DR_f_tight(:,1) = y_DR(:,Nper);

%______________________Changing matrices for high dpx (Hdpx)_______________

y_DR_f(:,1) = AHdpxf * y_DR_sq(:,Nsignif) + BHdpxf * uf(:,1);
y_DR_f_bl(:,1) = AHdpxf * y_DR_sq(:,Nsignif) + BHdpxf * uf_bl(:,1);
y_DR_f_noepsik(:,1) = AHdpxf * y_DR_sq(:,Nsignif) + BHdpxf * uf_noepsik(:,1);
y_DR_f_loose(:,1) = AHdpxf * y_DR_sq(:,Nsignif) + BHdpxf * uf_loose(:,1);
y_DR_f_tight(:,1) = AHdpxf * y_DR_sq(:,Nsignif) + BHdpxf * uf_tight(:,1);
y_DR_f_noKSP(:,1) = AHdpxf * y_DR_sq(:,Nsignif) + BHdpxf * uf_noKSP(:,1);

    
for j = 2:Nforc
    
    y_DR_f(:,j) = AHdpxf * y_DR_f(:,j-1) + BHdpxf * uf(:,j);
    y_DR_f_bl(:,j) = AHdpxf * y_DR_f_bl(:,j-1) + BHdpxf * uf_bl(:,j);
    y_DR_f_noepsik(:,j) = AHdpxf * y_DR_f_noepsik(:,j-1) + BHdpxf * uf_noepsik(:,j);
    y_DR_f_loose(:,j) = AHdpxf * y_DR_f_loose(:,j-1) + BHdpxf * uf_loose(:,j);
    y_DR_f_tight(:,j) = AHdpxf * y_DR_f_tight(:,j-1) + BHdpxf * uf_tight(:,j);
    y_DR_f_noKSP(:,j) = AHdpxf * y_DR_f_noKSP(:,j-1) + BHdpxf * uf_noKSP(:,j);
    
end

y_f = y_DR_f(oo_Hdpxf_.dr.inv_order_var,:);
y_f_bl = y_DR_f_bl(oo_Hdpxf_.dr.inv_order_var,:);
y_f_noepsik = y_DR_f_noepsik(oo_Hdpxf_.dr.inv_order_var,:);
y_f_loose = y_DR_f_loose(oo_Hdpxf_.dr.inv_order_var,:);
y_f_tight = y_DR_f_tight(oo_Hdpxf_.dr.inv_order_var,:);
y_f_noKSP = y_DR_f_noKSP(oo_Hdpxf_.dr.inv_order_var,:);


%________________________________________________________________________YOY INFLATION RESTORING_______________________%

dpc_bc = [y(1,:)' ; y_f(1,1:Nforc)'];  % business-cycle component of inflation (actual + forecasted)
dpc_bc_bl = [y(1,:)' ; y_f_bl(1,1:Nforc)']; 
dpc_bc_noepsik = [y(1,:)' ; y_f_noepsik(1,1:Nforc)'] ;
dpc_bc_loose = [y(1,:)' ; y_f_loose(1,1:Nforc)'] ;
dpc_bc_tight = [y(1,:)' ; y_f_tight(1,1:Nforc)'] ;
dpc_bc_noKSP = [y(1,:)' ; y_f_noKSP(1,1:Nforc)'] ;
% 
% dp_tr = [dp_VV_tr(21:21 + Nper-1); 0.01*ones(Nforc-1,1)];
% dp_s_YoY = [oo_Detr2.SmoothedShocks.u_VV_S(21:Ndetr) * (1 - 0.37456 - 0.35234); zeros(Nforc-1, 1)]; 
% 


dp_YoY = nan(Nper+Nforc, 1) ;
dp_YoY_bl = nan(Nper+Nforc, 1) ;
dp_YoY_noepsik = nan(Nper+Nforc, 1) ;
dp_YoY_loose = nan(Nper+Nforc, 1) ;
dp_YoY_tight = nan(Nper+Nforc, 1) ;
dp_YoY_noKSP = nan(Nper+Nforc, 1) ;

% for j=4:Nper+Nforc-1
%     dp_YoY(j) = ((1 + dp_bc(j) + dp_tr(j)) * (1 + dp_bc(j-1) + dp_tr(j-1)) * (1 + dp_bc(j-2) + dp_tr(j-2)) * (1 + dp_bc(j-3) + dp_tr(j-3))) * (1 + dp_s_YoY(j)) - 1 ;
%     dp_YoY_bl(j) = ((1 + dp_bc_bl(j) + dp_tr(j)) * (1 + dp_bc_bl(j-1) + dp_tr(j-1)) * (1 + dp_bc_bl(j-2) + dp_tr(j-2)) * (1 + dp_bc_bl(j-3) + dp_tr(j-3))) * (1 + dp_s_YoY(j)) - 1 ;
%     dp_YoY_noepsik(j) = ((1 + dp_bc_noepsik(j) + dp_tr(j)) * (1 + dp_bc_noepsik(j-1) + dp_tr(j-1)) * (1 + dp_bc_noepsik(j-2) + dp_tr(j-2)) * (1 + dp_bc_noepsik(j-3) + dp_tr(j-3))) * (1 + dp_s_YoY(j)) - 1 ;
%     dp_YoY_loose(j) = ((1 + dp_bc_loose(j) + dp_tr(j)) * (1 + dp_bc_loose(j-1) + dp_tr(j-1)) * (1 + dp_bc_loose(j-2) + dp_tr(j-2)) * (1 + dp_bc_loose(j-3) + dp_tr(j-3))) * (1 + dp_s_YoY(j)) - 1 ;
%     dp_YoY_tight(j) = ((1 + dp_bc_tight(j) + dp_tr(j)) * (1 + dp_bc_tight(j-1) + dp_tr(j-1)) * (1 + dp_bc_tight(j-2) + dp_tr(j-2)) * (1 + dp_bc_tight(j-3) + dp_tr(j-3))) * (1 + dp_s_YoY(j)) - 1 ;
%     
% end

for j=1:Nper
    dp_YoY(j) = exp(dpc(Ndetr-Nper+j) + dpc(Ndetr-Nper+j-1) + dpc(Ndetr-Nper+j-2) + dpc(Ndetr-Nper+j-3))-1;
    dp_YoY_bl(j) = exp(dpc(Ndetr-Nper+j) + dpc(Ndetr-Nper+j-1) + dpc(Ndetr-Nper+j-2) + dpc(Ndetr-Nper+j-3))-1;
    dp_YoY_noepsik(j) = exp(dpc(Ndetr-Nper+j) + dpc(Ndetr-Nper+j-1) + dpc(Ndetr-Nper+j-2) + dpc(Ndetr-Nper+j-3))-1;
    dp_YoY_loose(j) = exp(dpc(Ndetr-Nper+j) + dpc(Ndetr-Nper+j-1) + dpc(Ndetr-Nper+j-2) + dpc(Ndetr-Nper+j-3))-1;
    dp_YoY_tight(j) = exp(dpc(Ndetr-Nper+j) + dpc(Ndetr-Nper+j-1) + dpc(Ndetr-Nper+j-2) + dpc(Ndetr-Nper+j-3))-1;
    dp_YoY_noKSP(j) = exp(dpc(Ndetr-Nper+j) + dpc(Ndetr-Nper+j-1) + dpc(Ndetr-Nper+j-2) + dpc(Ndetr-Nper+j-3))-1;
    
end


dp_YoY(Nper+1) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc(Ndetr-2) + dpc_bc(Nper+1) + dpc_tr + dpc_s_1q20)-1;
dp_YoY_bl(Nper+1) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc(Ndetr-2) + dpc_bc_bl(Nper+1) + dpc_tr + dpc_s_1q20)-1;
dp_YoY_noepsik(Nper+1) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc(Ndetr-2) + dpc_bc_noepsik(Nper+1) + dpc_tr + dpc_s_1q20)-1;
dp_YoY_loose(Nper+1) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc(Ndetr-2) + dpc_bc_loose(Nper+1) + dpc_tr + dpc_s_1q20)-1;
dp_YoY_tight(Nper+1) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc(Ndetr-2) + dpc_bc_tight(Nper+1) + dpc_tr + dpc_s_1q20)-1;
dp_YoY_noKSP(Nper+1) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc(Ndetr-2) + dpc_bc_noKSP(Nper+1) + dpc_tr + dpc_s_1q20)-1;

dp_YoY(Nper+2) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc_bc(Nper+1) + dpc_bc(Nper+2) + 2 * dpc_tr + dpc_s_1q20 + dpc_s_2q20)-1;
dp_YoY_bl(Nper+2) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc_bc_bl(Nper+1) + dpc_bc_bl(Nper+2) + 2 * dpc_tr + dpc_s_1q20 + dpc_s_2q20)-1;
dp_YoY_noepsik(Nper+2) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc_bc_noepsik(Nper+1) + dpc_bc_noepsik(Nper+2) + 2 * dpc_tr + dpc_s_1q20 + dpc_s_2q20)-1;
dp_YoY_loose(Nper+2) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc_bc_loose(Nper+1) + dpc_bc_loose(Nper+2) + 2 * dpc_tr + dpc_s_1q20 + dpc_s_2q20)-1;
dp_YoY_tight(Nper+2) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc_bc_tight(Nper+1) + dpc_bc_tight(Nper+2) + 2 * dpc_tr + dpc_s_1q20 + dpc_s_2q20)-1;
dp_YoY_noKSP(Nper+2) = exp(dpc(Ndetr) + dpc(Ndetr-1) + dpc_bc_noKSP(Nper+1) + dpc_bc_noKSP(Nper+2) + 2 * dpc_tr + dpc_s_1q20 + dpc_s_2q20)-1;

dp_YoY(Nper+3) = exp(dpc(Ndetr) + dpc_bc(Nper+1) + dpc_bc(Nper+2) + dpc_bc(Nper+3) + 3 * dpc_tr + dpc_s_1q20 + dpc_s_2q20 + dpc_s_3q20)-1;
dp_YoY_bl(Nper+3) = exp(dpc(Ndetr) + dpc_bc_bl(Nper+1) + dpc_bc_bl(Nper+2) + dpc_bc_bl(Nper+3) + 3 * dpc_tr + dpc_s_1q20 + dpc_s_2q20 + dpc_s_3q20)-1;
dp_YoY_noepsik(Nper+3) = exp(dpc(Ndetr) + dpc_bc_noepsik(Nper+1) + dpc_bc_noepsik(Nper+2) + dpc_bc_noepsik(Nper+3) + 3 * dpc_tr + dpc_s_1q20 + dpc_s_2q20 + dpc_s_3q20)-1;
dp_YoY_loose(Nper+3) = exp(dpc(Ndetr) + dpc_bc_loose(Nper+1) + dpc_bc_loose(Nper+2) + dpc_bc_loose(Nper+3) + 3 * dpc_tr + dpc_s_1q20 + dpc_s_2q20 + dpc_s_3q20)-1;
dp_YoY_tight(Nper+3) = exp(dpc(Ndetr) + dpc_bc_tight(Nper+1) + dpc_bc_tight(Nper+2) + dpc_bc_tight(Nper+3) + 3 * dpc_tr + dpc_s_1q20 + dpc_s_2q20 + dpc_s_3q20)-1;
dp_YoY_noKSP(Nper+3) = exp(dpc(Ndetr) + dpc_bc_noKSP(Nper+1) + dpc_bc_noKSP(Nper+2) + dpc_bc_noKSP(Nper+3) + 3 * dpc_tr + dpc_s_1q20 + dpc_s_2q20 + dpc_s_3q20)-1;

for j=Nper+4:Nper+Nforc
    dp_YoY(j) = exp(dpc_bc(j)  + dpc_bc(j-1) + dpc_bc(j-2)  + dpc_bc(j-3) + 4 * dpc_tr + sum(dpc_s_f(j - Nper-3:j - Nper))) - 1;
    dp_YoY_bl(j) = exp(dpc_bc_bl(j) + dpc_bc_bl(j-1) + dpc_bc_bl(j-2) + dpc_bc_bl(j-3) + 4 * dpc_tr + sum(dpc_s_f(j - Nper-3:j - Nper))) - 1;
    dp_YoY_noepsik(j) = exp(dpc_bc_noepsik(j) + dpc_bc_noepsik(j-1)  + dpc_bc_noepsik(j-2) + dpc_bc_noepsik(j-3) + 4 * dpc_tr + sum(dpc_s_f(j - Nper-3:j - Nper))) - 1;
    dp_YoY_loose(j) = exp(dpc_bc_loose(j) + dpc_bc_loose(j-1) + dpc_bc_loose(j-2) + dpc_bc_loose(j-3) + 4 * dpc_tr + sum(dpc_s_f(j - Nper-3:j - Nper))) - 1;
    dp_YoY_tight(j) = exp(dpc_bc_tight(j) + dpc_bc_tight(j-1) + dpc_bc_tight(j-2) + dpc_bc_tight(j-3) + 4 * dpc_tr + sum(dpc_s_f(j - Nper-3:j - Nper))) - 1;
    dp_YoY_noKSP(j) = exp(dpc_bc_noKSP(j) + dpc_bc_noKSP(j-1) + dpc_bc_noKSP(j-2) + dpc_bc_noKSP(j-3) + 4 * dpc_tr + sum(dpc_s_f(j - Nper-3:j - Nper))) - 1;
end


[dp_YoY_bl(Nper+1:Nper+Nforc)*100 y_f(19,1:Nforc)'*400+ik_Neutral*400];



%________________________________________________________________________YOY OUTPUT RESTORING_______________________%

y_bc = [y(18,:)' ; y_f(18,1:Nforc)'];  % business-cycle component of inflation (actual + forecasted)
y_bc_bl = [y(18,:)' ; y_f_bl(18,1:Nforc)']; 
y_bc_noepsik = [y(18,:)' ; y_f_noepsik(18,1:Nforc)'] ;
y_bc_loose = [y(18,:)' ; y_f_loose(18,1:Nforc)'] ;
y_bc_tight = [y(18,:)' ; y_f_tight(18,1:Nforc)'] ;
y_bc_noKSP = [y(18,:)' ; y_f_noKSP(18,1:Nforc)'] ;

dy_YoY = nan(Nper+Nforc, 1) ;
dy_YoY_bl = nan(Nper+Nforc, 1) ;
dy_YoY_noepsik = nan(Nper+Nforc, 1) ;
dy_YoY_loose = nan(Nper+Nforc, 1) ;
dy_YoY_tight = nan(Nper+Nforc, 1) ;
dy_YoY_noKSP = nan(Nper+Nforc, 1) ;

a1 = M_Detr5.params(14); % Estimated on historical data growth rate 

for j=5:Nper
    dy_YoY(j) = exp(y_bc(j) - y_bc(j-4) + a1 * 4) - 1 ;
    dy_YoY_bl(j) = exp(y_bc_bl(j) - y_bc_bl(j-4) + a1 * 4) - 1;
    dy_YoY_noepsik(j) = exp(y_bc_noepsik(j) - y_bc_noepsik(j-4) + a1 * 4) - 1;
    dy_YoY_loose(j) = exp(y_bc_loose(j) - y_bc_loose(j-4) + a1 * 4) - 1;
    dy_YoY_tight(j) = exp(y_bc_tight(j) - y_bc_tight(j-4) + a1 * 4) - 1;    
    dy_YoY_noKSP(j) = exp(y_bc_noKSP(j) - y_bc_noKSP(j-4) + a1 * 4) - 1;   
end

dy_YoY(Nper+1) = exp(y_bc(Nper+1) - y_bc(Nper-3) + a1 * 3 + dy_tr) - 1 ;
dy_YoY_bl(Nper+1) = exp(y_bc_bl(Nper+1) - y_bc_bl(Nper-3) + a1 * 3 + dy_tr) - 1 ;
dy_YoY_noepsik(Nper+1) = exp(y_bc_noepsik(Nper+1) - y_bc_noepsik(Nper-3) + a1 * 3 + dy_tr) - 1 ;
dy_YoY_loose(Nper+1) = exp(y_bc_loose(Nper+1) - y_bc_loose(Nper-3) + a1 * 3 + dy_tr) - 1 ;
dy_YoY_tight(Nper+1) = exp(y_bc_tight(Nper+1) - y_bc_tight(Nper-3) + a1 * 3 + dy_tr) - 1 ;
dy_YoY_noKSP(Nper+1) = exp(y_bc_noKSP(Nper+1) - y_bc_noKSP(Nper-3) + a1 * 3 + dy_tr) - 1 ;

dy_YoY(Nper+2) = exp(y_bc(Nper+2) - y_bc(Nper-2) + a1 * 2 + dy_tr * 2) - 1 ;
dy_YoY_bl(Nper+2) = exp(y_bc_bl(Nper+2) - y_bc_bl(Nper-2) + a1 * 2 + dy_tr * 2) - 1 ;
dy_YoY_noepsik(Nper+2) = exp(y_bc_noepsik(Nper+2) - y_bc_noepsik(Nper-2) + a1 * 2 + dy_tr * 2) - 1 ;
dy_YoY_loose(Nper+2) = exp(y_bc_loose(Nper+2) - y_bc_loose(Nper-2) + a1 * 2 + dy_tr * 2) - 1 ;
dy_YoY_tight(Nper+2) = exp(y_bc_tight(Nper+2) - y_bc_tight(Nper-2) + a1 * 2 + dy_tr * 2) - 1 ;
dy_YoY_noKSP(Nper+2) = exp(y_bc_noKSP(Nper+2) - y_bc_noKSP(Nper-2) + a1 * 2 + dy_tr * 2) - 1 ;

a1 = dy_tr; % New (exogenously set growth rate)
for j=Nper+3:Nper+Nforc
    dy_YoY(j) = exp(y_bc(j) - y_bc(j-4) + a1 * 4) - 1 ;
    dy_YoY_bl(j) = exp(y_bc_bl(j) - y_bc_bl(j-4) + a1 * 4) - 1;
    dy_YoY_noepsik(j) = exp(y_bc_noepsik(j) - y_bc_noepsik(j-4) + a1 * 4) - 1;
    dy_YoY_loose(j) = exp(y_bc_loose(j) - y_bc_loose(j-4) + a1 * 4) - 1;
    dy_YoY_tight(j) = exp(y_bc_tight(j) - y_bc_tight(j-4) + a1 * 4) - 1;
    dy_YoY_noKSP(j) = exp(y_bc_noKSP(j) - y_bc_noKSP(j-4) + a1 * 4) - 1;
    
end

%_________________Adjustment on trend shift in 2q2020

dy_YoY = exp(log(dy_YoY + 1) + [zeros(Nper+1,1); -0.02 * ones(4,1); zeros(Nforc-5,1)]) - 1;
dy_YoY_bl = exp(log(dy_YoY_bl + 1) + [zeros(Nper+1,1); -0.02 * ones(4,1); zeros(Nforc-5,1)]) - 1;
dy_YoY_noepsik = exp(log(dy_YoY_noepsik + 1) + [zeros(Nper+1,1); -0.02 * ones(4,1); zeros(Nforc-5,1)]) - 1;
dy_YoY_loose = exp(log(dy_YoY_loose + 1) + [zeros(Nper+1,1); -0.02 * ones(4,1); zeros(Nforc-5,1)]) - 1;
dy_YoY_tight = exp(log(dy_YoY_tight + 1) + [zeros(Nper+1,1); -0.02 * ones(4,1); zeros(Nforc-5,1)]) - 1;
dy_YoY_noKSP = exp(log(dy_YoY_noKSP + 1) + [zeros(Nper+1,1); -0.02 * ones(4,1); zeros(Nforc-5,1)]) - 1;

%________________________________________________________________________YOY WAGE RESTORING_______________________%

w_bc = [y(40,:)' ; y_f(40,1:Nforc)'];  % business-cycle component of inflation (actual + forecasted)
w_bc_bl = [y(40,:)' ; y_f_bl(40,1:Nforc)']; 
w_bc_noepsik = [y(40,:)' ; y_f_noepsik(40,1:Nforc)'] ;
w_bc_loose = [y(40,:)' ; y_f_loose(40,1:Nforc)'] ;
w_bc_tight = [y(40,:)' ; y_f_tight(40,1:Nforc)'] ;
w_bc_noKSP = [y(40,:)' ; y_f_noKSP(40,1:Nforc)'] ;

dw_YoY = nan(Nper+Nforc, 1) ;
dw_YoY_bl = nan(Nper+Nforc, 1) ;
dw_YoY_noepsik = nan(Nper+Nforc, 1) ;
dw_YoY_loose = nan(Nper+Nforc, 1) ;
dw_YoY_tight = nan(Nper+Nforc, 1) ;
dw_YoY_noKSP = nan(Nper+Nforc, 1) ;

a1_w = M_Detr5.params(16); % Estimated on historical data growth rate 

for j=5:Nper
    dw_YoY(j) = exp(w_bc(j) - w_bc(j-4) + a1_w * 4) - 1 ;
    dw_YoY_bl(j) = exp(w_bc_bl(j) - w_bc_bl(j-4) + a1_w * 4) - 1;
    dw_YoY_noepsik(j) = exp(w_bc_noepsik(j) - w_bc_noepsik(j-4) + a1_w * 4) - 1;
    dw_YoY_loose(j) = exp(w_bc_loose(j) - w_bc_loose(j-4) + a1_w * 4) - 1;
    dw_YoY_tight(j) = exp(w_bc_tight(j) - w_bc_tight(j-4) + a1_w * 4) - 1;    
    dw_YoY_noKSP(j) = exp(w_bc_noKSP(j) - w_bc_noKSP(j-4) + a1_w * 4) - 1;   
end

dw_YoY(Nper+1) = exp(w_bc(Nper+1) - w_bc(Nper-3) + a1_w * 3 + dwp_tr) - 1 ;
dw_YoY_bl(Nper+1) = exp(w_bc_bl(Nper+1) - w_bc_bl(Nper-3) + a1_w * 3 + dwp_tr) - 1 ;
dw_YoY_noepsik(Nper+1) = exp(w_bc_noepsik(Nper+1) - w_bc_noepsik(Nper-3) + a1_w * 3 + dwp_tr) - 1 ;
dw_YoY_loose(Nper+1) = exp(w_bc_loose(Nper+1) - w_bc_loose(Nper-3) + a1_w * 3 + dwp_tr) - 1 ;
dw_YoY_tight(Nper+1) = exp(w_bc_tight(Nper+1) - w_bc_tight(Nper-3) + a1_w * 3 + dwp_tr) - 1 ;
dw_YoY_noKSP(Nper+1) = exp(w_bc_noKSP(Nper+1) - w_bc_noKSP(Nper-3) + a1_w * 3 + dwp_tr) - 1 ;

dw_YoY(Nper+2) = exp(w_bc(Nper+2) - w_bc(Nper-2) + a1_w * 2 + dwp_tr * 2) - 1 ;
dw_YoY_bl(Nper+2) = exp(w_bc_bl(Nper+2) - w_bc_bl(Nper-2) + a1_w * 2 + dwp_tr * 2) - 1 ;
dw_YoY_noepsik(Nper+2) = exp(w_bc_noepsik(Nper+2) - w_bc_noepsik(Nper-2) + a1_w * 2 + dwp_tr * 2) - 1 ;
dw_YoY_loose(Nper+2) = exp(w_bc_loose(Nper+2) - w_bc_loose(Nper-2) + a1_w * 2 + dwp_tr * 2) - 1 ;
dw_YoY_tight(Nper+2) = exp(w_bc_tight(Nper+2) - w_bc_tight(Nper-2) + a1_w * 2 + dwp_tr * 2) - 1 ;
dw_YoY_noKSP(Nper+2) = exp(w_bc_noKSP(Nper+2) - w_bc_noKSP(Nper-2) + a1_w * 2 + dwp_tr * 2) - 1 ;

a1_w = dwp_tr; % New (exogenously set growth rate)
for j=Nper+3:Nper+Nforc
    dw_YoY(j) = exp(w_bc(j) - w_bc(j-4) + a1_w * 4) - 1 ;
    dw_YoY_bl(j) = exp(w_bc_bl(j) - w_bc_bl(j-4) + a1_w * 4) - 1;
    dw_YoY_noepsik(j) = exp(w_bc_noepsik(j) - w_bc_noepsik(j-4) + a1_w * 4) - 1;
    dw_YoY_loose(j) = exp(w_bc_loose(j) - w_bc_loose(j-4) + a1_w * 4) - 1;
    dw_YoY_tight(j) = exp(w_bc_tight(j) - w_bc_tight(j-4) + a1_w * 4) - 1;
    dw_YoY_noKSP(j) = exp(w_bc_noKSP(j) - w_bc_noKSP(j-4) + a1_w * 4) - 1;
    
end


s_bc = [y(22,:)' ; y_f(22,1:Nforc)'];
s_bc_bl = [y(22,:)' ; y_f_bl(22,1:Nforc)'];
s_bc_noepsik = [y(22,:)' ; y_f_noepsik(22,1:Nforc)'];
s_bc_loose = [y(22,:)' ; y_f_loose(22,1:Nforc)'];
s_bc_tight = [y(22,:)' ; y_f_tight(22,1:Nforc)'];

a1_s_f = 0.01-oo_Detr5.posterior_mode.parameters.a1_pstar;
a1_s = M_Detr5.params(13);
% S_actUSD_2q19 = 64.52;
% S_tr = [exp(oo_Detr5.SmoothedVariables.s_tr(Ndetr) * ones(Nper,1)) .* exp(a1_s * [1:Nper]')/exp(a1_s * (Nper)); exp(oo_Detr5.SmoothedVariables.s_tr(Ndetr) * ones(Nforc,1)) .* exp(a1_s_f * [1:Nforc]')];
S_tr = [S_actUSD_4q19 * exp(-s_bc(Nper)) * ones(Nper,1) .* exp(a1_s * [0:Nper-1]')/exp(a1_s * (Nper-1)); S_actUSD_4q19 * exp(-s_bc(Nper)) * ones(Nforc,1) .* exp(a1_s_f * [1:Nforc]')];

S = S_tr .* exp(s_bc);
S_bl = S_tr .* exp(s_bc_bl);
S_noepsik = S_tr .* exp(s_bc_noepsik);
S_loose = S_tr .* exp(s_bc_loose);
S_tight = S_tr .* exp(s_bc_tight);


X_dy_YoY = [dy_YoY_bl(Nper-Nsignif+1:Nper+FH) dy_YoY_tight(Nper-Nsignif+1:Nper+FH) dy_YoY_loose(Nper-Nsignif+1:Nper+FH)];
X_y = [y_bc_bl(Nper-Nsignif+1:Nper+FH) y_bc_tight(Nper-Nsignif+1:Nper+FH) y_bc_loose(Nper-Nsignif+1:Nper+FH)];
X_dw_YoY = [dw_YoY_bl(Nper-Nsignif+1:Nper+FH) dw_YoY_tight(Nper-Nsignif+1:Nper+FH) dw_YoY_loose(Nper-Nsignif+1:Nper+FH)];
X_w = [w_bc_bl(Nper-Nsignif+1:Nper+FH) w_bc_tight(Nper-Nsignif+1:Nper+FH) w_bc_loose(Nper-Nsignif+1:Nper+FH)];
X_ik = [[y(21,Nper-Nsignif+1:Nper)'*400+6; y_f_bl(21,1:FH)'*400+ik_Neutral*400] [y(21,Nper-Nsignif+1:Nper)'*400+6; y_f_tight(21,1:FH)'*400+ik_Neutral*400] [y(21,Nper-Nsignif+1:Nper)'*400+6; y_f_loose(21,1:FH)'*400+ik_Neutral*400]];
X_dp_YoY = [dp_YoY_bl(Nper-Nsignif+1:Nper+FH) dp_YoY_tight(Nper-Nsignif+1:Nper+FH) dp_YoY_loose(Nper-Nsignif+1:Nper+FH)];
X_S = [S_bl(Nper-Nsignif+1:Nper+FH) S_tight(Nper-Nsignif+1:Nper+FH) S_loose(Nper-Nsignif+1:Nper+FH)];


OPR_info = [X_dp_YoY X_ik X_y X_dy_YoY X_S S_tr(Nper-Nsignif+1:Nper+FH) [nan(Nsignif,1); y_f_noepsik(21,1:FH)'*400 + ik_Neutral*400]  [y(1,Nper-Nsignif+1:Nper)' ; y_f_bl(1,1:FH)']*4 + 0.04 [y(1,Nper-Nsignif+1:Nper)' ; y_f_tight(1,1:FH)']*4 + 0.04 [y(1,Nper-Nsignif+1:Nper)' ; y_f_loose(1,1:FH)']*4 + 0.04 [y(1,Nper-Nsignif+1:Nper)' ; y_f_noKSP(1,1:FH)']*4 + 0.04 [exp(y(36,Nper-Nsignif+1:Nper)') * 60 ; exp(y_f_bl(36,1:FH)') * PX_Long] dp_YoY_noepsik(Nper-Nsignif+1:Nper+FH) X_w X_dw_YoY];

OUTPUT_CORE5.y = y;
OUTPUT_CORE5.y_f = y_f;
OUTPUT_CORE5.y_f_bl = y_f_bl;
OUTPUT_CORE5.y_sq = y_sq;
OUTPUT_CORE5.y_f_noepsik = y_f_noepsik;
OUTPUT_CORE5.y_f_loose = y_f_loose;
OUTPUT_CORE5.y_f_tight = y_f_tight;
OUTPUT_CORE5.y_f_noKSP = y_f_noKSP;
OUTPUT_CORE5.dp_YoY = dp_YoY;
OUTPUT_CORE5.dp_YoY_bl = dp_YoY_bl;
OUTPUT_CORE5.dp_YoY_noepsik = dp_YoY_noepsik;
OUTPUT_CORE5.dp_YoY_loose = dp_YoY_loose;
OUTPUT_CORE5.dp_YoY_tight = dp_YoY_tight;
OUTPUT_CORE5.dp_YoY_noKSP = dp_YoY_noKSP;
OUTPUT_CORE5.dy_YoY_bl = dy_YoY_bl;
OUTPUT_CORE5.dy_YoY_loose = dy_YoY_loose;
OUTPUT_CORE5.dy_YoY_tight = dy_YoY_tight;
OUTPUT_CORE5.dy_YoY_noKSP = dy_YoY_noKSP;
OUTPUT_CORE5.Nper = Nper;
OUTPUT_CORE5.X_dp_YoY = X_dp_YoY;
OUTPUT_CORE5.X_dy_YoY =X_dy_YoY;
OUTPUT_CORE5.X_y = X_y;
OUTPUT_CORE5.X_ik = X_ik;
OUTPUT_CORE5.X_S = X_S;
OUTPUT_CORE5.S_tr = S_tr;
OUTPUT_CORE5.uf = uf;
OUTPUT_CORE5.uf_noKSP = uf_noKSP;
OUTPUT_CORE5.u = u;
OUTPUT_CORE5.Nper = Nper;
OUTPUT_CORE5.OPR_info = OPR_info;



end
