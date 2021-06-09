%___________________Forecasting for VKS XX.06.2020 (OPR 04)_________________________________________

%__________________________________INPUT_____________________________________________________________
clc
clear all

Nforc = 100; % Forecast horizon in matrices
FH = 22; % Forecast horizon in the graph
Nsignif = 24; % NOT More than Nper = 22 in 03.12.2019
% Nper_CORE = 19; % To calculate something for Core2

% PX_3q19 = 62.26; % Quandl avg 3q19
% PX_4q19 = 63.01; % Quandl avg 4q19

%_______________LAST SCENARIOS of OPR02____________________________________
% PX_1q20 = 53.6; % avg till 04.03.2020 + New MainFlat scenario
% PX_q1E2q20 = 50;
% PX_2q20 = 35; % Scenario 7535
% PX_2q20 = 40; % Scenario Main
% PX_q2E3q20 = 35;
%__________________________________________________________________________
%_______________SCENARIOS OF OPR03_________________________________________

% PX_1q20 = 51.38; % Quandl avg 1q20
% PX_q1E2q20 = 48; % Estimation of expectations (lower than avg price because of downward trend)
% PX_2q20 = 26.80; % 
% PX_3q20 = 36.5;

% PX_1q20 = 57.22; % avg till 04.03.2020 + New Stress scenario

%______________________OPR06_______________________________________________
% PX_1q20 = 51.38; % Quandl avg 1q20
% PX_q1E2q20 = 48; % Estimation of expectations (lower than avg price because of downward trend)
% PX_2q20 = 26.82; % 
% PX_3q20 = 44;
% PX_4q20 = 44;
% 
% PX_Long = 60;   % Long term oil price in forecast

% %______________________OPR07_______________________________________________
% PX_1q20 = 51.38; % Quandl avg 1q20
% PX_q1E2q20 = 48; % Estimation of expectations (lower than avg price because of downward trend)
% PX_2q20 = 26.82; % 
% PX_3q20 = 43.36;
% PX_4q20 = 42;

%______________________OPR08_______________________________________________
PX_1q20 = 51.38; % Quandl avg 1q20
PX_q1E2q20 = 48; % Estimation of expectations (lower than avg price because of downward trend)
PX_2q20 = 26.82; % 
PX_3q20 = 43.36;
PX_4q20 = 41;

PX_Long = 50;   % Long term oil price in forecast

% i_VV_act_4q18 = 0.1061 / 4; % Tarasenko
% i_VV_act_1q19 = 0.1151 / 4; % Tarasenko % Methodology has been changed
% % i_VV_act_2q19 = 0.1180 / 4; % Tarasenko (without June 2019)
% i_VV_act_2q19 = 0.1194 / 4; % Tarasenko
% i_VV_act_3q19 = 0.1134 / 4; % Tarasenko (july and august) for OPR 15.10

% i_VV_act_3q19 = 0.1159 / 4; % Tarasenko (whole 3 quarters)
% i_VV_act_3q19 = 0.13294 / 4; % Napalkov 
% i_VV_act_4q19 = 0.12754 / 4; % Napalkov (first 2 months)
% i_VV_act_4q19 = 0.12574 / 4; % Napalkov
% i_VV_act_1q20 = 0.12764 / 4; % Napalkov (only January)
% i_VV_act_1q20 = 0.12764 / 4; % Napalkov (January and February)
% i_VV_act_1q20 = 0.12587 / 4; % Napalkov (whole 1 quarter first estimation)
i_VV_act_1q20 = 0.12415 / 4; % Napalkov (whole 1 quarter revised)
i_VV_act_2q20 = 0.11729 / 4; % Napalkov (whole 2 quarter)
% i_VV_act_3q20 = 0.11060 / 4; % Napalkov (only July)
% i_VV_act_3q20 = 0.109 / 4; % Napalkov (July and August)
i_VV_act_3q20 = 0.1082 / 4; % Napalkov (whole 3 quarter)
i_VV_forecast_4q20 = 0.0993 / 4; % Napalkov (Forecast)

%_________INFLATION FOR CORE model

% dp_VV_act_4q18 = 0.043;
% dp_VV_act_1q19 = 0.0515;
% dp_VV_act_2q19 = 0.044;
% ______________________________For VKS 16.04
% dp_VV_STforecast_2q19 = 0.0487;
% dp_VV_STforecast_3q19 = 0.0477;

% ______________________________For VKS 03.06
% dp_VV_STforecast_2q19 = 0.04937;
% dp_VV_STforecast_3q19 = 0.04709;

% %_______________________________For VKS 16.07
% 
% dp_VV_STforecast_2q19 = 0.042;
% dp_VV_STforecast_3q19 = 0.042;
% dp_VV_STforecast_4q19 = 0.04;

% %_______________________________For VKS 27.08
% 
% dp_VV_STforecast_2q19 = 0.042;
% dp_VV_STforecast_3q19 = 0.0405;
% % dp_VV_STforecast_4q19 = 0.0377;
% 
% %_______________________________For VKS 15.10
% 
% dp_VV_act_3q19 = 0.0370;
% dp_VV_STforecast_4q19 = 0.03077;

% %_______________________________For VKS 03.12
% 
% dp_VV_act_3q19 = log(1 + 0.0370);
% dp_VV_STforecast_4q19 = log(1 + 0.0301);

% %_______________________________For VKS 2020.opr01
% 
% dp_VV_actYoY_3q19 = log(1 + 0.0370);
% dp_VV_actYoY_4q19 = log(1 + 0.0275); 
% dp_VV_STforecastYoY_1q20 = log(1 + 0.0208); % Forecast

% %_______________________________For VKS 2020.opr02
% dp_VV_actYoY_3q19 = log(1 + 0.0370);
% dp_VV_actYoY_4q19 = log(1 + 0.0275); 
% % dp_VV_STforecastYoY_1q20 = log(1 + 0.0195); % Before OPEC+ Crash
% dp_VV_STforecastYoY_1q20 = log(1 + 0.0210); % AFTER OPEC+ CRASH

%_______________________________For VKS 2020.opr03
% dp_VV_actYoY_3q19 = log(1 + 0.0370);
% dp_VV_actYoY_4q19 = log(1 + 0.0275); 
% dp_VV_actYoY_1q20 = log(1 + 0.0261);
% dp_VV_STforecastYoY_2q20 = log(1 + 0.0336); 
% dp_VV_STforecastYoY_3q20 = log(1 + 0.0397); 

