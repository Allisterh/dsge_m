# Load functions
"functions/" %>% 
  str_c(dir("functions/")) %>% 
  map(source)

# Loading and tidying (unstandardized) dataset 
data_raw <- "data/data_dsge_m.xlsx" %>% 
  make_dataset()

# Set a threshold (for estimation)
threshold <- seq(ymd("2011-03-01"), ymd("2019-12-01"), by = "3 months")

gdp_res <- as_tibble()
for (i in 1:(length(threshold)-1)) {
  # Read monthly and quarterly models' matrices
  load("data/dsge_q.Rds") # quarterly model
  load("data/dsge_m.Rds") # monthly model
  
  # Create a list w/ standardized datasets used as inputs in models
  data_std <- data_raw %>% 
    dplyr::filter(date <= threshold[i]) %>% 
    standardize_data(nfcst = 3)
  
  res <- estimate_aux_equation(data_std$Zm, data_std$Zq, dsge_m, dsge_q)
  dsge_m <- res$dsge_m
  dsge_q <- res$dsge_q
  rm(res)
  
  # Forecast of monthly model
  result_m <- kalman_smoother_diag(y = t(data_std$Zm), A = dsge_m$A, C = dsge_m$C,
                                   Q = dsge_m$Q, R = dsge_m$R, init_x = dsge_m$init_Xm,
                                   init_V = dsge_m$init_Vm, mchar = "model",
                                   smpl = 1:nrow(data_std$Zm))
  
  # Restore forecast of unstandardized values (monthly model)
  fcst_m <- (t(result_m$xsmooth) %*% t(dsge_m$C)) * data_std$SD_m + data_std$MZ_m
  
  # Forecast of quarterly model
  result_q <- kalman_smoother_diag(y = t(data_std$Zq), A = dsge_q$A, C = dsge_q$C,
                                   Q = dsge_q$Q, R = dsge_q$R, init_x = dsge_q$init_Xq,
                                   init_V = dsge_q$init_Vq, mchar = "model",
                                   smpl = 1:nrow(data_std$Zm))
  
  # Restore forecast of unstandardized values (quarterly model)
  fcst_q <- (t(result_q$xsmooth) %*% t(dsge_q$C)) * data_std$SD_q + data_std$MZ_q
  
  gdp <- data_raw %>% 
    dplyr::select(date, dyobs) %>% 
    .[1:nrow(fcst_m),] %>% 
    add_column(GDP_m = fcst_m[,2]) %>% 
    dplyr::filter(month(date) %% 3 == 0) %>% 
    add_column(GDP_q = fcst_q[,2]) %>% 
    gather(key = "Indicator", value = "Value", -date) %>% 
    dplyr::filter((date >= threshold[i])) %>% 
    add_column(fcst_date = rep(as_date(threshold[i]))) %>% 
    mutate(Indicator = as_factor(Indicator))
  gdp_res <- bind_rows(gdp_res, gdp)
  
  print(threshold[i])
}
