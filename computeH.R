#Calculate the kernel matrix H
# INPUT
#   noTrainEx: the number of training examples
#   ib: indices of the first terms in pairs (vector)
#   ie: indices of the second terms in pairs (vector)
# OUTPUT
#    H: the matrix H that satisfies Sigma = 1/n*X*H*X'


calculateH = function(noTrainEx,ib, ie)
{
# initialisation
  B <- matrix(0,noTrainEx,noTrainEx) 
  E <- matrix(0,noTrainEx,noTrainEx)
  W <- matrix(0,noTrainEx,noTrainEx) 
  
  #Calculate B and E - set the diaogonal with the count of occurences
  for(i in 1:noTrainEx)
    B[i,i]=sum(ib == i)
    E[i,i]=sum(ie == i)
  
  #Calculate W
  for(i in 1:length(ib))
      W[ib[i],ie[i] ] <- W[ib[i],ie[i] ] + 1
  
  
  H <- B + E - t(W) - W    
  
  return <- H
}