%_______________________________For VKS 2020.opr04

% dp_VV_actYoY_1q20 = log(1 + 0.0261);
% dp_VV_STforecastYoY_2q20 = log(1 + 0.0328); 
% dp_VV_STforecastYoY_3q20 = log(1 + 0.0399); 

% %_______________________________For VKS 2020.opr05 before new inflation statistics 
% 
% dp_VV_actYoY_1q20 = log(1 + 0.0261);
% dp_VV_STforecastYoY_2q20 = log(1 + 0.033); 
% dp_VV_STforecastYoY_3q20 = log(1 + 0.0379); 
% dp_VV_STforecastYoY_4q20 = log(1 + 0.0398); 

% %_______________________________For VKS 2020.opr05
% 
% dp_VV_actYoY_1q20 = log(1 + 0.0261);
% dp_VV_STforecastYoY_2q20 = log(1 + 0.0347); 
% dp_VV_STforecastYoY_3q20 = log(1 + 0.0396); 
% dp_VV_STforecastYoY_4q20 = log(1 + 0.0415); 

% %_______________________________For VKS 2020.opr06

% dp_VV_actYoY_1q20 = log(1 + 0.0261);
% dp_VV_STforecastYoY_2q20 = log(1 + 0.0347); 
% dp_VV_STforecastYoY_3q20 = log(1 + 0.0390 + 0.0004); 
% dp_VV_STforecastYoY_4q20 = log(1 + 0.0422 + 0.0008); 

% %_______________________________For VKS 2020.opr07
% 
% dp_VV_actYoY_1q20 = log(1 + 0.0261);
% dp_VV_actYoY_2q20 = log(1 + 0.0347); 
% dp_VV_actYoY_3q20 = log(1 + 0.0405); 
% dp_VV_STforecastYoY_4q20 = log(1 + 0.0435); 

%_______________________________For VKS 2020.opr08

dp_VV_actYoY_1q20 = log(1 + 0.0261);
dp_VV_actYoY_2q20 = log(1 + 0.0347); 
dp_VV_actYoY_3q20 = log(1 + 0.0405); 
dp_VV_STforecastYoY_4q20 = log(1 + 0.0507); 
dp_VV_STforecastYoY_1q21 = log(1 + 0.0475); 
dp_VV_STforecastYoY_2q21 = log(1 + 0.0409); % Not used

% %_________INFLATION FOR RDSGE model
% 
% dp_VV_F_act_4q18 = 0.043;
% dp_VV_M_act_4q18 = 0.043;
% dp_VV_S_act_4q18 = 0.043;
% 
% dp_VV_F_act_1q19 = 0.0515;
% dp_VV_M_act_1q19 = 0.0515;
% dp_VV_S_act_1q19 = 0.0515;
% 
% dp_VV_F_STforecast_2q19 = 0.0487;
% dp_VV_M_STforecast_2q19 = 0.0487;
% dp_VV_S_STforecast_2q19 = 0.0487;
% 
% dp_VV_F_STforecast_3q19 = 0.0477;
% dp_VV_M_STforecast_3q19 = 0.0477;
% dp_VV_S_STforecast_3q19 = 0.0477;
% 
% %_______________________ACTUAL and ESTIMATED FOR RUSSIA
% 
% dp_F_act_4q18 = 0.043;
% dp_M_act_4q18 = 0.043;
% dp_S_act_4q18 = 0.043;
% 
% dp_F_act_1q19 = 0.0515;
% dp_M_act_1q19 = 0.0515;
% dp_S_act_1q19 = 0.0515;
% 
% dp_F_STforecast_2q19 = 0.0487;
% dp_M_STforecast_2q19 = 0.0487;
% dp_S_STforecast_2q19 = 0.0487;
% 
% dp_F_STforecast_3q19 = 0.0477;
% dp_M_STforecast_3q19 = 0.0477;
% dp_S_STforecast_3q19 = 0.0477;

% %______________________RESTORED FOR THE REST OF THE COUNTRY
% sh=0.104; % Share of VV in Country price index
% 
% dp_RU_F_act_4q18 = dp_F_act_4q18 / (1 - sh) - sh / (1 - sh) * dp_VV_F_act_4q18;
% dp_RU_M_act_4q18 = dp_M_act_4q18 / (1 - sh) - sh / (1 - sh) * dp_VV_M_act_4q18;
% dp_RU_S_act_4q18 = dp_S_act_4q18 / (1 - sh) - sh / (1 - sh) * dp_VV_S_act_4q18;
% 
% dp_RU_F_act_1q19 = dp_F_act_1q19 / (1 - sh) - sh / (1 - sh) * dp_VV_F_act_1q19;
% dp_RU_M_act_1q19 = dp_M_act_1q19 / (1 - sh) - sh / (1 - sh) * dp_VV_M_act_1q19;
% dp_RU_S_act_1q19 = dp_S_act_1q19 / (1 - sh) - sh / (1 - sh) * dp_VV_S_act_1q19;
% 
% dp_RU_F_STforecast_2q19 = dp_F_STforecast_2q19 / (1 - sh) - sh / (1 - sh) * dp_VV_F_STforecast_2q19;
% dp_RU_M_STforecast_2q19 = dp_M_STforecast_2q19 / (1 - sh) - sh / (1 - sh) * dp_VV_M_STforecast_2q19;
% dp_RU_S_STforecast_2q19 = dp_S_STforecast_2q19 / (1 - sh) - sh / (1 - sh) * dp_VV_S_STforecast_2q19;
% 
% dp_RU_F_STforecast_3q19 = dp_F_STforecast_3q19 / (1 - sh) - sh / (1 - sh) * dp_VV_F_STforecast_3q19;
% dp_RU_M_STforecast_3q19 = dp_M_STforecast_3q19 / (1 - sh) - sh / (1 - sh) * dp_VV_M_STforecast_3q19;
% dp_RU_S_STforecast_3q19 = dp_S_STforecast_3q19 / (1 - sh) - sh / (1 - sh) * dp_VV_S_STforecast_3q19;

