# Preliminary part --------------------------------------------------------

# Load functions
"functions/" %>% 
  str_c(dir("functions/")) %>% 
  map(source)

# Read monthly and quarterly models' matrices
load("data/dsge_q.Rds") # quarterly model
load("data/dsge_m.Rds") # monthly model

# Set a threshold (for estimation)
threshold <- "2011-03-01"

# Prepare a dataset for estimation ----------------------------------------

# Loading and tidying (unstandardized) dataset 
data_raw <- "data/data_dsge_m.xlsx" %>% 
  make_dataset()

# Create a list w/ standardized datasets used as inputs in models
data_std <- data_raw %>% 
  dplyr::filter(date <= threshold) %>% 
  standardize_data(nfcst = 12)

# Estimation of auxiliary equation used in a monthly model ----------------

res <- estimate_aux_equation(data_std$Zm, data_std$Zq, dsge_m, dsge_q)
dsge_m <- res$dsge_m
dsge_q <- res$dsge_q
rm(res)

# Estimation of unobserved states (Kalman Filter) -------------------------

# Forecast of monthly model
result_m <- kalman_smoother_diag(y = t(data_std$Zm), A = dsge_m$A, C = dsge_m$C,
                                Q = dsge_m$Q, R = dsge_m$R, init_x = dsge_m$init_Xm,
                                init_V = dsge_m$init_Vm, mchar = "model",
                                smpl = 1:nrow(data_std$Zm))

# Restore forecast of unstandardized values
fcst <- (t(result_m$xsmooth) %*% t(dsge_m$C)) * data_std$SD_m + data_std$MZ_m
plot(fcst[,2], type = 'l') # plot GDP growth
GDP_m <- fcst[,2]
