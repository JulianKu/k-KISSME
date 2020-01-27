computeI = function(eps, n, H, K)
{
    # Helping matrix to compute the covariance matrix
    #
    # INPUT
    #   eps:    epsilon for the regularizer
    #   n:      number of samples in corresponding constraint set (S or D)
    #   H:      H matrix of the corresponding constraint set (S or D)
    #   K:      kernel matrix
    # OUTPUT
    #   I:      helper matrix used for covariance matrix computation
    library(matlib)
    library(Matrix)
    
    # computation of the helper matrix according to formulas given by the paper
    # enforce sparseness
    A <- Diagonal(n=dim(K)[1]) + 1/(n*eps) * K %*% H
    I <- (1 / (n*eps^2)) * H %*% solve(A, sparse = TRUE)
    return(Matrix(I, sparse = TRUE))
}

kCovariance = function(eps, cnstr, K)
{
    # Calculate the inverse covariance matrix
    #
    # INPUT
    #   eps:    epsilon for the regularizer
    #   cnstr:  named list containing must- (S) and cannot-link (D) constraints
    #   K:      the kernel matrix
    # OUTPUT
    #   C:      covariance matrix used for distance metric
    
    source("computeH.R")
    
    # get must- and cannot-link constraints
    D <- cnstr$D
    S <- cnstr$S
    
    # number of data samples and constraints
    n <- dim(K)[1]
    n0 <- dim(D)[1]
    n1 <- dim(S)[1]
    
    # compute H matrix for both constraint types
    H0 <- computeH(n,as.matrix(D[1]),as.matrix(D[2]))
    H1 <- computeH(n,as.matrix(S[1]),as.matrix(S[2]))
    
    # compute covariance matrix according to formulas given by the paper
    C <- computeI(eps,n0,H0,K) - computeI(eps,n1,H1,K)
    
    # enforce sparseness when returning the covariance matrix
    return(Matrix(C, sparse = TRUE))
}