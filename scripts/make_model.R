# Preliminary part --------------------------------------------------------

# Read dynare output
nk_model <- "data/nk_model.mat" %>% 
  readMat()

# Extract matrices of state space form in Dynare: Y_t = A * Y_t-1 + B * eps_t 
A <- nk_model$oo.[[4]][[8]]
B <- nk_model$oo.[[4]][[9]]

# Bind additional rows and columns in a transition equation:
# for pi_t, y_t, y_t-1 and trend growth (assumed to follow a RW process)
A_new <- rbind(
  cbind(A, rep(0, 6), rep(0, 6), rep(0, 6)),
  c(rep(0, 6), 1)
  )
B_new <- rbind(
  cbind(B, rep(0, 6)),
  c(rep(0, 3), 1)
  )

# Check existence of the monthly state space form --------------------------

# For translating a s.space form to monthly equivalent, we have to check
# the existence and uniqueness of the cube root of matrix A
V <- eigen(A_new)$vectors # eigenvectors
D <- eigen(A_new)$values # eigenvalues

# Change order of eigenvectors in a matrix
V <- cbind(V[,6:7], V[,3], V[,2], V[,5], V[,4], V[,1])

# Change order of values in eigenvalues vector and make it a diagonal matrix
D <- c(D[6:7], D[3], D[2], D[5], D[4], D[1])
D <- diag(D)

# Check existence (that V is invertible)
if (nrow(V) > rankMatrix(V)[1]) {
  cat("V does not have full rank!")
  cat(
    str_c("The size of V = ", nrow(V), ", but rank(V) = ", rankMatrix(V)[1])
    )
}

# Check unicity
if (!all(Re(diag(D)) >= 0)) {
  cat("These eigenvalues lie in the negative part of the real axis")
}
D[abs(D) < 1e-10] <- 1e-10

# Derive the cube root of matrix A
A_sm <- V %*% D ^ (1/3) %*% solve(V)
if (any(Im(A_sm) > 1e-8)) {
  cat("This cube root is not real!")
  A_sm <- Re(A_sm)
}
A_sm[A_new == 0] <- 0

# Define a quarterly state space form -------------------------------------

# Adding rows and columns corresponding to the lagged output
A_q <- rbind(
  cbind(A_new, rep(0, 7)),
  c(0, 0, 0, 0, 1, 0, 0, 0)
  )

# Q_q --- covariance of the shocks in the transition equation
B_q <- rbind(B_new, rep(0, ncol(B_new)))
Q_q <- B_q %*% t(B_q)

# Define the selection matrix for the observation equation
C_q <- rbind(
  rep(0, ncol(A_q)), rep(0, ncol(A_q)), rep(0, ncol(A_q))
  )
C_q[1, 1] <- 1 # rate gap at period t
C_q[3, 6] <- 1 # inflation gap at period t
C_q[2, 5] <- 1 # output gap at period t
C_q[2, 7] <- 1 # trend part of growth at period t
C_q[2, 8] <- -1 # output gap at period t-1

# Define a monthly state space form ---------------------------------------

# Matrix A of transition equation
A_m <- rbind(
  cbind(A_sm, rep(0, 7), rep(0, 7), rep(0, 7)),
  c(0, 0, 0, 0, 1, 0, 0, 0, 0, 0),
  c(0, 0, 0, 0, 0, 0, 0, 1, 0, 0),
  c(0, 0, 0, 0, 0, 0, 0, 0, 1, 0)
)



# Derive monthly equivalent of matrix B (see GMR, 2016)
BminMonthly <- solve((A_sm %*% A_sm) + A_sm + diag(nrow(A_sm))) %*% B_new
B_m <- rbind(BminMonthly, rep(0, 4), rep(0, 4), rep(0, 4))

# Covariance matrix of shocks
Q_m <- B_m %*% t(B_m)

# Define the selection matrix for the observation equation
C_m <- rbind(
  rep(0, ncol(A_m)), rep(0, ncol(A_m)), rep(0, ncol(A_m))
  )
C_m[1, 1] <- 1 # rate gap at period t
C_m[3, 6] <- 1 # inflation gap at period t
C_m[2, 5] <- 1 # output gap at period t
C_m[2, 7] <- 1 # trend part of growth at period t
C_m[2, 10] <- -1 # output gap at period t-1

# Matrices for Kalman smoother
# dsge_q
initXq <- rep(0, ncol(A_q)) # vector of initial values of observables
initVq <- diag(ncol(A_q)) * 10 # initial vcov matrix
# dsge_m
initXm <- rep(0, ncol(A_m)) # vector of initial values of observables
initVm <- diag(ncol(A_m)) * 10 # initial vcov matrix

# Save the result matrices ------------------------------------------------

# quarterly model
dsge_q <- list(C = C_q, A = A_q, B = B_q, Q = Q_q, init_Xq = initXq, init_Vq = initVq)
# monthly model
dsge_m <- list(C = C_m, A = A_m, B = B_m, Q = Q_m, init_Xm = initXm, init_Vm = initVm)

save(dsge_q, file = "data/dsge_q.Rds") # quarterly model
save(dsge_m, file = "data/dsge_m.Rds") # monthly model
