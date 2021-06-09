function [ y_sh_dec, y_sh_dec_re ] = Shock_decomposition_5( y_CORE4, y_f_CORE4, u_CORE4, uf_CORE4 )
%SHOCK_DECOMPOSITION Summary of this function goes here

% load Res_core4_detr4_ikN60_forecast
% load Res_core4_detr4_newvrp_ikN60_26sh_forecast
% oo_C4f_ = oo_;
% M_C4f_ = M_;

% load Res_core4_detr4_newvrp_ikN60_26sh_Hdpx_forecast
load Res_core5VV_detr5_ikN60_forecast
oo_Hdpxf_ = oo_;
M_Hdpxf_ = M_;

% load Res_core4_detr4_ikN60
load Res_core5VV_detr5_ikN60

%________________________Matrices for historical decomposition

A=[zeros(M_.endo_nbr,M_.nstatic) oo_.dr.ghx zeros(M_.endo_nbr,M_.endo_nbr-M_.nstatic-M_.npred-M_.nboth)];
B=oo_.dr.ghu;
% B_decl = B(oo_.dr.inv_order_var,:) ;

%________________________Matrices for forecasting


% Af=[zeros(M_C4f_.endo_nbr,M_C4f_.nstatic) oo_C4f_.dr.ghx zeros(M_C4f_.endo_nbr,M_C4f_.endo_nbr-M_C4f_.nstatic-M_C4f_.npred-M_C4f_.nboth)];
% Bf=oo_C4f_.dr.ghu;
% Bf_decl = Bf(oo_C4f_.dr.inv_order_var,:);

AHdpxf=[zeros(M_Hdpxf_.endo_nbr,M_Hdpxf_.nstatic) oo_Hdpxf_.dr.ghx zeros(M_Hdpxf_.endo_nbr,M_Hdpxf_.endo_nbr-M_Hdpxf_.nstatic-M_Hdpxf_.npred-M_Hdpxf_.nboth)];
BHdpxf=oo_Hdpxf_.dr.ghu;
% BHdpxf_decl = Bf(oo_Hdpxf_.dr.inv_order_var,:) ;

y_DR_sh_dec = zeros(M_.endo_nbr,size(u_CORE4,2)+size(uf_CORE4,2),size(u_CORE4,1)); % dimensions: 1 = variables (64+3AUX) 2=periods (22+100) 3=shocks (13) 


for k=1:size(u_CORE4,1)/2
    
    Mk = zeros(size(u_CORE4,1),size(u_CORE4,1));
    Mk(k,k) = 1;
    y_DR_sh_dec(:,1,k) = B * Mk * u_CORE4(:,1);
    
    for j = 2:size(u_CORE4,2)
    y_DR_sh_dec(:,j,k) = A * y_DR_sh_dec(:,j-1,k) + B * Mk * u_CORE4(:,j);
    end
    
    MHdpxk = zeros(size(uf_CORE4,1),size(uf_CORE4,1));
    MHdpxk(k,k) = 1;
    MHdpxk(k+13,k+13) = 1;
    for j = size(u_CORE4,2)+1:size(u_CORE4,2)+size(uf_CORE4,2)

    y_DR_sh_dec(:,j,k) = AHdpxf * y_DR_sh_dec(:,j-1,k) + BHdpxf * MHdpxk * uf_CORE4(:,j-size(u_CORE4,2));
    end
    
end
y_sh_dec = y_DR_sh_dec(oo_.dr.inv_order_var,:,:);

y_sh_dec_re = nan(size(u_CORE4,1),size(u_CORE4,2)+size(uf_CORE4,2),M_.endo_nbr);

%_________________________REARRANGING
for k = 1:M_.endo_nbr
    for m = 1:size(u_CORE4,1)
        y_sh_dec_re(m,:,k) = y_sh_dec(k,:,m);
    end
end



end

