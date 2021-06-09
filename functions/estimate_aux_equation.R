estimate_aux_equation <- function(df_monthly, df_quarterly, dsge_m, dsge_q) {
  
  # A function for estimating the parameters of equation which connects
  # observables from a DSGE model (Y) to the monthly panel of auxiliary
  # indicators (X)
  # X = Gamma * Y + e, where R is the vcov matrix of observables
  # 
  # Input arguments:
  # "df" - a dataset of quarterly observables and monthly auxiliaries
  # "dsge_m" - a list w/ a monthly DSGE model
  # "dsge_q" - a list w/ a quarterly DSGE model
  # 
  # Output:
  # "dsge_m" - a list w/ a montly DSGE model combined with the parameters of
  # auxiliary equation (Gamma and R)
  # "dsge_q" - a list w/ a montly DSGE model combined with the parameters of
  # auxiliary equation (only R)
  
  # Create a standardized quarterly dataset for the estimation of Gamma
  Yq_std <- df_monthly %>% 
    dplyr::select(robs, dyobs, dpobs) %>% 
    mutate_all(na_if, 0) %>% 
    drop_na() %>% 
    as.matrix()
  Xq_std <- df_monthly %>% 
    mutate_all(na_if, 0) %>% 
    drop_na() %>% 
    dplyr::select(-robs, -dyobs, -dpobs) %>% 
    as.matrix()
  
  # Estimate Gamma
  Gamma <- solve(t(Yq_std) %*% Yq_std) %*% (t(Yq_std) %*% Xq_std) # standard OLS
  Gamma <- t(Gamma)
  
  # Adding Gamma to observation matrix C
  dsge_m$C <- rbind(dsge_m$C, unname(Gamma) %*% dsge_m$C)
  
  # Calculate R (variance of shocks of observed variables)
  R <- diag((t(Xq_std) %*% Xq_std) - (t(Xq_std) %*% Yq_std %*% t(Gamma))) / nrow(Xq_std)
  
  # Adding R to the models
  dsge_m$R <- diag(c(rep(1e+32, nrow(dsge_q$C)), unname(R)))
  dsge_m$R <- array(dsge_m$R, dim = c(nrow(dsge_m$R), ncol(dsge_m$R), nrow(df_monthly)))
  dsge_q$R <- diag(c(rep(1e+32, nrow(dsge_q$C), nrow(dsge_q$C))))
  dsge_q$R <- array(dsge_q$R, dim = c(nrow(dsge_q$C), nrow(dsge_q$C), nrow(df_quarterly)))
  
  temp <- df_monthly %>% 
    mutate_all(na_if, 0)
  
  ddf <- matrix(c(rep(1e-4, nrow(dsge_q$C)), unname(R)), nrow(df_monthly), ncol(df_monthly), byrow = TRUE)
  ddf[is.na(unname(temp))] <- 1e+32

  # Change R in monthly models
  for (i in 1:nrow(df_monthly)) {
    dsge_m$R[,,i] <- diag(ddf[i,])
  }
  
  temp <- df_quarterly %>% 
    mutate_all(na_if, 0)
  
  ddf <- matrix(rep(1e-4, nrow(dsge_q$C)), nrow(df_quarterly), ncol(df_quarterly), byrow = TRUE)
  ddf[is.na(unname(temp))] <- 1e+32
  
  # Change R in monthly models
  for (i in 1:nrow(df_quarterly)) {
    dsge_q$R[,,i] <- diag(ddf[i,])
  }
  
  res <- list(dsge_m = dsge_m, dsge_q = dsge_q)
  
  return(res)
  
}