function [D,Series,dates,datesNum]=load_monthly_panel(filename,sheetname)
% LOAD THE AUXILIARY VARIABLES AND DOES THE APPROPRIATE transformations

%% load the data
[num,text]=xlsread(filename,sheetname);
Series = text(1,3:end);
datesNum= datenum('31-Dec-1899')+num(2:end,2);
dates = datevec(datesNum);
dates = dates(1:end,1:2);
X = num(2:end,3:end);
TransfCode = num(1,3:end);


%% transform the data
[T,N] = size(X);
Td  = size(dates,1);
X = [X; NaN*ones(Td-T,N)];
for j = 1:N
    if TransfCode(j) == 1 %% monthly differences
        temp = (X(13:end,j)-X(12:end-1,j));
        D(:,j) = temp(2:end);
    elseif TransfCode(j) == 2 %% monthly growth rate
        temp = (X(13:end,j)-X(12:end-1,j))./X(12:end-1,j)*100;
        D(:,j) = temp(2:end);
    elseif TransfCode(j) == 3 %% no trasformation, interest rates
        temp = X(13:end,j);
        D(:,j) = temp(2:end);
    else  %% no transformation, other variables
        temp = X(13:end,j);
        D(:,j) = temp(2:end);
    end;
end
%% Adjust the time vector to take into account initial data lost whe transforming the data
dates = dates(14:end,:);
datesNum = datesNum(14:end,:);
%% Trasform monthly diffenences (growth rates) in quarterly equivalents
D_temp = filter([1 2 3 2 1],1,D);
D_temp(:,end) = D(:,end);

%% Keep the GSW variables exactly as they were in the GSW paper
D_temp(:,TransfCode==0) = D(:,TransfCode==0); %% GDP growth is not transformed since it is quarterly

%% Quarterly transformation of the rates
D_temp(:,TransfCode==3) = filter([1 1 1]/3,1,D(:,TransfCode==3));

%% account for data lost when making this trasformation
D = D_temp(6:end,:);
dates = dates(6:end,:);
datesNum = datesNum(6:end,:);

%%% Make sure that the sample begins in a first month of a quarter
if mod(dates(1,2),3)==2 %% If the sample starts in the second month of the quarter
    D = D(3:end,:);
    dates = dates(3:end,:);
    datesNum = datesNum(3:end,:);
elseif mod(dates(1,2),3)==0 %% If the sample starts in the last month of the quarter
    D = D(2:end,:);
    dates = dates(2:end,:);
    datesNum = datesNum(2:end,:);
end;
