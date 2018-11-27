# DEMO


source("kernel.R")
source("constraints.R")

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
train <- idx$train
test <- idx$test

X_train <- cbind(as.matrix((cam_a[train])), as.matrix((cam_b[train])))
X_test <- cbind(as.matrix((cam_a[test])), as.matrix((cam_b[test])))

# generate must- and cannot-link constraints
cnstr <- genConstraints(train)

library(kernlab)
# compute kernel matrix
rbf <- rbfdot(sigma = 2^-16)
K <- kernelMatrix(rbf, t(X_train))

eps <- 0.001
pmetric <- FALSE
result <- kernel(eps, cnstr, K, pmetric)