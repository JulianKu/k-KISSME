
computeI = function(n, eps, H, K)
{
    #Easy computation of inverse of type (eI +(1-e) )
    
    
}

kernel = function(eps, cnstr, K, pmetric)
{
    #Calculate the kernel
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
    H0 <- computeH(n,D[1],D[2])
    H1 <- computeH(n,S[1],S[2])
    
    C <- 
    
}