% 
% % For RDSGE model we use Rub/USD informatioin
% %______From VKS 16.07.2019 we use average exchange rate
S_actUSD_4q18 = 66.51;
S_actUSD_1q19 = 65.74;
S_actUSD_2q19 = 64.52;
S_actUSD_3q19 = 64.59;
% S_actUSD_4q19 = 63.54; % ocasionally included first half of january 2020
S_actUSD_4q19 = 63.74;
% S_actUSD_1q20 = 62.92; % First variant of Forecast
% S_actUSD_1q20 = 63.45;

% S_actUSD_1q20 = 63.96; % avg till 28.02.2020 + Optimistic scenario
% S_actUSD_1q20 = 64.39; % avg till 28.02.2020 + Flat scenario
% S_actUSD_1q20 = 66.50; % avg till 28.02.2020 + Stress scenario

%_______________NEW Scenarios!!!!!!!!!!!!!_________________________________
% S_actUSD_1q20 = 64.11; % avg till 04.03.2020 + New MainFlat scenario

% S_actUSD_1q20 = 64.71; % avg till 04.03.2020 + New Stress scenario

%_______________AFTER OPEC+ deal crash!!!!!!!!!!!!!!!______________________

% S_actUSD_1q20 = 66.55; % avg till 10.03.2020 + Main AFTER OPEC+ CRASH
S_actUSD_1q20 = 66.63;
S_actUSD_2q20 = 72.04;
% S_actUSD_3q20 = 73.13; % Before DDKP correction
% S_actUSD_3q20 = 74.3; % To fit DDKP figure on 2nd half of 2020
S_actUSD_3q20 = 73.57;
% S_actUSD_4q20 = 80; % OPR07
S_actUSD_4q20 = 77.3;
%_____end of the period exchange rate

% S_actUSD_4q18 = 69.52;
% S_actUSD_1q19 = 65.41;
% S_actUSD_2q19 = 63.07;
% % S_actUSD_3q19 = 63.86; % 09.07.2019 Official rate from cbr.ru
% S_actUSD_3q19 = 64; % AD HOC


% For Core  model we use NEER information
S_actual_4q18 = 1.99375462475711; % ln of NEER VVGU (approximated by USDRUB)
S_actual_1q19 = S_actual_4q18 * S_actUSD_1q19 / S_actUSD_4q18;
S_actual_2q19 = S_actual_1q19 * S_actUSD_2q19 / S_actUSD_1q19;
S_actual_3q19 = S_actual_2q19 * S_actUSD_3q19 / S_actUSD_2q19;
S_actual_4q19 = S_actual_3q19 * S_actUSD_4q19 / S_actUSD_3q19;
S_actual_1q20 = S_actual_4q19 * S_actUSD_1q20 / S_actUSD_4q19;
S_actual_2q20 = S_actual_1q20 * S_actUSD_2q20 / S_actUSD_1q20;
S_actual_3q20 = S_actual_2q20 * S_actUSD_3q20 / S_actUSD_2q20;
S_actual_4q20 = S_actual_3q20 * S_actUSD_4q20 / S_actUSD_3q20;

% ik_actual = 7.75;
% ik_bl_2q19 = 7.5; % For Core2 (OLD)
% ik_actual_2q19 = 7.5; % Fore Core3 (OLD)
% ik_bl_3q19 = 7; % For Core3 (OLD)

ik_Neutral = 0.055/4;

% ik_actual_3q19 = 7.265; % AVG!!!
% ik_actual_4q19 = 6.595; % AVG!!!

% ik_bl_1q20 = 6.0656; % AVG if 5.75 from 20.03.2020
% ik_bl_1q20 = 6.102; % AVG if 6 from 20.03.2020 (Flat scenario) = New Stress
% ik_bl_1q20 = 6.139; % AVG if 6.25 from 20.03.2020 (Stress scenario)
% ik_bl_1q20 = 6.25; % AVG if 7 from 20.03.2020
% ik_bl_1q20 = 6.3237; % AVG if 7.5 from 20.03.2020
% ik_bl_1q20 = 6.0287 % AVG if 5.5 from 20.03.2020

ik_actual_1q20 = 6.096;
%____BASELINE____
% ik_bl_2q20 = 6.0;
% ik_bl_3q20 = 6.0;
% ik_bl_4q20 = 6.0;
%____CUT to 5.5 and hold 
% ik_bl_2q20 = 6.0 * 18/60 + 5.5 * 42/60;
% ik_bl_3q20 = 5.5;
% ik_bl_4q20 = 5.5;
%____CUT to 5.0 and hold
% ik_bl_2q20 = 6.0 * 18/60 + 5.5 * 35/60 + 5.0 * 7/60;
% ik_bl_3q20 = 5.0;
% ik_bl_4q20 = 5.0;

%____FEDBASE
ik_bl_2q20 = 6.0 * 18/60 + 5.5 * 35/60 + 4.5 * 7/60; % 5.5333
%ik_bl_3q20 = 4.5 * 18/66 + 4.0 * 48/66;
ik_bl_3q20 = 4.5 * 23/66 + 4.25 * 35/66 + 4.25 * 8/66;
ik_bl_4q20 = 4.25;
ik_bl_1q21 = 4.25;

%_____________CUT to 4
% ik_bl_3q20 = 4.5 * 23/66 + 4.25 * 35/66 + 4.25 * 8/66;
% ik_bl_4q20 = 4.25 * 17/65 + 4 * 48/65;

% dY_YoY4q18_actual = 2.847; % Looks very suspicious and create unrealistic dynamics. May be should be treated as measurement error  
% dY_YoY4q18_actual = 2.347;
% dY_YoY1q19_actual = 1;
% dY_YoY2q19_actual = 0.9;
% dY_YoY3q19_actual = 1.26; % Based on Volgo-Vyatka SA series (old vers)

%________________________________Current data = 2.02
% dY_YoY3q19_actual = 2.01;
% %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% % dY_YoY4q19_actual = 1.26; % Based on nowcast for Volgo-Vyatka SA series (SHOULD BE REVISED)  
% % _______________________________Current data = 0.35
% dY_YoY4q19_actual = 0.29;

%_________________________________OPR04: before OPEC+ correction
% dY_YoY1q20_actual = 0.88;
% dY_YoY2q20_actual = -5.65;
% dY_YoY3q20_forecast = -4.40;
%_________________________________OPR04: after OPEC+ correction
% dY_YoY1q20_actual = 0.88;
% dY_YoY2q20_actual = -6.524;
% dY_YoY3q20_forecast = -5.256;
%_________________________________OPR05
% dY_YoY1q20_actual = 0.88;
% dY_YoY2q20_actual = -13.64 + 1.58;
% dY_YoY3q20_forecast = -10.99 + 5.58;

