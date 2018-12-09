# DEMO


source("kernel.R")
source("constraints.R")
source("distance.R")

# directory of feature vectors
dir <- "LOMO\ Feature\ Extractor/data/VIPeR"

# import feature vectors from dat files
features <- importfeat(dir)
cam_a <- features$a
cam_b <- features$b

# number of data samples in data set
n_data <- dim(cam_a)[2]

# split data into training and test set
idx <- splitData(n_data, ratio = 0.5)
iTrain <- idx$train
iTest <- idx$test

X <- cbind(as.matrix((cam_a)), as.matrix((cam_b)))
X_train <- cbind(as.matrix((cam_a[iTrain])), as.matrix((cam_b[iTrain])))
X_test <- cbind(as.matrix((cam_a[iTest])), as.matrix((cam_b[iTest])))

# generate must- and cannot-link constraints
cnstr <- genConstraints(iTrain)

library(kernlab)
# compute kernel matrix
#rbf <- rbfdot(sigma = 2^-16)
K <- kernelMatrix(vanilladot(), t(X))

eps <- 0.001
pmetric <- FALSE
C <- kernel(eps, cnstr, K, pmetric)

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

