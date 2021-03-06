#data preprocessing

shifter <- function(x, n = 1) {
    # shifts elements in an array by n places
    if (n == 0) x else c(tail(x, -n), head(x, n))
}

importfeat = function(directory)
{
    # import feature vectors from external file
    #
    # INPUT
    #   directory:  directory of feature vector data
    # OUTPUT
    #   feat:   named list of feature vectors for two cameras
    #     - a:      feature vectors of images from camera a
    #     - b:      feature vectors of images from camera b
    
    filename_a <-  sprintf("%s/lomo_cam_a.dat", directory)
    filename_b <-  sprintf("%s/lomo_cam_b.dat", directory)
    
    # read data and sort by filename
    features_a <- read.delim(filename_a, sep=",")
    features_b <- read.delim(filename_b, sep=",")
    features_a <- features_a[ , order(names(features_a))]
    features_b <- features_b[ , order(names(features_b))]
    
    feat <- list("a" = features_a, "b" = features_b)
    return(feat)
}

splitData = function(n_data, r_val, r_test)
{
    # split data into training and test set
    #
    # INPUT
    #   n_data: number of data samples
    #   r_val:  ratio of validation data regarding whole data set
    #   r_test: ratio of test data regarding whole data set
    #   (ratio of training data = 1 - r_val - r_test)
    # OUTPUT
    #   idx:   named list of index sets for training and test set
    #     - train:      index set for training data
    #     - validation: index set for validation data
    #     - test:       index set for test data
    
    # get number of data samples for each partial data set
    n_val <- round(r_val * n_data)
    n_test <- round(r_test * n_data)
    n_train <- n_data - n_val - n_test
    
    # random permutation
    perm <- sample(1:n_data)
    
    # create train and test indices
    idx_train <- perm[1:n_train]
    idx_val <- perm[(n_train+1):(n_train+n_val)]
    idx_test <- perm[-1:-(n_train+n_val)]
    
    idx <- list("train" = idx_train, "validation" = idx_val, "test" = idx_test)
    return(idx)
}

genConstraints = function(idx)
{ 
    # build the must- and cannot-link constraints from training data
    #
    # INPUT
    #   idx:    index set for which the constraints shall be built
    # OUTPUT
    #   cnstr:  named list for constraint links
    #     - S:      data frame for must-link constraints
    #     - D:      data frame for cannot-link constraints
    
    
    # must-link constraints (one to one matching between both viewpoint datasets)
    S <- data.frame(idx, idx)
    names(S) <- c("cam_a", "cam_b")
    
    # change indexes for the cannot-link constraints
    prmcrrct <- FALSE                           # flag if permutation is correct
    while (!prmcrrct) {
        perm <- sample(idx)                     # new permutation
        mask <- idx == perm                     # look for indexes that have not changed in the permutation
        if (sum(mask) > 1) {
            perm[mask] <- shifter(perm[mask])   # change unchanged samples
            prmcrrct <- TRUE
        } else if (sum(mask) == 0) {            # when changin not possible -> reshuffle
            prmcrrct <- TRUE
        }
    }
    # cannot-link constraints
    D <- data.frame(idx, perm)              
    names(D) <- c("cam_a", "cam_b")
    
    cnstr <- list("S" = S, "D" = D) 
    
    return(cnstr)
}