source("functions/kalman_update_diag.R")

kalman_filter_diag <- function(y, A, C, Q, R, init_x, init_V, ...) {
  
  # Kalman filter.
  # [x, V, VV, loglik] = kalman_filter(y, A, C, Q, R, init_x, init_V, ...)
  #
  # INPUTS:
  # y(:,t)   - the observation at time t
  # A - the system matrix
  # C - the observation matrix 
  # Q - the system covariance 
  # R - the observation covariance
  # init_x - the initial state (column) vector 
  # init_V - the initial state covariance 
  #
  # OPTIONAL INPUTS (string/value pairs [default in brackets])
  # 'model' - model(t)=m means use params from model m at time t [ones(1,T) ]
  #     In this case, all the above matrices take an additional final dimension,
  #     i.e., A(:,:,m), C(:,:,m), Q(:,:,m), R(:,:,m).
  #     However, init_x and init_V are independent of model(1).
  # 'u'     - u(:,t) the control signal at time t [ [] ]
  # 'B'     - B(:,:,m) the input regression matrix for model m
  #
  # OUTPUTS (where X is the hidden state being estimated)
  # x(:,t) = E[X(:,t) | y(:,1:t)]
  # V(:,:,t) = Cov[X(:,t) | y(:,1:t)]
  # VV(:,:,t) = Cov[X(:,t), X(:,t-1) | y(:,1:t)] t >= 2
  # loglik = sum{t=1}^T log P(y(:,t))
  #
  # If an input signal is specified, we also condition on it:
  # e.g., x(:,t) = E[X(:,t) | y(:,1:t), u(:, 1:t)]
  # If a model sequence is specified, we also condition on it:
  # e.g., x(:,t) = E[X(:,t) | y(:,1:t), u(:, 1:t), m(1:t)]
  
  os <- nrow(y)
  TT <- ncol(y)
  
  ss <- nrow(A) # size of state space
  
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
    } else if (args[[i]] == "ndx") {
      ndx <- args[[i+1]]
    } else {
      cat("Unrecognized argument")
      stop()
    }
  }
  
  x <- matrix(0, ss, TT)
  V <- array(0, dim = c(ss, ss, TT))
  VV <- array(0, dim = c(ss, ss, TT))
  
  loglik <- 0
  
  for (t in 1:TT) {
    m <- model[t]
    if (t == 1) {
      # prevx = init_x(:,m);
      # prevV = init_V(:,:,m);
      prevx <- init_x
      prevV <- init_V
      initial <- 1
    } else {
      prevx <- x[, t-1]
      prevV <- V[,, t-1]
      initial <- 0
    }
    if (all(is.na(u))) {
      res_ku_diag <- kalman_update_diag(A, C, Q, R[,,m], y[,t], prevx, prevV, "initial", initial)
      x[,t] <- res_ku_diag$xnew
      V[,,t] <- res_ku_diag$Vnew
      LL <- res_ku_diag$loglik
      VV[,,t] <- res_ku_diag$VVnew
    } else {
      if (all(is.na(ndx))) {
        res_ku_diag <- kalman_update_diag(A, C, Q, R[,,m], y[,t], prevx, prevV, 'initial', initial, 'u', u[,t], 'B', B)
        x[,t] <- res_ku_diag$xnew
        V[,,t] <- res_ku_diag$Vnew
        LL <- res_ku_diag$loglik
        VV[,,t] <- res_ku_diag$VVnew
      } else {
        i <- ndx[[t]]
        # copy over all elements; only some will get updated
        x[,t] <- prevx
        prevP <- solve(prevV)
        prevPsmall <- prevP[i,i]
        prevVsmall <- solve(prevPsmall)
        res_ku_diag <- kalman_update_diag(A[i,i], C[,i], Q[i,i], R[,,m], y[,t], prevx[i], prevVsmall, 'initial', initial, 'u', u[,t], 'B', B[i,])
        x[i,t] <- res_ku_diag$xnew
        smallV <- res_ku_diag$Vnew
        LL <- res_ku_diag$loglik
        VV[i,i,t] <- res_ku_diag$VVnew
      }
    }
    loglik <- loglik + LL
  }
  
  res_kf_diag <- list()
  res_kf_diag$x <- x
  res_kf_diag$V <- V
  res_kf_diag$VV <- VV
  res_kf_diag$loglik <- loglik

  return(res_kf_diag)
  
}