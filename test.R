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
vanKern <-kernelMatrix(vanilladot(), t(X))
rbfKern <-kernelMatrix(rbfdot(), t(X))
polyKern <-kernelMatrix(polydot(), t(X))

kKernel <-list(vanKern,rbfKern, polyKern)

#K <- kernelMatrix(vanilladot(), t(X))

# small regularization constant epsilon
#eps <- 0.001
epsT1 <- sapply(1:12, function(x){10^-x})
epsT2 <- seq(from = 10^(-6), to = 10^-3, by = (5*10^-5))
#epsT3 <-seq(from = 10^-3, to = 1 ,by = 5*10^-2)
epsVec <-c(epsT1, epsT2)

epsVec <-sample(epsVec,100)
print(epsVec)



testK <-lapply(kKernel, function(e)
  {
    K<-e
    test<-lapply(epsVec, function(d)
    {
      validateHyperparamters(cnstr,n_data, iVal,d,K)
    })
    #print(test)
    return(test)
  })

hyperparamterResultMat <-as.matrix(unlist(testK))
print("Training with Crossvalidation Results:")
print(hyperparamterResultMat)

maxKcol <-which(hyperparamterResultMat == max(hyperparamterResultMat), arr.ind = TRUE)[1,]["col"]
epsMax <- epsVec[which(hyperparamterResultMat == max(hyperparamterResultMat), arr.ind = TRUE)[1]]
K <-kKernel[[maxKcol]]

print(sprintf("Epsilon: %.12f ", epsMax))

testHyperparamter(cnstr,n_data, iTest, epsMax, K)

