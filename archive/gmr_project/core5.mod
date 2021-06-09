@#define params = [ "beta", "theta_n", "theta_f", "h", "eta", "sigma", "gamma_ex", "alpha", "rho_ik", "k_dp", "k_y", "rho_rp", "theta_i", "rho_ystar", "rho_pstar", "rho_istar", "rho_yn", "rho_beta", "tau", "ksi", "psi_x", "rho_pxstar", "rho_ir", "istar_bar", "khi_h", "khi_n", "gamma_t", "gamma_f", "nu_exp", "nu_imp", "k_sf", "rho_yh", "rho_g", "gamma_g", "psi_g",  "rho_w", "theta_w", "khi_w", "eta_f", "phi_f", "theta_h", "khi_f", "rho_i"]
//                    1         2          3       4     5       6        7           8        9        10      11      12         13         14           15           16          17        18        19      20     21         22           23         24          25      26        27          28      29          30       31       32        33       34         35        36       37         38      39       40        41         42       43           

@#define exo = [ "ik", "rp", "irp", "ystar", "pstar", "istar", "yn", "beta", "pxstar", "ir", "yh", "g", "w", "ik1", "rp1", "irp1", "ystar1", "pstar1", "istar1", "yn1", "beta1", "pxstar1", "ir1", "yh1", "g1", "w1" ]
//                 1    2      3       4         5         6     7     8        9       10    11    12   13    14    15      16       17        18        19      20      21        22       23      24    25    26

@#define variables = [ "dpc", "dpn", "dpt", "dph", "dpf", "dpf_p", "pc", "pn", "pt", "ph", "pf", "pf_p", "c", "cn", "ct", "ch", "cf", "y", "yex", "i", "ik", "s", "rp", "mcn", "mch", "w", "n", "bstar", "ystar", "dpstar", "istar", "u_yn", "u_yh", "u_beta", "u_rp", "pxstar", "ir", "pstar", "g", "wp"] 
//                       1      2      3      4      5       6      7     8     9     10    11    12      13   14    15    16    17    18    19    20   21    22   23    24     25     26   27    28        29       30        31      32      33       34       35       36      37     38      39   40            

var 
	@#for v in variables
	@{v}  
	@#endfor
    ;

varexo
	@#for ex in exo
	eps_@{ex}  
	@#endfor
    ;

parameters 
	@#for p in params
	@{p}  
	@#endfor
	;

load parameterfile ;

@#for p in params
	set_param_value('@{p}',@{p});
	@#endfor

model (linear) ;
//__________________________________________________________________________________________________________________
//________________________________MAIN block________________________________________________________________________

c = 1 / (1 + h) * c(+1) + h / (1 + h) * c(-1) - (1 - h) / (1 + h) / sigma * (i - dpc(+1) - (1 - rho_beta) * u_beta); // 1 Euler equation
//w - pc = eta * n + sigma * ( 1 / (1 - h) * c - h / (1 - h) * c(-1)) + eps_w + eps_w1(-1); //                        2x Labor supply (Flexible wages)
w - w(-1) - khi_w * dpc(-1) = beta * (w(+1) - w - khi_w * dpc) + (1 - theta_w) * (1 - beta * theta_w) / theta_w * (eta * n + sigma * ( 1 / (1 - h) * c - h / (1 - h) * c(-1)) - w + pc) + eps_w + eps_w1(-1); // 2 Labor supply (Sticky wages)
i = beta / (1 + beta + (1 - theta_i) * (1 - beta * theta_i) / theta_i)  * i(+1) + ((1 - theta_i) * (1 - beta * theta_i) / theta_i) / (1 + beta + (1 - theta_i) * (1 - beta * theta_i) / theta_i) * ik + 1 / (1 + beta + (1 - theta_i) * (1 - beta * theta_i) / theta_i) * i(-1) + eps_irp + eps_irp1(-1); // 3 Calvo interest rates
//i = rho_i * i(-1) + (1 - rho_i) * ik +  + eps_irp + eps_irp1(-1); //                                                3b AR(2) for regional risk premia shock
ik = istar + (s(+1) - s) + rp; //                                                                                   4 UIP with risk premium
y = n + (gamma_g + (1 - gamma_ex - gamma_g) * (1 - gamma_t)) * u_yn + (1 - (gamma_g + (1 - gamma_ex - gamma_g) * (1 - gamma_t))) * u_yh; // 5 Production function (demand for labor)
y =  gamma_g * (g + psi_g * pxstar) + gamma_ex * yex + (1 - gamma_ex - gamma_g) * ((1 - gamma_t) * cn + gamma_t * (1 - gamma_f) * ch) ; //    6 Output distribution (main macroeconomic identity)
c = (1 - gamma_t) * cn + gamma_t * ct; //                                                                           7 Consumption aggregation
cn = c - alpha * (pn - pc); //                                                                                      8 Demand for nontradables
ch = ct - nu_imp * (ph - pt); //                                                                                    9 Demand for home tradables
cf = ct - nu_imp * (pf - pt); //                                                                                    10 Demand for foreign tradables

