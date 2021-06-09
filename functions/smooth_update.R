smooth_update <- function(xsmooth_future, Vsmooth_future, xfilt, Vfilt,  Vfilt_future, VVfilt_future, A, Q, B, u) {
  
  # One step of the backwards RTS smoothing equations.
  # function [xsmooth, Vsmooth, VVsmooth_future] = smooth_update(xsmooth_future, Vsmooth_future, ...
  #                                                xfilt, Vfilt,  Vfilt_future, VVfilt_future, A, B, u)
  #
  # INPUTS:
  # xsmooth_future = E[X_t+1|T]
  # Vsmooth_future = Cov[X_t+1|T]
  # xfilt = E[X_t|t]
  # Vfilt = Cov[X_t|t]
  # Vfilt_future = Cov[X_t+1|t+1]
  # VVfilt_future = Cov[X_t+1,X_t|t+1]
  # A = system matrix for time t+1
  # Q = system covariance for time t+1
  # B = input matrix for time t+1 (or [] if none)
  # u = input vector for time t+1 (or [] if none)
  #
  # OUTPUTS:
  # xsmooth = E[X_t|T]
  # Vsmooth = Cov[X_t|T]
  # VVsmooth_future = Cov[X_t+1,X_t|T]
  
  # xpred = E[X(t+1) | t]
  if (all(is.na(B))) {
    xpred <- A %*% xfilt
  } else {
    xpred <- A %*% xfilt + B %*% u
  }
  
  Vpred <- (A %*% Vfilt %*% t(A)) + Q # Vpred = Cov[X(t+1) | t]
  # Vfilt, pause
  J <- Vfilt %*% t(A) %*% pracma::pinv(Vpred) # smoother gain matrix
  xsmooth <- xfilt + (J %*% (xsmooth_future - xpred))
  Vsmooth <- Vfilt + (J %*% (Vsmooth_future - Vpred) %*% t(J))
  VVsmooth_future <- VVfilt_future + (Vsmooth_future - Vfilt_future) %*% pracma::pinv(Vfilt_future) %*% VVfilt_future
  
  res_sm_update <- list()
  res_sm_update$xsmooth <- xsmooth
  res_sm_update$Vsmooth <- Vsmooth
  res_sm_update$VVsmooth_future <- VVsmooth_future
  
  return(res_sm_update)
  
}