
computeI = function(eps, n, H, K)
{
    # Helping matrix to compute the kernel
    #
    # INPUT
    #   eps:    epsilon for the regularizer
    #   n:      number of samples in corresponding constraint set (S or D)
    #   H:      H matrix of the corresponding constraint set (S or D)
    #   K:      kernel matrix
    # OUTPUT
    #   I:      helper matrix used for kernel computation
    A <- diag(dim(K)[1]) + 1/(n*eps) * K %*% H
    library(matlib)
    I <- (1 / (n*eps^2)) * H %*% Ginv(A)
    return(I)
}

kernel = function(eps, cnstr, K, pmetric)
{
    # Calculate the kernel
    #
    # INPUT
    #   eps:    epsilon for the regularizer
    #   dat:    named list containing must- (S) and cannot-link (D) constraints
    #   K:      the kernel matrix
    #   met:    Is it a metric?
    # OUTPUT
    #   C:      the matrix used for kernel
    
    
    D <- cnstr$D
    S <- cnstr$S
    
    # number of data samples
    n <- dim(K)[1]
    n0 <- dim(D)[1]
    n1 <- dim(S)[1]
    
    source("computeH.R")
    H0 <- computeH(n,as.matrix(D[1]),as.matrix(D[2]))
    H1 <- computeH(n,as.matrix(S[1]),as.matrix(S[2]))
    
    C <- computeI(eps,n0,H0,K) - computeI(eps,n1,H1,K)
    
    if (pmetric == TRUE) {
        print("projection for incremental update not implemented yet")
    }
    return(C)
}