pc = (1 - gamma_t) * pn + gamma_t * pt; //                                                                          11 CPI definition
pn = pn(-1) + dpn; //                                                                                               12 Nontradable price index definition
pt = (1 - gamma_f) * ph + gamma_f * pf; //                                                                          13 Tradables price index definition
pf_p = pf_p(-1) + dpf_p; //                                                                                         14 Foreign goods PRODUCER price index definitioin
pf = (1 - eta_f) * pf_p + eta_f * pn;//                                                                             15 Foreign goods RETAIL price index definitioin
ph = ph(-1) + dph; //                                                                                               16 Home tradables price index definition

dpn - khi_n * dpc(-1) = beta * (dpn(+1) - khi_n * dpc) + ((1 - theta_n) * (1 - beta * theta_n) / theta_n) * mcn ; //17 Phillips curve for nontradables
dph - khi_h * dpc(-1) = beta * (dph(+1) - khi_h * dpc) + ((1 - theta_h) * (1 - beta * theta_h) / theta_h) * mch ; //18 Phillips curve for home tradables
dpf_p - khi_f * dpc(-1) = beta * (dpf_p(+1) - khi_f * dpc) + ((1 - theta_f) * (1 - beta * theta_f) / theta_f) * ((s + pstar - pf_p) * (1 - eta_f / ((1 - eta_f) * (phi_f - 1))) + eta_f / ((1 - eta_f) * (phi_f - 1)) * (pn - pf_p)) ; // 19 Phillips curve for imported goods with INCOMPLETE PASS-THROUGH
dpc = (1 - gamma_t) * dpn + gamma_t * dpt; //                                                                       20 CPI inflation definition
dpf = pf - pf(-1); //                                                                                               21 Foreign goods RETAIL inflation
dpt = pt - pt(-1); //                                                                                               22 Tradable goods inflation

mcn = w - pn + i - u_yn; //                                                                                         23 Marginal costs of 
mch = w - ph + i - u_yh; //                                                                                         24 Marginal costs of home tradables production

yex = (1 - psi_x) * (ystar - nu_exp * (ph - s - pstar)); //                                                         25 Real export defnontradables productioininition
k_sf * psi_x * pxstar + (1 - psi_x) * (pstar + ystar - nu_exp * (ph - s - pstar)) - (pstar + cf) + bstar(-1)*(1 + istar_bar) + ir(-1) - bstar - ir = 0; // 26 Balance of payments in nominal terms

rp = - ksi * pxstar - tau * (bstar+s) + u_rp; //                                                                    27 External risk premium dynamics
ik = rho_ik * ik(-1) + (1 - rho_ik) * (k_dp/4 * (dpc(+1) + dpc(+2) + dpc(+3) + dpc(+4)) +  k_y * y) + eps_ik + eps_ik1(-1); //   28 Taylor rule
                                                               
