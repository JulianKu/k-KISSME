#preprocesses the data 

shifter <- function(x, n = 1) {
    # shifts elements in an array by n places
    if (n == 0) x else c(tail(x, -n), head(x, n))
}

importfeat = function(directory)
{
    # import feature vectors form external file
    #
    # INPUT
    #   dir:    directory of feature vector data
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

splitData = function(n_data, ratio)
{
    # split data into training and test set
    #
    # INPUT
    #   n_data: number of data samples
    #   ratio:  ration of training data regarding whole data set (test ratio = 1 train ratio)
    # OUTPUT
    #   idx:   named list of index sets for training and test set
    #     - train:      index set for training data
    #     - test:       index set for test data
    
    half_data <- round(ratio * n_data)
    
    # random permutation
    perm <- sample(1:n_data)
    
    # create equal sized train and test indexes
    idx_train <- perm[1:half_data]
    idx_test <- perm[-1:-half_data]
    
    idx <- list("train" = idx_train, "test" = idx_test)
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
    
    
    # must-link constraints
    S <- data.frame(idx, idx)
    names(S) <- c("cam_a", "cam_b")
    
    # change indexes for the cannot-link constraints
    prmcrrct <- FALSE                                  # flag if permutation is correct
    while (!prmcrrct) {
        perm <- sample(idx)                     # new permutation
        mask <- idx == perm                     # look for indexes that have not changed in the permutation
        if (sum(mask) > 1) {
            perm[mask] <- shifter(perm[mask])
            prmcrrct <- TRUE
        } else if (sum(mask) == 0) {
            prmcrrct <- TRUE
        }
    }
    D <- data.frame(idx, perm)              # cannot-link constraints
    names(D) <- c("cam_a", "cam_b")
    
    cnstr <- list("S" = S, "D" = D) 
    
    return(cnstr)
}
####################################################### EXAMPLES ####################################################

# # example how to access the training data (permutated training data)
# train_a <- features_a[,c(idx_train)]
# 
# # view the first must-link constraint
# x1 <- S[1, c("cam_a")]
# x2 <- S[1, c("cam_b")]
# 
# x1_name <- colnames(features_a)[x1]
# x2_name <- colnames(features_b)[x2]
# 
# library('bmp')
# pic <- read.bmp(sprintf("%s/cam_a/%s", directory, substring(x1_name, 2)))
# 
# m <- as.raster(pic, max = 255)
# plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
# usr <- par("usr")
# rasterImage(m, usr[1], usr[3], usr[2], usr[4])
# 
# pic <- read.bmp(sprintf("%s/cam_b/%s", directory, substring(x2_name, 2)))
# 
# m <- as.raster(pic, max = 255)
# plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
# usr <- par("usr")
# rasterImage(m, usr[1], usr[3], usr[2], usr[4])
# 
# ####
# 
# #view the first cannot-link constraint
# x1 <- D[1, c("cam_a")]
# x2 <- D[1, c("cam_b")]
# 
# x1_name <- colnames(features_a)[x1]
# x2_name <- colnames(features_b)[x2]
# 
# pic <- read.bmp(sprintf("%s/cam_a/%s", directory, substring(x1_name, 2)))
# 
# m <- as.raster(pic, max = 255)
# plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
# usr <- par("usr")
# rasterImage(m, usr[1], usr[3], usr[2], usr[4])
# 
# pic <- read.bmp(sprintf("%s/cam_b/%s", directory, substring(x2_name, 2)))
# 
# m <- as.raster(pic, max = 255)
# plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
# usr <- par("usr")
# rasterImage(m, usr[1], usr[3], usr[2], usr[4])
           
