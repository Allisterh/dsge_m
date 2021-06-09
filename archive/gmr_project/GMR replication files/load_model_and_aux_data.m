%% LOAD THE MODEL DATA
[QDATA,modelSeries]=xlsread('DataGSWFF_GMR2015.xlsx','ModelDataAll');
datesY = datenum('31-Dec-1899')+QDATA(:,1);
timeY = datevec(datesY);
finalData = QDATA(1:end-1,2:end);
%% LOAD AND TRANSFORM THE AUXILIARY DATA
% panel set to start at the end of the 3rd month of the quarter
[DATA,Series,time_panel,dates_panel]=load_monthly_panel('DataGSWFF_GMR2015.xlsx',sheetName);

[Tm,nDATA]=size(DATA); 
%   'IPTOT'    'CUTOT'    'PMI'    'DPRI'    'URATE'    'PCETOT'    'HSTARTS' 
% 'CON_TOT'    'CPITOT'    'PPI_FG'    'HRLYEGS_TOTPR'    'PHBOS_GA'    'N' 
% 'FFR'    'SP'    'Credit'    'M2'    'EPU'    'T10Y2YM'    'T10YFFM'
% PCEPI

myPanelOrder =[ 13 5 14:15 1 3:4 7:9 11:12 16:18 21]; %Legend_GMRFF2015_4: no CU_TOT no T10Y2YM no T10YFFM no PPI_FG
% 
CONSM = DATA(:,6);
Series = Series(myPanelOrder);
DATA = DATA(:,myPanelOrder);

seriesX = [modelSeries(1,1:5),Series(1:end)];
%% MAKE THE MODEL DATA AND THE AUX DATA COMPATIBLE
% find T0 
T0=find(timeY(:,1)==time_panel(1,1)&timeY(:,2)==time_panel(1,2));
time = time_panel;
dates = dates_panel;
nY = length(modelSeries);
modDatam = NaN*ones(Tm,nY);

modDatamFinal = modDatam;
modDatamFinal(3:3:end-2,:)=finalData(T0:end,:);

%Xfin = [modDatamFinal(:,1:5) DATA(:, 1:end)];
Xfin = [modDatamFinal(:,1) CONSM modDatamFinal(:,3:5) DATA(:,1:end)];
% Xfin = [modDatamFinal(:,1) CONSM modDatamFinal(:,3:6) DATA(:,2) modDatamFinal(:,8) DATA(:,4:end)];
[Tall,N]=size(Xfin);

%% LOAD SPF DATA
[URSPF,~]=xlsread('medianLevel2015.xls','UNEMP','A1:H184');
[GDPSPF,~]=xlsread('medianGrowth2015.xls','RGDP','A1:G184');
[PGDPSPF,~]=xlsread('medianGrowth2015.xls','PGDP','A1:G184');
[CSPF,~]=xlsread('medianGrowth2015.xls','RCONSUM','A1:G184');
[EMPSPF,~]=xlsread('medianLevel2015.xls','EMP','A1:H184');

%% LOAD POPULATION GROWTH SERIES FOR ADJUSTMENT OF SPF FORECASTS
[POPDATA,~]=xlsread('DataGSWFF_GMR2015.xlsx','POPGrowth');

POPDATA = POPDATA(T0:end);