//__________________________________________________________________________________________________________________
//_______________________________EXOGENOUS block____________________________________________________________________
pstar = rho_pstar * pstar(-1) + eps_pstar + eps_pstar1(-1); //                                                      29 AR(1) of foreign price index
dpstar = pstar - pstar(-1); //                                                                                      30 Foreign inflation definition
ystar = rho_ystar * ystar(-1) + eps_ystar  + eps_ystar1(-1); //                                                     31 AR(1) of foreign output
istar = rho_istar * istar(-1) + eps_istar + eps_istar1(-1); //                                                      32 AR(1) of foreign interest rate
pxstar = rho_pxstar * pxstar(-1) + eps_pxstar + eps_pxstar1(-1); //                                                 33 AR(1) of oil price
u_yn = rho_yn * u_yn(-1) + eps_yn + eps_yn1(-1); //                                                                 34 AR(1) of TFP shock of nontradables
u_yh = rho_yh * u_yh(-1) + eps_yh + eps_yh1(-1); //                                                                 35 AR(1) of TFP shock of home tradables
u_rp = rho_rp * u_rp(-1) + eps_rp + eps_rp1(-1); //                                                                 36 AR(1) of external risk premium shock
u_beta = rho_beta * u_beta(-1) + eps_beta + eps_beta1(-1); //                                                       37 AR(1) of intertemporal shock
ir = rho_ir * ir(-1) + eps_ir + eps_ir1(-1); //                                                                     38 AR(1) of international reserves dynamics 
g = rho_g * g(-1) + eps_g + eps_g1(-1); //                                                                          39 AR(1) of government spending
wp = w - pc;  //                                                                                                    40 Real wage definition

end ;

check ;

shocks;

	@#for ex in exo
	var eps_@{ex} = var_eps_@{ex}; 
	@#endfor

end;

//stoch_simul(irf=16,order=1) y dpc ik yn dpcn ikn s sn;
//stoch_simul(irf=16,order=1) y dpc ph pf s ik c yex bstar yn dpcn phn pfn sn ikn cn yexn bstarn;
//stoch_simul(irf=16,order=1) yex cf s rp bstar ik i y dpc yexn cfn sn rpn bstarn ikn in yn dpcn ph pf pc phn pfn pcn;
//stoch_simul(irf=100,order=1) s ik y wp dpc pc rp bstar;


estimated_params ;


    stderr eps_ik,              uniform_PDF,,,0,2 ;
    stderr eps_rp,              uniform_PDF,,,0,2 ;
    stderr eps_irp,             uniform_PDF,,,0,2 ;
    stderr eps_yn,              uniform_PDF,,,0,2 ;
//    stderr eps_yn,              gamma_PDF,0.05,0.05 ;
//    stderr eps_yh,              gamma_PDF,0.05,0.05 ;
    stderr eps_w,               uniform_PDF,,,0,2 ;
    stderr eps_beta,            uniform_PDF,,,0,2 ;
    stderr eps_ystar,           uniform_PDF,,,0,2 ;
    stderr eps_pstar,           uniform_PDF,,,0,2 ;
    stderr eps_istar,           uniform_PDF,,,0,2 ; 
    stderr eps_pxstar,          uniform_PDF,,,0,2 ; 
    stderr eps_g,               uniform_PDF,,,0,2 ;

//    psi_x,                      gamma_PDF,0.3,0.1;
//    psi_x,                      uniform_PDF,,,0,1; // 
    psi_g,                      normal_PDF,0.4,0.04; // 1 was 0.4,0.04
//    psi_g,                      uniform_PDF,,,0,1;
    ksi,                        normal_PDF,0.05,0.01; // 2 was 0.1,0.01
//    ksi,                        uniform_PDF,,,0,1;    
//    tau,                        gamma_PDF,0.03,0.03; //
//    tau,                        uniform_PDF,,,0,1;
 
    h,                          beta_PDF,0.4,0.05 ; // 3
//    h,                          uniform_PDF,,,0,1;

//    theta_n,                    beta_PDF,0.75,0.03 ;
//    theta_h,                    beta_PDF,0.75,0.03 ;
    theta_f,                    beta_PDF,0.6,0.03 ; // 9
    theta_w,                    beta_PDF,0.5,0.03 ; // 10
    theta_i,                    beta_PDF,0.5,0.1 ; // 13
//    theta_i,                    beta_PDF,0.5,0.2 ;
//    theta_i,                    uniform_PDF,,,0,1;
//    theta_f,                    uniform_PDF,,,0,1;
//    theta_n,                    uniform_PDF,,,0,1;
//    theta_w,                    uniform_PDF,,,0,1;

    alpha,                      gamma_PDF,0.66,0.06 ; // 8 
//    alpha,                      uniform_PDF,,,0,10;
    nu_exp,                     gamma_PDF,0.2,0.03 ; // 4
    nu_imp,                     gamma_PDF,1,0.1 ; // 5