% %_________________________________OPR06
% dY_YoY1q20_actual = 0.88;
% dY_YoY2q20_actual = -11.5; % 14.4 - exact figure
% dY_YoY3q20_forecast = -9.55 + 2.05 ; % = -7.5%
% % dY_YoY4q20_forecast = -8.19 + 3.69 ; % = -4.5% Don't used !!
% 
% %_________________________________OPR07
% dY_YoY1q20_actual = 0.88;
% dY_YoY2q20_actual = -10.875; 
% dY_YoY3q20_forecast = ( -7.4 - 7.4) / 2 ; % = -7.5%
% dY_YoY4q20_forecast = ( -7.5 - 7.0) / 2 ; % = -7.35%

% %_________________________________OPR07 after correction of 2q2020
% dY_YoY1q20_actual = 0.88;
% dY_YoY2q20_actual = -7.74; 
% dY_YoY3q20_forecast = (-3.79 - 4.02) / 2 ; %
% dY_YoY4q20_forecast = (-3.91 - 4.30) / 2 ; % 

%_________________________________OPR08
dY_YoY1q20_actual = 2.7;
dY_YoY2q20_actual = -7.1; 
dY_YoY3q20_actual = -2.5; %
dY_YoY4q20_forecast = -2.5 ; % only DFM
dY_YoY1q21_forecast = -3.3 ; % only DFM

% dY_YoY1q20_actual = 1.09;
% dY_YoY2q20_actual = -8.96;
% dY_YoY2q20E3q20 = - 5;
% rho_etarp_comp_RDSGE = 0; % AR(1) coeff for compensating shock in etarp in DSGE model

istar_actual_2q19 = 2.5;
istar_actual_3q19 = 2;
istar_actual_4q19 = 1.75;
istar_actual_1q20 = 1.4;
istar_actual_2q20 = 0.25;
istar_q2E3q20 = 0.25;
istar_q3E4q20 = 0.25;
istar_q4E1q21 = 0.25;
istar_LR = 2.5;

dG_YoY1q20 = 0.18 * 0 * 4;
dG_YoY2q20 = 0.18 * 0.52 * 4;
dG_YoY3q20 = 0.18 * 0.42 * 4;
dG_YoY4q20 = 0.18 * 0.06 * 4;

dwp_YoY1q20_actual = 5.18;
dwp_YoY2q20_actual = 0.25;
dwp_YoY3q20_actual = 2.1;
dwp_YoY4q20_forecast = 1.1;

save INPUT
% 
% OUTPUT_CORE4 = Core4_forecasting_2020_opr05(Nforc,FH);
% 
% y_CORE4 = OUTPUT_CORE4.y;
% y_f_CORE4 = OUTPUT_CORE4.y_f;
% y_f_bl_CORE4 = OUTPUT_CORE4.y_f_bl;
% y_sq_CORE4 = OUTPUT_CORE4.y_sq;
% y_f_noepsik_CORE4 = OUTPUT_CORE4.y_f_noepsik;
% y_f_loose_CORE4 = OUTPUT_CORE4.y_f_loose;
% y_f_tight_CORE4 = OUTPUT_CORE4.y_f_tight;
% y_f_noKSP_CORE4 = OUTPUT_CORE4.y_f_noKSP;
% dp_YoY_CORE4 = OUTPUT_CORE4.dp_YoY;
% dp_YoY_bl_CORE4 = OUTPUT_CORE4.dp_YoY_bl;
% dp_YoY_noepsik_CORE4 = OUTPUT_CORE4.dp_YoY_noepsik;
% dp_YoY_loose_CORE4 = OUTPUT_CORE4.dp_YoY_loose;
% dp_YoY_tight_CORE4 = OUTPUT_CORE4.dp_YoY_tight;
% dp_YoY_noKSP_CORE4 = OUTPUT_CORE4.dp_YoY_noKSP;
% dy_YoY_bl_CORE4 = OUTPUT_CORE4.dy_YoY_bl;
% dy_YoY_loose_CORE4 = OUTPUT_CORE4.dy_YoY_loose;
% dy_YoY_tight_CORE4 = OUTPUT_CORE4.dy_YoY_tight;
% dy_YoY_noKSP_CORE4 = OUTPUT_CORE4.dy_YoY_noKSP;
% Nper_CORE_CORE4 = OUTPUT_CORE4.Nper;
% X_dp_YoY_CORE4 = OUTPUT_CORE4.X_dp_YoY;
% X_dy_YoY_CORE4 = OUTPUT_CORE4.X_dy_YoY;
% X_y_CORE4 = OUTPUT_CORE4.X_y;
% X_ik_CORE4 = OUTPUT_CORE4.X_ik;
% X_S_CORE4 = OUTPUT_CORE4.X_S;
% uf_CORE4 = OUTPUT_CORE4.uf;
% uf_noKSP_CORE4 = OUTPUT_CORE4.uf_noKSP;
% u_CORE4 = OUTPUT_CORE4.u;
% Nper_CORE4 = OUTPUT_CORE4.Nper;
% OPR_info_CORE4 = OUTPUT_CORE4.OPR_info;
% S_tr_CORE4 = OUTPUT_CORE4.S_tr;
% 
% [ y_sh_dec4, y_sh_dec_re4 ] = Shock_decomposition(y_CORE4, y_f_CORE4, u_CORE4, uf_CORE4);
% %____Decomposition of series
% dpc_dec4=y_sh_dec_re4(:,:,1)'; % dpc
% y_dec4=y_sh_dec_re4(:,:,16)'; % y
% s_dec4=y_sh_dec_re4(:,:,20)'; % s
% ik_dec4=y_sh_dec_re4(:,:,19)'; % ik

OUTPUT_CORE5 = Core5_forecasting_2020_opr08(Nforc,FH);

