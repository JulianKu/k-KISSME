# repeat a vector x n-times over rows or columns
rep.row<-function(x,n){
    matrix(rep(x,each=n),nrow=n)
}
rep.col<-function(x,n){
    matrix(rep(x,each=n), ncol=n, byrow=TRUE)
}

    
calcDist = function(datA,datB, C)
{
    #Calculate the pairwise mahalanobis distance between all samples from dataset A and B 
    #according to the given inverse covariance
    # INPUT
    #   datA:       dataset A (d x n1)
    #   datB:       dataset B (d x n2)
    #   C:          inverse covariance matrix (d x d)
    # OUTPUT
    #   Mdist:      matrix of distances between all samples of datA and datB (n1 x n2) 
    
    
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
    
    # if one of the datasets is empty -> return 1D-array that is empty
    if (nA == 0 || nB == 0) {
        return(matrix(0L, nrow = nA, ncol = nB))
    } else {
        # compute Mahalanobis distance
        # note: (a-b)'C(a-b) = a'Ca + b'Cb - 2a'Cb
        
        #compute a'Ca for all a in A
        CA <- C %*% datA
        ACA <- colSums(datA*CA)
        #compute b'Cb for all b in B
        CB <- C %*% datB
        BCB <- colSums(datB*CB)
        
        # dist = a'Ca + b'Cb - 2a'Cb
        Mdist <- rep.col(ACA,nB) + rep.row(BCB,nA) - 2*t(datA) %*% CB
        rownames(Mdist) <- colnames(datA)
        colnames(Mdist) <- colnames(datB)
        return(Mdist)
    }
}


nlowest <- function(M,n.min) 
{
    #function that finds n (=rank) lowest elements in M
    
    O <- order(M)[1:n.min]
    rbind(O,M[O])
}


results = function(data, n_data, idxTest, C)
{
    #Get results for the distances between samples
    # INPUT
    #   data:       dataset
    #   idxTest:    indices of data to test
    #   C:          inverse covariance matrix (d x d)
    # OUTPUT
    #   Mdist:      matrix of distances between all samples of datA and datB (n1 x n2) 
    
    
    # splits up data according to camera viewpoint (cam_a and cam_b)
    datA <- data[ ,idxTest]
    datB <- data[ ,idxTest+n_data]
    # computes pairwise distances between both camera sets
    Mdist <- calcDist(datA, datB, C)
    return(Mdist)
}


rankedResults = function(Mdist, rank)
{
    #Sort results and return the by rank defined number of images for each image that have the lowest distance
    # INPUT
    #   Mdist:      matrix of distances
    #   rank:       number of samples with lowest distance that are to be taken into account
    # OUTPUT
    #   results:    data frame containing for every tested image from camera a 
    #               the images from camera b and corresponding distances that are lowest
    
    # for every image get the #rank others image that have the lowest distance (save image index and distance in dataframe)
    result <- as.data.frame(t(apply(Mdist,1,nlowest,n.min = rank)))
    # replace image index with image name (get names from column indices)
    result[,c(T,F)] <- colnames(Mdist)[unlist(result[,c(T,F)])]
    # name columns
    colnames(result) <- rep(c("image", "distance"), times = rank)
    return(result)
}

matches <- function(rankedDist, row) 
{
    #Returns ranked position of image from camera B that is a match for the image defined by row
    #if no match, returns NA
    
    key <- substr(row,start=1,stop=4)
    against <- substr(rankedDist[row,],start=1,stop=4)
    return(match(key,against) %/% 2 + 1)
}


score <- function(rankedDist)
{
    #Returns matching rate for given ranked distance in percent
    
    lMatches <- sapply(rownames(rankedDist), matches, rankedDist=rankedDist)
    score <- sum(!is.na(lMatches))/length(lMatches) * 100
    return(score)
}

