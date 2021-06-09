kalman_update_diag <- function(A, C, Q, R, y, x, V, ...) {
  
  # KALMAN_UPDATE Do a one step update of the Kalman filter
  # [xnew, Vnew, loglik] = kalman_update(A, C, Q, R, y, x, V, ...)
  #
  # INPUTS:
  # A - the system matrix
  # C - the observation matrix 
  # Q - the system covariance 
  # R - the observation covariance
  # y(:)   - the observation at time t
  # x(:) - E[X | y(:, 1:t-1)] prior mean
  # V(:,:) - Cov[X | y(:, 1:t-1)] prior covariance
  #
  # OPTIONAL INPUTS (string/value pairs [default in brackets])
  # 'initial' - 1 means x and V are taken as initial conditions (so A and Q are ignored) [0]
  # 'u'     - u(:) the control signal at time t [ [] ]
  # 'B'     - the input regression matrix
  #
  # OUTPUTS (where X is the hidden state being estimated)
  #  xnew(:) =   E[ X | y(:, 1:t) ] 
  #  Vnew(:,:) = Var[ X(t) | y(:, 1:t) ]
  #  VVnew(:,:) = Cov[ X(t), X(t-1) | y(:, 1:t) ]
  #  loglik = log P(y(:,t) | y(:,1:t-1)) log-likelihood of innovatio
  
  # set default params
  u <- matrix()
  B <- matrix()
  initial <- 0
  
  args <- list(...)
  for (i in seq(1, length(args), 2)) {
    if (args[[i]] == "initial") {
      initial <- args[[i+1]]
    } else if (args[[i]] == "u") {
      u <- args[[i+1]]
    } else if (args[[i]] == "B") {
      B <- args[[i]]
    } else {
      cat("Unrecognized argument")
      stop()
    }
  }
  
  # xpred(:) = E[X_t+1 | y(:, 1:t)]
  # Vpred(:,:) = Cov[X_t+1 | y(:, 1:t)]
  
  if (initial) {
    if (all(is.na(u))) {
      xpred <- x
    } else {
      xpred <- x + B %*% u
    }
    Vpred <- V
  } else {
    if (all(is.na(u))) {
      xpred <- A %*% x
    } else {
      xpred <- A %*% x + B %*% u
    }
    Vpred <- A %*% V %*% t(A) + Q
  }
  
  # size(y)
  # size(C)
  # size(xpred)
  # pause
  e <- y - C %*% xpred # error (innovation)
  n <- length(e)
  ss <- nrow(A)
  
  d <- length(e)
  
  # size(C)
  # size(Vpred)
  # size(C*Vpred*C')
  # size(R)
  S <- C %*% Vpred %*% t(C) + R
  GG <- t(C) %*% diag(1 / diag(R)) %*% C
  Sinv <- diag(1 / diag(R)) - (diag(1 / diag(R)) %*% C %*% solve(diag(1, ss, ss) + Vpred %*% GG) %*% Vpred %*% t(C) %*% diag(1 / diag(R)))
  detS <- prod(diag(R)) * det(diag(1, ss, ss) + Vpred %*% GG)
  
  denom <- (2 * pi) ^ (d / 2) * sqrt(abs(detS))
  mahal <- colSums(t(e) %*% Sinv %*% e)
  loglik <- -0.5 * mahal - log(denom)
  
  K <- Vpred %*% t(C) %*% Sinv # Kalman gain matrix
  
  # If there is no observation vector, set K = zeros(ss).
  xnew <- xpred + K %*% e # csi_est(t\t) formula 13.6. 5    
  Vnew <- (diag(1, ss, ss) - K %*% C) %*% Vpred # P(t\t) formula 13.2.16 hamilton
  VVnew <- (diag(1, ss, ss) - K %*% C) %*% A %*% V
  
  # xnew, pause
  # Vnew, pause
  
  res_ku_diag <- list()
  res_ku_diag$xnew <- xnew
  res_ku_diag$Vnew <- Vnew
  res_ku_diag$loglik <- loglik
  res_ku_diag$VVnew <- VVnew
  
  return(res_ku_diag)
  
}