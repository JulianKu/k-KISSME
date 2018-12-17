pow10 <- function(x){10^x}

# DEMO
# import functions
source("constraints.R")
source("kCovariance.R")
source("distance.R")
source("Visualization.R")
source("validateHyperparameters.R")
source("testHyperparameter.R")

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

##-----------------------
#learn hyperparameters
##--------------------------
# generate must- and cannot-link constraints
cnstr <- genConstraints(iTrain)

library(kernlab)
# compute kernel matrix
#rbf <- rbfdot(sigma = 2^-16)
sigmas <- sapply(-10:10, pow10)
rbfs <- lapply(sigmas, function(sig){kernelMatrix(rbfdot(sigma = sig), t(X))})
names(rbfs) <- sapply(sigmas, function(sig){paste('RBF',sig)})
vanilla <-kernelMatrix(vanilladot(), t(X))
degrees <- 2:10
polys <- lapply(degrees, function(deg){kernelMatrix(polydot(degree = deg), t(X))})
names(polys) <- sapply(degrees, function(deg){paste('Poly',deg)})

Kernels <-c(list(Linear=vanilla),rbfs, polys)

# small regularization constant epsilon
#eps <- 0.001
epsVec <- sapply(seq(-7,0,0.5), pow10)

testK <- lapply(1:length(Kernels), function(k)
  {
    K <- Kernels[[k]]
    print(sprintf("Testing kernel %s", names(Kernels)[k]))
    test <- lapply(1:length(epsVec), function(e)
    {
      eps <- epsVec[e]
      print(sprintf("Testing epsilon %f", eps))    
      validateHyperparameters(cnstr,n_data, iVal, eps, K)
    })
    #print(test)
    return(test)
  })

hypparamResMat <-as.matrix(unlist(testK))
print("Training with Crossvalidation Results:")
print(hypparamResMat)

maxKcol <- which(hypparamResMat == max(hypparamResMat), arr.ind = TRUE)[1,1] %/% length(Kernels) + 1
epsMax <- epsVec[(which(hypparamResMat == max(hypparamResMat), arr.ind = TRUE)[1,1] - 1) %% length(Kernels) +1]
K <- Kernels[[maxKcol]]

print(sprintf("Kernel: %s", names(Kernels)[maxKcol]))
print(sprintf("Epsilon: %.12f ", epsMax))

testHyperparamter(cnstr,n_data, iTest, epsMax, K)

