source("functions/kalman_filter_diag.R")
source("functions/smooth_update.R")

kalman_smoother_diag <- function(y, A, C, Q, R, init_x, init_V, ...) {
  
  # Kalman/RTS smoother.
  # [xsmooth, Vsmooth, VVsmooth, loglik] = kalman_smoother(y, A, C, Q, R, init_x, init_V, ...)
  #
  # The inputs are the same as for kalman_filter.
  # The outputs are almost the same, except we condition on y(:, 1:T) (and u(:, 1:T) if specified),
  # instead of on y(:, 1:t).
  
  os <- nrow(y)
  TT <- ncol(y) 
  ss <- nrow(A)
  
  # set default params
  model <- rep(1, TT)
  u <- matrix()
  B <- matrix()
  ndx <- matrix()
  
  args <- list(...)
  nargs <- length(args)
  for (i in seq(1, nargs, 2)) {
    if (args[[i]] == "model") {
      model <- args[[i+1]]
    } else if (args[[i]] == "u") {
      u <- args[[i+1]]
    } else if (args[[i]] == "B") {
      B <- args[[i+1]]
    }
    else {
      cat("Unrecognized argument")
      stop()
    }
  }
  
  xsmooth <- matrix(0, ss, TT)
  Vsmooth <- array(0, dim = c(ss, ss, TT))
  VVsmooth <- array(0, dim = c(ss, ss, TT))
  
  # Forward pass
  res_kf_diag <- kalman_filter_diag(y, A, C, Q, R, init_x, init_V, mchar = "model", model = model, uchar = "u", u = u, Bchar = "B", B = B) #, 'u', u, 'B', B)
  xfilt <- res_kf_diag$x
  Vfilt <- res_kf_diag$V
  loglik <- res_kf_diag$loglik
  VVfilt <- res_kf_diag$VV

  # Backward pass
  xsmooth[,TT] <- xfilt[,TT]
  Vsmooth[,,TT] <- Vfilt[,,TT]
  # VVsmooth(:,:,T) = VVfilt(:,:,T);
  
  for (t in (TT-1):1) {
    m <- model[t+1]
    if (all(is.na(B))) {
      res_sm_update <- smooth_update(xsmooth[,t+1], Vsmooth[,,t+1], xfilt[,t], Vfilt[,,t], Vfilt[,,t+1], VVfilt[,,t+1], A, Q, matrix(), matrix())
      xsmooth[,t] <- res_sm_update$xsmooth
      Vsmooth[,,t] <- res_sm_update$Vsmooth
      VVsmooth[,,t+1] <- res_sm_update$VVsmooth_future
    } else {
      res_sm_update <- smooth_update(xsmooth[,t+1], Vsmooth[,,t+1], xfilt[,t], Vfilt[,,t], Vfilt[,,t+1], VVfilt[,,t+1], A, Q, B, u[,t+1])
      xsmooth[,t] <- res_sm_update$xsmooth
      Vsmooth[,,t] <- res_sm_update$Vsmooth
      VVsmooth[,,t+1] <- res_sm_update$VVsmooth_future
    }
  }
  
  VVsmooth[,,1] <- matrix(0, ss, ss)
  
  res_ks_diag <- list()
  res_ks_diag$xsmooth <- xsmooth
  res_ks_diag$Vsmooth <- Vsmooth
  res_ks_diag$VVsmooth <- VVsmooth
  res_ks_diag$loglik <- loglik
  
  return(res_ks_diag)
  
}