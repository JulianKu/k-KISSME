# repeat a vector x n-times over rows or columns
rep.row<-function(x,n){
    matrix(rep(x,each=n),nrow=n)
}
rep.col<-function(x,n){
    matrix(rep(x,each=n), ncol=n, byrow=TRUE)
}

#Calculate the pairwise mahalanobis distance between all samples from dataset A and B 
#according to the given inverse covariance
# INPUT
#   datA:       dataset A (d x n1)
#   datB:       dataset B (d x n2)
#   C:          inverse covariance matrix (d x d)
# OUTPUT
#   Mdist:      matrix of distances between all samples of datA and datB (n1 x n2)     

calcDist = function(datA,datB, C)
{
    # get input dimensions
    dimA <- dim(datA)
    dA <- dimA[1]
    nA <- dimA[2]
    dimB <- dim(datB)
    dB <- dimB[1]
    nB <- dimB[2]
    dC <- dim(C)[1]
    # assert if dimensions match
    stopifnot(exprs = { dA == dB; dA == dC })
    
    # (a-b)'C(a-b) = a'Ca + b'Cb - 2a'Cb
    if (nA == 0 || nB == 0) {
        return(matrix(0L, nrow = nA, ncol = nB))
    } else {
        # compute Mahalanobis distance
        # note: (a-b)'C(a-b) = a'Ca + b'Cb - 2a'
        
        #compute a'Ca for all a in A
        CA <- C %*% datA
        ACA <- colSums(datA*CA)
        #compute b'Cb for all b in B
        CB <- C %*% datB
        BCB <- colSums(datB*CB)
        
        Mdist <- rep.col(ACA,nB) + rep.row(BCB,nA) - 2*t(datA) %*% CB
        return(Mdist)
    }
}

#function that finds n (=rank) lowest elements in M
nlowest <- function(M,n.min) 
{
    O <- order(M)[1:n.min]
    rbind(O,M[O])
}

#Get results for the distances between samples
# INPUT
#   data:       dataset
#   idxTest:    indices of data to test
#   C:          inverse covariance matrix (d x d)
#   rank:       number of samples with lowest distance that are to be taken into account
# OUTPUT
#   results:    data frame containing for every tested image from camera a 
#               the images from camera b and corresponding distances that are lowest

results = function(data, n_data, idxTest, C, rank)
{
    datA <- data[ ,idxTest]
    datB <- data[ ,idxTest+n_data]
    Mdist <- calcDist(datA, datB, C)
    result <- as.data.frame(t(apply(Mdist,1,nlowest,n.min = rank)))
    result[,c(T,F)] <- colnames(Mdist)[unlist(result[,c(T,F)])]
    colnames(result) <- rep(c("image", "distance"), times = rank)
    return(result)
}