y_CORE5 = OUTPUT_CORE5.y;
y_f_CORE5 = OUTPUT_CORE5.y_f;
y_f_bl_CORE5 = OUTPUT_CORE5.y_f_bl;
y_sq_CORE5 = OUTPUT_CORE5.y_sq;
y_f_noepsik_CORE5 = OUTPUT_CORE5.y_f_noepsik;
y_f_loose_CORE5 = OUTPUT_CORE5.y_f_loose;
y_f_tight_CORE5 = OUTPUT_CORE5.y_f_tight;
y_f_noKSP_CORE5 = OUTPUT_CORE5.y_f_noKSP;
dp_YoY_CORE5 = OUTPUT_CORE5.dp_YoY;
dp_YoY_bl_CORE5 = OUTPUT_CORE5.dp_YoY_bl;
dp_YoY_noepsik_CORE5 = OUTPUT_CORE5.dp_YoY_noepsik;
dp_YoY_loose_CORE5 = OUTPUT_CORE5.dp_YoY_loose;
dp_YoY_tight_CORE5 = OUTPUT_CORE5.dp_YoY_tight;
dp_YoY_noKSP_CORE5 = OUTPUT_CORE5.dp_YoY_noKSP;
dy_YoY_bl_CORE5 = OUTPUT_CORE5.dy_YoY_bl;
dy_YoY_loose_CORE5 = OUTPUT_CORE5.dy_YoY_loose;
dy_YoY_tight_CORE5 = OUTPUT_CORE5.dy_YoY_tight;
dy_YoY_noKSP_CORE5 = OUTPUT_CORE5.dy_YoY_noKSP;
Nper_CORE_CORE5 = OUTPUT_CORE5.Nper;
X_dp_YoY_CORE5 = OUTPUT_CORE5.X_dp_YoY;
X_dy_YoY_CORE5 = OUTPUT_CORE5.X_dy_YoY;
X_y_CORE5 = OUTPUT_CORE5.X_y;
X_ik_CORE5 = OUTPUT_CORE5.X_ik;
X_S_CORE5 = OUTPUT_CORE5.X_S;
uf_CORE5 = OUTPUT_CORE5.uf;
uf_noKSP_CORE5 = OUTPUT_CORE5.uf_noKSP;
u_CORE5 = OUTPUT_CORE5.u;
Nper_CORE5 = OUTPUT_CORE5.Nper;
OPR_info_CORE5 = OUTPUT_CORE5.OPR_info;
S_tr_CORE5 = OUTPUT_CORE5.S_tr;

[ y_sh_dec5, y_sh_dec_re5 ] = Shock_decomposition_5(y_CORE5, y_f_CORE5, u_CORE5, uf_CORE5);
%____Decomposition of series
dpc_dec5=y_sh_dec_re5(:,:,1)'; % dpc
y_dec5=y_sh_dec_re5(:,:,18)'; % y
s_dec5=y_sh_dec_re5(:,:,22)'; % s
ik_dec5=y_sh_dec_re5(:,:,21)'; % ik
wp_dec5=y_sh_dec_re5(:,:,40)'; % wp

%______________________Graphs



