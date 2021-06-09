%%  Replication files for:
%%  "Nowcasting: The Real Time Informational Content of Macroeconomic Data",  
%%  Domenico Giannone, Lucrezia Reichlin & David Small, 
%%  Forthcoming, Journal of Monetary Economics.
%%  Paper and programs available at: http://homepages.ulb.ac.be/ dgiannon/

function [Z,Jout,Jmis] = outliers_correction(X,tol);
%function [Z,Jout,Jmis] = outliers_correction(X);
% Adjust for outliers and missing observation

T = size(X,1);
Jmis = isnan(X);
a = sort(X);

%%% define outliers as those obs. that exceed 4 times the interquartile
%%% distance

Jout = (abs(X-a(round(T/2))) > tol*abs(a(round(T*1/4))-a(round(3/4))));

Z = X;
Z(Jmis) = a(round(T/2)); %% put the median in place of missing values
% Z(Jout) = a(round(T/2)); %% put the median in place of outliers
Z(Jout) = mean(X); %% put the median in place of outliers
Zma = MAcentered(Z,3);

Z(Jout) = Zma(Jout);

Z(Jmis) = Zma(Jmis);



%% this function compute MA of order k
function x_ma = MAcentered(x,k_ma);
xpad = [x(1,:).*ones(k_ma,1); x; x(end,:).*ones(k_ma,1)];
for j = k_ma+1:length(xpad)-k_ma;
    x_ma(j-k_ma,:) = mean(xpad(j-k_ma:j+k_ma,:));
end;