# DEMO

# import functions
source("constraints.R")
source("kCovariance.R")
source("distance.R")
source("Visualization.R")

# directory of feature vectors
dir <- "LOMO\ Feature\ Extractor/data/VIPeR"

# import feature vectors from dat files
features <- importfeat(dir)
cam_a <- features$a
cam_b <- features$b

# number of data samples in data set
n_data <- dim(cam_a)[2]

# split data into training, validation and test set
idx <- splitData(n_data, r_val = 0.1, r_test = 0.1)
iTrain <- idx$train
iVal <- idx$validation
iTest <- idx$test

# concatenate both cameras into one set (whole data, training, validation and test set)
X <- cbind(as.matrix((cam_a)), as.matrix((cam_b)))
X_train <- cbind(as.matrix((cam_a[iTrain])), as.matrix((cam_b[iTrain])))
X_val <- cbind(as.matrix((cam_a[iVal])), as.matrix((cam_b[iVal])))
X_test <- cbind(as.matrix((cam_a[iTest])), as.matrix((cam_b[iTest])))

# generate must- and cannot-link constraints
cnstr <- genConstraints(iTrain)

library(kernlab)
# compute kernel matrix
#rbf <- rbfdot(sigma = 2^-16)
K <- kernelMatrix(vanilladot(), t(X))

# small regularization constant epsilon
eps <- 0.001

# compute inverse covariance matrix C
C <- kCovariance(eps, cnstr, K)

# compute pairwise distance between test images of both datasets
Mdist <- results(K, n_data, iTest, C)

#Compute different rank matching rates
ranks <- c(1,5,10,20)
nranks <- length(ranks)
rankedDists <- vector("list",nranks)
scores <- vector("list",nranks)
for (i in seq(1,nranks)) {
    # get n=rank lowest distances 
    rankedDists[[i]] <- rankedResults(Mdist, rank=ranks[i])
    # compute matching rate based on the samples with lowest distance
    scores[[i]] <- score(rankedDists[[i]])
    print(sprintf("Rank-%d Matching Rate: %.2f", ranks[i],scores[[i]]))
}

# PLOT
test_idx = c(1,2,3,4)
rank = 5
results <- rankedResults(Mdist, rank)
image_dataframe <- results[test_idx, c(T,F)]
plot_rank(image_dataframe, rank, dir)
