computeH = function(n,ib, ie)
{
    #Calculate the helper matrix H
    # INPUT
    #   n:          number of constraints
    #   ib:         indices of the first terms in constraint pairs (vector)
    #   ie:         indices of the second terms in constraint pairs (vector)
    # OUTPUT
    #   H:          the matrix H that satisfies Sigma = 1/n*X*H*X'
    
    
    library(Matrix)
    
    # calculate B and E - set the diaogonal with the count of occurences of an image in the constraints
    B <- Diagonal(x=tabulate(ib, n))
    E <- Diagonal(x=tabulate(ie, n))
    
    # initialise W with zeros
    W <- matrix(0,n,n)
    # calculate W - set the entry at position (i,j) to 1 if there exists a constraint for (i,j)
    W[ib + nrow(W) * (ie - 1)] <- 1
    
    # calculate H according to formulas in the paper
    H <- B + E - t(W) - W
    
    # enforce sparseness when returning the H matrix
    return(Matrix(H, sparse = TRUE))
}