# import dependencies
source("constraints.R")
source("distance.R")
source("kCovariance.R")
source("validateHyperparameters.R")
source("Visualization.R")

# directory of feature vectors
dir <- "LOMO\ Feature\ Extractor/data/VIPeR"

# import feature vectors from dat files
features <- importfeat(dir)
cam_a <- features$a
cam_b <- features$b

# concatenate both cameras into one set
X <- cbind(as.matrix((cam_a)), as.matrix((cam_b)))

# number of data samples in data set
n_data <- dim(cam_a)[2]

# split data into training, validation and test set
idx <- splitData(n_data, r_val = 0.1, r_test = 0.1)
iTrain <- idx$train
iVal <- idx$validation
iTest <- idx$test

# generate must- and cannot-link constraints
cnstr <- genConstraints(iTrain)

pow10 <- function(x){10^x}
##------------------------
# optimize hyperparameters
##------------------------
library(kernlab)
# compute kernel matrices
sigmas <- sapply(seq(-3.5,2.5,0.5), pow10)
rbfs <- lapply(sigmas, function(sig){kernelMatrix(rbfdot(sigma = sig), t(X))})
names(rbfs) <- sapply(sigmas, function(sig){paste('RBF',sig)})
vanilla <-kernelMatrix(vanilladot(), t(X))
degrees <- 2:10
polys <- lapply(degrees, function(deg){kernelMatrix(polydot(degree = deg), t(X))})
names(polys) <- sapply(degrees, function(deg){paste('Poly',deg)})
# concatenate kernel matrices
Kernels <-c(list(Linear=vanilla),rbfs, polys)

# small regularization constant epsilon
epsVec <- sapply(seq(-10,-0.5,0.5), pow10)
# rank matching rates
ranks <- c(1,5,10,20,25,50)

testK <- lapply(1:length(Kernels), function(k)
  {
    K <- Kernels[[k]]
    print(sprintf("Testing kernel %s", names(Kernels)[k]))
    test <- lapply(1:length(epsVec), function(e)
    {
      eps <- epsVec[e]
      print(sprintf("Testing epsilon %.11f", eps))    
      valscores <- validateHyperparameters(cnstr, n_data, iVal, eps, K, ranks)
      scoreSum <-sum(unlist(valscores))
      return(list('sum'=scoreSum, 'scores'=valscores))
    })
    #print(test)
    return(test)
  })

scoreSums <- lapply(1:length(testK[[1]]), function(x){testK[[1]][[x]]$sum})
hypparamResMat <-as.matrix(unlist(scoreSums))

# get best hyperparameter combination
idxMax <- which(hypparamResMat == max(hypparamResMat), arr.ind = TRUE)[1,1]
maxKcol <- idxMax %/% length(epsVec) + 1
epsMax <- epsVec[(idxMax - 1) %% length(epsVec) +1]
K <- Kernels[[maxKcol]]

# print hyperparameters
print(sprintf("Kernel: %s", names(Kernels)[maxKcol]))
print(sprintf("Epsilon: %.12f ", epsMax))

# print scores on validation set
maxScores <- testK[[1]][[idxMax]]$scores
print('Scores of best validation hyperparameter set')
invisible(sapply(1:length(ranks), function(i){print(sprintf("Rank-%d Matching Rate: %.2f", ranks[i],maxScores[[i]]))}))

# finally return scores on test set with best hyperparameter combination and visualize
testScores <- validateHyperparameters(cnstr,n_data, iTest, epsMax, K, ranks, plotrank = 5, dir=dir)
print('Scores on test set')
invisible(sapply(1:length(ranks), function(i){print(sprintf("Rank-%d Matching Rate: %.2f", ranks[i],testScores[[i]]))}))