% figure(101)
% clf
% 
% 
% subplot(2,3,1); plot([y_CORE4(1,:)'; nan(Nforc,1)],'k','LineWidth',2); hold on;
% % subplot(2,3,1); plot([y_fact_check(7,:)'; nan(Nforc-1,1)],'go','LineWidth',1);
% % subplot(2,3,1); plot([nan(size(y_CORE4,2),1); y_f_CORE4(1,1:Nforc)'],'g.-','LineWidth',2); ylabel('dpc');
% subplot(2,3,1); plot([nan(size(y_CORE4,2),1); y_f_bl_CORE4(1,1:Nforc)'],'r.--','LineWidth',2); ylabel('dpc');
% % subplot(2,3,1); plot([nan(size(y_CORE4,2),1); y_f_noepsik_CORE4(1,1:Nforc)'],'.-','LineWidth',2);
% legend('Fact','Baseline');
% subplot(2,3,1); plot([1 size(y_CORE4,2)+Nforc],[0 0],'k','LineWidth',1);
% 
% subplot(2,3,2); plot([y_CORE4(16,:)'; nan(Nforc,1)],'k','LineWidth',2); hold on;
% subplot(2,3,2); plot([nan(size(y_CORE4,2),1); y_f_CORE4(16,1:Nforc)'],'g.-','LineWidth',2); ylabel('y');
% subplot(2,3,2); plot([nan(size(y_CORE4,2),1); y_f_bl_CORE4(16,1:Nforc)'],'r.--','LineWidth',2);
% subplot(2,3,2); plot([nan(size(y_CORE4,2),1); y_f_noepsik_CORE4(16,1:Nforc)'],'.-','LineWidth',2);
% subplot(2,3,2); plot([1 size(y_CORE4,2)+Nforc],[0 0],'k','LineWidth',1);
% 
% subplot(2,3,3); plot([y_CORE4(19,:)'; nan(Nforc,1)],'k','LineWidth',2); hold on;
% subplot(2,3,3); plot([nan(size(y_CORE4,2),1); y_f_CORE4(19,1:Nforc)'],'g.-','LineWidth',2); ylabel('ik');
% subplot(2,3,3); plot([nan(size(y_CORE4,2),1); y_f_bl_CORE4(19,1:Nforc)'],'r.--','LineWidth',2);
% subplot(2,3,3); plot([nan(size(y_CORE4,2),1); y_f_noepsik_CORE4(19,1:Nforc)'],'.-','LineWidth',2);
% legend('Fact','First','Baseline','No epsik');
% subplot(2,3,3); plot([1 size(y_CORE4,2)+Nforc],[0 0],'k','LineWidth',1);
% 
% subplot(2,3,4); plot([y_CORE4(20,:)'; nan(Nforc,1)],'k','LineWidth',2); hold on;
% subplot(2,3,4); plot([nan(size(y_CORE4,2),1); y_f_CORE4(20,1:Nforc)'],'g.-','LineWidth',2); ylabel('s');
% subplot(2,3,4); plot([nan(size(y_CORE4,2),1); y_f_bl_CORE4(20,1:Nforc)'],'r.--','LineWidth',2);
% subplot(2,3,4); plot([nan(size(y_CORE4,2),1); y_f_noepsik_CORE4(20,1:Nforc)'],'.-','LineWidth',2);
% legend('Fact','First','Baseline','No epsik');
% subplot(2,3,4); plot([1 size(y_CORE4,2)+Nforc],[0 0],'k','LineWidth',1);
% 
% subplot(2,3,5); plot([y_CORE4(58,:)'; nan(Nforc,1)],'k','LineWidth',2); hold on;
% subplot(2,3,5); plot([nan(size(y_CORE4,2),1); y_f_CORE4(58,1:Nforc)'],'g.-','LineWidth',2); ylabel('PX*');
% subplot(2,3,5); plot([nan(size(y_CORE4,2),1); y_f_bl_CORE4(58,1:Nforc)'],'r.--','LineWidth',2);
% subplot(2,3,5); plot([nan(size(y_CORE4,2),1); y_f_noepsik_CORE4(58,1:Nforc)'],'.-','LineWidth',2);
% legend('Fact','First','Baseline','No epsik');
% subplot(2,3,5); plot([1 size(y_CORE4,2)+Nforc],[0 0],'k','LineWidth',1);
% 
% subplot(2,3,6); plot([y_f_bl_CORE4(18,2:Nforc)'],'.--','LineWidth',2); hold on; ylabel('i');
% subplot(2,3,6); plot([y_f_bl_CORE4(19,2:Nforc)'],'r.--','LineWidth',2); legend('i','ik');
% subplot(2,3,6); plot([1 size(y_CORE4,2)+Nforc],[0 0],'k','LineWidth',1);

figure(102)
clf


subplot(2,3,1); plot([y_CORE5(1,:)'; nan(Nforc,1)],'k','LineWidth',2); hold on;
% subplot(2,3,1); plot([y_fact_check(7,:)'; nan(Nforc-1,1)],'go','LineWidth',1);
% subplot(2,3,1); plot([nan(size(y_CORE5,2),1); y_f_CORE5(1,1:Nforc)'],'g.-','LineWidth',2); ylabel('dpc');
subplot(2,3,1); plot([nan(size(y_CORE5,2),1); y_f_bl_CORE5(1,1:Nforc)'],'r.--','LineWidth',2); ylabel('dpc');
% subplot(2,3,1); plot([nan(size(y_CORE5,2),1); y_f_noepsik_CORE5(1,1:Nforc)'],'.-','LineWidth',2);
legend('Fact','Baseline');
subplot(2,3,1); plot([1 size(y_CORE5,2)+Nforc],[0 0],'k','LineWidth',1);

subplot(2,3,2); plot([y_CORE5(18,:)'; nan(Nforc,1)],'k','LineWidth',2); hold on;
subplot(2,3,2); plot([nan(size(y_CORE5,2),1); y_f_CORE5(18,1:Nforc)'],'g.-','LineWidth',2); ylabel('y');
subplot(2,3,2); plot([nan(size(y_CORE5,2),1); y_f_bl_CORE5(18,1:Nforc)'],'r.--','LineWidth',2);
subplot(2,3,2); plot([nan(size(y_CORE5,2),1); y_f_noepsik_CORE5(18,1:Nforc)'],'.-','LineWidth',2);
subplot(2,3,2); plot([1 size(y_CORE5,2)+Nforc],[0 0],'k','LineWidth',1);

subplot(2,3,3); plot([y_CORE5(21,:)'; nan(Nforc,1)],'k','LineWidth',2); hold on;
subplot(2,3,3); plot([nan(size(y_CORE5,2),1); y_f_CORE5(21,1:Nforc)'],'g.-','LineWidth',2); ylabel('ik');
subplot(2,3,3); plot([nan(size(y_CORE5,2),1); y_f_bl_CORE5(21,1:Nforc)'],'r.--','LineWidth',2);
subplot(2,3,3); plot([nan(size(y_CORE5,2),1); y_f_noepsik_CORE5(21,1:Nforc)'],'.-','LineWidth',2);
legend('Fact','First','Baseline','No epsik');
subplot(2,3,3); plot([1 size(y_CORE5,2)+Nforc],[0 0],'k','LineWidth',1);

subplot(2,3,4); plot([y_CORE5(22,:)'; nan(Nforc,1)],'k','LineWidth',2); hold on;
subplot(2,3,4); plot([nan(size(y_CORE5,2),1); y_f_CORE5(22,1:Nforc)'],'g.-','LineWidth',2); ylabel('s');
subplot(2,3,4); plot([nan(size(y_CORE5,2),1); y_f_bl_CORE5(22,1:Nforc)'],'r.--','LineWidth',2);
subplot(2,3,4); plot([nan(size(y_CORE5,2),1); y_f_noepsik_CORE5(22,1:Nforc)'],'.-','LineWidth',2);
legend('Fact','First','Baseline','No epsik');
subplot(2,3,4); plot([1 size(y_CORE5,2)+Nforc],[0 0],'k','LineWidth',1);

subplot(2,3,5); plot([y_CORE5(36,:)'; nan(Nforc,1)],'k','LineWidth',2); hold on;
subplot(2,3,5); plot([nan(size(y_CORE5,2),1); y_f_CORE5(36,1:Nforc)'],'g.-','LineWidth',2); ylabel('PX*');
subplot(2,3,5); plot([nan(size(y_CORE5,2),1); y_f_bl_CORE5(36,1:Nforc)'],'r.--','LineWidth',2);
subplot(2,3,5); plot([nan(size(y_CORE5,2),1); y_f_noepsik_CORE5(36,1:Nforc)'],'.-','LineWidth',2);
legend('Fact','First','Baseline','No epsik');
subplot(2,3,5); plot([1 size(y_CORE5,2)+Nforc],[0 0],'k','LineWidth',1);

subplot(2,3,6); plot([y_f_bl_CORE5(20,2:Nforc)'],'.--','LineWidth',2); hold on; ylabel('i');
subplot(2,3,6); plot([y_f_bl_CORE5(21,2:Nforc)'],'r.--','LineWidth',2); legend('i','ik');
subplot(2,3,6); plot([1 size(y_CORE5,2)+Nforc],[0 0],'k','LineWidth',1);

% figure(104)
% clf
% 
% subplot(2,2,1); plot([dp_YoY_bl_CORE4(Nper_CORE4-2:Nper_CORE4+1); nan(FH-1,1)],'ko-','LineWidth',3,'MarkerSize',11); hold on;
% subplot(2,2,1); plot([nan(3,1); dp_YoY_noKSP_CORE4(Nper_CORE4+1:Nper_CORE4+FH)],'k--  ','LineWidth',3); hold on;
% subplot(2,2,1); plot([nan(3,1); dp_YoY_bl_CORE4(Nper_CORE4+1:Nper_CORE4+FH)],'ro-  ','LineWidth',2,'MarkerSize',15,'MarkerFaceColor','m'); hold on;
% subplot(2,2,1); plot([nan(3,1); dp_YoY_loose_CORE4(Nper_CORE4+1:Nper_CORE4+FH)],'v-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','g'); 
% subplot(2,2,1); plot([nan(3,1); dp_YoY_tight_CORE4(Nper_CORE4+1:Nper_CORE4+FH)],'s-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','c');
% subplot(2,2,1); plot([nan(3,1); dp_YoY_noepsik_CORE4(Nper_CORE4+1:Nper_CORE4+FH)],'k:  ','LineWidth',3,'MarkerSize',10,'MarkerFaceColor','c');legend('Fact','No KSP','Baseline CORE4','Loose','Tight','No epsik');
% subplot(2,2,1); plot([1 FH+3],[0.04 0.04],'k','LineWidth',3); ylabel('dpc YoY') ;
% 
% subplot(2,2,2); plot([y_CORE4(19,Nper_CORE4-2:Nper_CORE4)'*400+ik_Neutral*400'; y_f_bl_CORE4(19,1)'*400+ik_Neutral*400; nan(FH-1,1)],'ko-','LineWidth',3,'MarkerSize',11); hold on;
% subplot(2,2,2); plot([nan(3,1); y_f_noKSP_CORE4(19,1:FH)'*400+ik_Neutral*400],'k--  ','LineWidth',3); hold on;
% subplot(2,2,2); plot([nan(3,1); y_f_bl_CORE4(19,1:FH)'*400+ik_Neutral*400],'ro-  ','LineWidth',2,'MarkerSize',15,'MarkerFaceColor','m'); hold on;
% subplot(2,2,2); plot([nan(3,1); y_f_loose_CORE4(19,1:FH)'*400+ik_Neutral*400],'v-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','g');
% subplot(2,2,2); plot([nan(3,1); y_f_tight_CORE4(19,1:FH)'*400+ik_Neutral*400],'s-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','c');
% subplot(2,2,2); plot([nan(3,1); y_f_noepsik_CORE4(19,1:FH)'*400+ik_Neutral*400],'k:  ','LineWidth',3,'MarkerSize',10,'MarkerFaceColor','c'); legend('Fact','No KSP','Baseline CORE4','Loose','Tight','No epsik');
% subplot(2,2,2); plot([1 FH+3],[ik_Neutral*400 ik_Neutral*400],'k--','LineWidth',2); ylabel('ik'); 
% 
% subplot(2,2,3); plot([y_CORE4(16,Nper_CORE4-2:Nper_CORE4)' ; y_f_bl_CORE4(16,1)'; nan(FH-1,1)],'ko-','LineWidth',3,'MarkerSize',11); hold on;
% subplot(2,2,3); plot([nan(3,1); y_f_noKSP_CORE4(16,1:FH)'],'k--  ','LineWidth',3); hold on;
% subplot(2,2,3); plot([nan(3,1); y_f_bl_CORE4(16,1:FH)'],'ro-  ','LineWidth',2,'MarkerSize',15,'MarkerFaceColor','m'); hold on;
% subplot(2,2,3); plot([nan(3,1); y_f_loose_CORE4(16,1:FH)'],'v-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','g'); 
% subplot(2,2,3); plot([nan(3,1); y_f_tight_CORE4(16,1:FH)'],'s-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','c'); legend('Fact','No KSP','Baseline CORE4','Loose','Tight');
% subplot(2,2,3); plot([1 FH+3],[0 0],'k--','LineWidth',2); ylabel('y');
% 
% subplot(2,2,4); plot([dy_YoY_bl_CORE4(Nper_CORE4-2:Nper_CORE4+1); nan(FH-1,1)],'ko-','LineWidth',3,'MarkerSize',11); hold on;
% subplot(2,2,4); plot([nan(3,1); dy_YoY_noKSP_CORE4(Nper_CORE4+1:Nper_CORE4+FH)],'k--  ','LineWidth',3); hold on;
% subplot(2,2,4); plot([nan(3,1); dy_YoY_bl_CORE4(Nper_CORE4+1:Nper_CORE4+FH)],'ro-  ','LineWidth',2,'MarkerSize',15,'MarkerFaceColor','m'); hold on;
% subplot(2,2,4); plot([nan(3,1); dy_YoY_loose_CORE4(Nper_CORE4+1:Nper_CORE4+FH)],'v-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','g'); 
% subplot(2,2,4); plot([nan(3,1); dy_YoY_tight_CORE4(Nper_CORE4+1:Nper_CORE4+FH)],'s-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','c'); legend('Fact','No KSP','Baseline CORE4','Loose','Tight');
% subplot(2,2,4); plot([1 FH+3],[0 0],'k','LineWidth',1); ylabel('dy YoY') ;
% subplot(2,2,4); plot([1 FH+3],[0.015 0.015],'k--','LineWidth',2); ylabel('dy YoY') ;

figure(105)
clf

subplot(2,2,1); plot([dp_YoY_bl_CORE5(Nper_CORE5-2:Nper_CORE5+1); nan(FH-1,1)],'ko-','LineWidth',3,'MarkerSize',11); hold on;
subplot(2,2,1); plot([nan(3,1); dp_YoY_noKSP_CORE5(Nper_CORE5+1:Nper_CORE5+FH)],'k--  ','LineWidth',3); hold on;
subplot(2,2,1); plot([nan(3,1); dp_YoY_bl_CORE5(Nper_CORE5+1:Nper_CORE5+FH)],'ro-  ','LineWidth',2,'MarkerSize',15,'MarkerFaceColor',[1 0.6 0.6]); hold on;
subplot(2,2,1); plot([nan(3,1); dp_YoY_loose_CORE5(Nper_CORE5+1:Nper_CORE5+FH)],'v-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','g'); 
subplot(2,2,1); plot([nan(3,1); dp_YoY_tight_CORE5(Nper_CORE5+1:Nper_CORE5+FH)],'s-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','c');
subplot(2,2,1); plot([nan(3,1); dp_YoY_noepsik_CORE5(Nper_CORE5+1:Nper_CORE5+FH)],'k:  ','LineWidth',3,'MarkerSize',10,'MarkerFaceColor','c');legend('Fact','No KSP','Baseline CORE5','Loose','Tight','No epsik');
subplot(2,2,1); plot([1 FH+3],[0.04 0.04],'k','LineWidth',3); ylabel('dpc YoY') ;

subplot(2,2,2); plot([y_CORE5(21,Nper_CORE5-2:Nper_CORE5)'*400+ik_Neutral*400'; y_f_bl_CORE5(21,1)'*400+ik_Neutral*400; nan(FH-1,1)],'ko-','LineWidth',3,'MarkerSize',11); hold on;
subplot(2,2,2); plot([nan(3,1); y_f_noKSP_CORE5(21,1:FH)'*400+ik_Neutral*400],'k--  ','LineWidth',3); hold on;
subplot(2,2,2); plot([nan(3,1); y_f_bl_CORE5(21,1:FH)'*400+ik_Neutral*400],'ro-  ','LineWidth',2,'MarkerSize',15,'MarkerFaceColor',[1 0.6 0.6]); hold on;
subplot(2,2,2); plot([nan(3,1); y_f_loose_CORE5(21,1:FH)'*400+ik_Neutral*400],'v-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','g');
subplot(2,2,2); plot([nan(3,1); y_f_tight_CORE5(21,1:FH)'*400+ik_Neutral*400],'s-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','c');
subplot(2,2,2); plot([nan(3,1); y_f_noepsik_CORE5(21,1:FH)'*400+ik_Neutral*400],'k:  ','LineWidth',3,'MarkerSize',10,'MarkerFaceColor','c'); legend('Fact','No KSP','Baseline CORE5','Loose','Tight','No epsik');
subplot(2,2,2); plot([1 FH+3],[ik_Neutral*400 ik_Neutral*400],'k--','LineWidth',2); ylabel('ik'); 

subplot(2,2,3); plot([y_CORE5(18,Nper_CORE5-2:Nper_CORE5)' ; y_f_bl_CORE5(18,1)'; nan(FH-1,1)],'ko-','LineWidth',3,'MarkerSize',11); hold on;
subplot(2,2,3); plot([nan(3,1); y_f_noKSP_CORE5(18,1:FH)'],'k--  ','LineWidth',3); hold on;
subplot(2,2,3); plot([nan(3,1); y_f_bl_CORE5(18,1:FH)'],'ro-  ','LineWidth',2,'MarkerSize',15,'MarkerFaceColor',[1 0.6 0.6]); hold on;
subplot(2,2,3); plot([nan(3,1); y_f_loose_CORE5(18,1:FH)'],'v-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','g'); 
subplot(2,2,3); plot([nan(3,1); y_f_tight_CORE5(18,1:FH)'],'s-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','c'); legend('Fact','No KSP','Baseline CORE5','Loose','Tight');
subplot(2,2,3); plot([1 FH+3],[0 0],'k--','LineWidth',2); ylabel('y');

subplot(2,2,4); plot([dy_YoY_bl_CORE5(Nper_CORE5-2:Nper_CORE5+1); nan(FH-1,1)],'ko-','LineWidth',3,'MarkerSize',11); hold on;
subplot(2,2,4); plot([nan(3,1); dy_YoY_noKSP_CORE5(Nper_CORE5+1:Nper_CORE5+FH)],'k--  ','LineWidth',3); hold on;
subplot(2,2,4); plot([nan(3,1); dy_YoY_bl_CORE5(Nper_CORE5+1:Nper_CORE5+FH)],'ro-  ','LineWidth',2,'MarkerSize',15,'MarkerFaceColor',[1 0.6 0.6]); hold on;
subplot(2,2,4); plot([nan(3,1); dy_YoY_loose_CORE5(Nper_CORE5+1:Nper_CORE5+FH)],'v-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','g'); 
subplot(2,2,4); plot([nan(3,1); dy_YoY_tight_CORE5(Nper_CORE5+1:Nper_CORE5+FH)],'s-  ','LineWidth',2,'MarkerSize',10,'MarkerFaceColor','c'); legend('Fact','No KSP','Baseline CORE5','Loose','Tight');
subplot(2,2,4); plot([1 FH+3],[0 0],'k','LineWidth',1); ylabel('dy YoY') ;
subplot(2,2,4); plot([1 FH+3],[0.015 0.015],'k--','LineWidth',2); ylabel('dy YoY') ;


% figure(105)
% clf
% 
% subplot(1,2,1); plot(sum(y_sh_dec_re(:,1:30,1),1)); hold on;
% subplot(1,2,1); plot(y_CORE4(1,:),'r');
% 
% subplot(1,2,2); plot(sum(y_sh_dec_re(:,1:30,16),1)); hold on;
% subplot(1,2,2); plot(y_CORE4(16,:),'r');
ik_dec_sum = sum(ik_dec5,2)*400+ik_Neutral*400;
% load Res_core4Rus
% load Res_core4Rus_minus7
load Res_core5VV_detr5_ikN60
y_sh_dec_re_estim = nan(size(oo_.shock_decomposition,3),size(oo_.shock_decomposition,2),size(oo_.shock_decomposition,1));
for k = 1:M_.endo_nbr
    for m = 1:Nsignif
        y_sh_dec_re_estim(m,:,k) = oo_.shock_decomposition(k,:,m);
    end
end
ik_dec_est_sum = sum(y_sh_dec_re_estim(:,1:13,19),2)*400+ik_Neutral*400;

figure(106)
clf
subplot(1,2,1);
plot(y_f_bl_CORE5(21,:)'*400+ik_Neutral*400,'LineWidth',2); hold on; legend('ik f bl');
plot(ik_dec_sum(Nsignif+1:size(ik_dec_sum,1)),'r'); 
plot([1 Nforc],[ik_Neutral*400 ik_Neutral*400],'k');

subplot(1,2,2); plot(y_f_bl_CORE5(31,:)'*400+2.5,'LineWidth',2); hold on; legend('i star');
plot([1 Nforc],[2.5 2.5],'k');

% figure(107)
% clf
% plot(ik_dec_sum(1:Nsignif+10),'r'); hold on;
% plot(ik_dec_est_sum,'g');
% plot(ik_dec_est_sum + (y_sh_dec_re_estim(:,14,19)*400),'o');
% plot(y_sh_dec_re_estim(:,15,19)*400+6.5,'k'); legend('formula','est','sum all','fact');



