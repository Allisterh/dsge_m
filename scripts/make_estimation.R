# Preliminary part --------------------------------------------------------

# Load functions
source("functions/make_dataset.R")
source("functions/kalman_smoother_diag.R")

# Read monthly and quarterly models' matrices
load("data/dsge_q.Rds") # quarterly model
load("data/dsge_m.Rds") # monthly model

# Set a threshold (for estimation)
threshold <- "2011-03-01"

"data/data_dsge_m.xlsx" %>% 
  make_dataset()

# Create standardized dataset for Kalman filtering ------------------------

# Store values of mean and std
mean_std <- data %>% 
  dplyr::filter(date <= threshold) %>% 
  gather(key = "Indicator", value = "Value", -date) %>% 
  group_by(Indicator) %>% 
  summarise(mean_value = mean(Value, na.rm = T),
            std_value = sqrt(var(Value, na.rm = T)))

# Standardize dataset
data_std <- data %>% 
  dplyr::filter(date <= threshold) %>% 
  mutate_if(is.numeric, ~ (scale(.) %>% as.vector))

# Estimation of auxiliary equation ----------------------------------------

# Create standardized quarterly datasets for the estimation of Gamma
Yq_std <- data_std %>% 
  dplyr::select(robs, dyobs, dpobs) %>% 
  drop_na() %>% 
  as.matrix()
Xq_std <- data_std %>% 
  dplyr::filter(month(date) %% 3 == 0) %>% 
  dplyr::select(-date, -robs, -dyobs, -dpobs) %>% 
  drop_na() %>% 
  as.matrix()

# Estimate Gamma
Gamma <- solve(t(Yq_std) %*% Yq_std) %*% (t(Yq_std) %*% Xq_std) # standard OLS
Gamma <- t(Gamma)

# Adding Gamma to observation matrix C
dsge_m$C <- rbind(dsge_m$C, unname(Gamma) %*% dsge_m$C)
dsge_m$C <- array(dsge_m$C, dim = c(nrow(dsge_m$C), ncol(dsge_m$C), nrow(data_std)))

# Calculate R (variance of shocks of auxiliaries)
R <- diag((t(Xq_std) %*% Xq_std) - (t(Xq_std) %*% Yq_std %*% t(Gamma))) / nrow(Xq_std)

# Adding R to the models
dsge_m$R <- diag(c(rep(1e-4, nrow(dsge_q$C)), unname(R)))
dsge_m$R <- array(dsge_m$R, dim = c(nrow(dsge_m$R), ncol(dsge_m$R), nrow(data_std)))
dsge_q$R <- diag(c(rep(1e-4, nrow(dsge_q$C), nrow(dsge_q$C))))
dsge_q$R <- array(dsge_q$R, dim = c(nrow(dsge_q$C), nrow(dsge_q$C), nrow(Yq_std)))

# Change R in monthly models
for (i in 1:nrow(data_std)) {
  if (i %% 3 != 0) {
    dsge_m$R[,,i] <- diag(c(rep(1e+32, nrow(dsge_q$C)), unname(R)))
  }
  else {
    dsge_m$R[,,i] <- diag(c(rep(1e-4, nrow(dsge_q$C)), unname(R)))
  }
}

# Dataset for estimation --------------------------------------------------

# Make matrices A and Q as arrays
dsge_m$A <- array(dsge_m$A, dim = c(nrow(dsge_m$A), ncol(dsge_m$A), nrow(data_std)))
dsge_q$A <- array(dsge_q$A, dim = c(nrow(dsge_q$A), ncol(dsge_q$A), nrow(Yq_std)))
dsge_m$Q <- array(dsge_m$Q, dim = c(nrow(dsge_m$Q), ncol(dsge_m$Q), nrow(data_std)))
dsge_q$Q <- array(dsge_q$Q, dim = c(nrow(dsge_q$Q), ncol(dsge_q$Q), nrow(Yq_std)))

Zm <- data_std %>% 
  mutate(robs = replace_na(robs, 0),
         dyobs = replace_na(dyobs, 0),
         dpobs = replace_na(dpobs, 0)) %>% 
  dplyr::select(-date) %>% 
  as.matrix() %>% 
  unname()

# Estimation of unobserved states (Kalman Filter) -------------------------

res <- kalman_smoother_diag(t(Zm), dsge_m$A, dsge_m$C, dsge_m$Q, dsge_m$R, dsge_m$init_Xm, dsge_m$init_Vm, mchar = "model", smpl = 1:nrow(data_std))
plot(res$xsmooth[5,], type = 'l')