//    nu_exp,                     uniform_PDF,,,0,10;  
//    nu_imp,                     uniform_PDF,,,0,10;      
    eta,                        gamma_PDF,1,0.1 ; // 6
    sigma,                      gamma_PDF,2,0.2 ; // 7
//    psi_g,                      uniform_PDF,,,0,1;

//    rho_pxstar,                 beta_PDF,0.9,0.1 ;
//    rho_ystar,                  beta_PDF,0.8,0.2 ;
    rho_pstar,                  beta_PDF,0.2,0.1 ;
    rho_istar,                  beta_PDF,0.6,0.1 ;
    rho_rp,                     beta_PDF,0.6,0.05 ; 
    rho_beta,                   beta_PDF,0.2,0.1 ;
    rho_yn,                     beta_PDF,0.2,0.1 ;
//    rho_irp,                    beta_PDF,0.5,0.2 ;
//    rho_i,                      beta_PDF,0.5,0.2 ;
//    rho_irp,                    beta_PDF,0.5,0.1 ;
    rho_yh,                     beta_PDF,0.2,0.1 ; // 14

    k_dp,                       normal_PDF,2,0.2; // 11
    k_y,                        normal_PDF,0.05,0.01 ; // 12
//    rho_ik,                      beta_PDF,0.7,0.1 ;

    khi_n,                      beta_PDF,0.5,0.05 ; // 15
    khi_h,                      beta_PDF,0.5,0.05 ; // 16
    khi_f,                      beta_PDF,0.5,0.05 ; // 17
    khi_w,                      beta_PDF,0.5,0.1 ; // 18
//    rho_yh,                     beta_PDF,0.5,0.2 ;
//    khi_f,                      uniform_PDF,,,0,1; //
//    khi_w,                      uniform_PDF,,,0,1;
//    khi_n,                      uniform_PDF,,,0,1; //

//    k_sf,                       beta_PDF,0.5,0.2 ;
//    eta_f,                      uniform_PDF,,,0,1; //

eta_f,                          beta_PDF,0.3,0.05; // 19

end ;

//varobs ystar dpstar istar pxstar s y ik dpc; 
varobs pxstar ystar dpstar istar s ik dpc y i wp g; // wp y i istar 
//varobs pxstar ystar istar dpstar y;


estimated_params_init;

theta_h,        0.75 ;
theta_f,        0.6;
theta_i,        0.5;
theta_n,        0.75;
eta,            1 ;
sigma,          2 ;
gamma_ex,       0.1697 ;
alpha,          1 ;
tau,            0.00001;
//nu_exp,         0.66;
//nu_imp,         0.66;
ksi,            0.1;
psi_g,          0.4;
k_dp,           2 ;
k_y,            0.05 ;
//k_dpstar,       1.5 ;
//k_ystar,        0.125 ;
rho_ik,         0.7;
psi_x,          0.3;
//rho_irp,        0.9;
eta_f,          0.3;
k_sf,           0.1;

end;



//estimation(datafile=Rusdata_1019_detr5Rus_ikN60,mode_compute=5,presample=0,first_obs=17,prefilter=0,mh_replic=0000,mh_nblocks=1,mh_jscale=0.2,mh_drop=0.2,order=1,plot_priors=0,lik_init=2,mode_check) dpc ; // load_mh_file,mode_file=Mode_core4D_newtm_N65
//estimation(datafile=VVdata_1019_detr5_ikN60,mode_compute=5,presample=0,first_obs=17,prefilter=0,mh_replic=0000,mh_nblocks=1,mh_jscale=0.2,mh_drop=0.2,order=1,plot_priors=0,lik_init=2,mode_check) dpc ; // load_mh_file,mode_file=Mode_core4D_newtm_N65
estimation(datafile=VVdata_1019_detr6,mode_compute=5,presample=0,first_obs=17,prefilter=0,mh_replic=0000,mh_nblocks=1,mh_jscale=0.2,mh_drop=0.2,order=1,plot_priors=0,lik_init=2,mode_check) dpc ; // load_mh_file,mode_file=Mode_core4D_newtm_N65


check ;

stoch_simul(irf=50,order=1,nograph) s pc pf_p ph pn y c cn ch yex cf ik dpc istar i pxstar wp g ystar istar;
shock_decomposition(parameter_set=posterior_mode) y s dpc ik i pxstar ystar istar dpstar c yex wp g;

