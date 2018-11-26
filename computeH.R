#Calculate the helper matrix H
# INPUT
#   noTrainEx:  the number of training examples
#   ib:         indices of the first terms in pairs (vector)
#   ie:         indices of the second terms in pairs (vector)
# OUTPUT
#   H:          the matrix H that satisfies Sigma = 1/n*X*H*X'

calculateH = function(noTrainEx,ib, ie)
{
    # initialisation
    W <- matrix(0,noTrainEx,noTrainEx) 
    
    #Calculate B and E - set the diaogonal with the count of occurences
    B <- diag(tabulate(ib, noTrainEx))
    E <- diag(tabulate(ie, noTrainEx))
    
    #Calculate W
    W[ib + nrow(W) * (ie - 1)] <- 1
    
    
    H <- B + E - t(W) - W    
    
    return <- H
}