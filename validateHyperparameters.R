# DEMO

#cnstr constrains of training data
#n_data both datasets (training and validation)
#iVal  index of validation data
validateHyperparameters <- function(cnstr, n_data, iVal, eps, K, ranks, plotrank=FALSE, dir=FALSE){
  
  # import functions
  source("constraints.R")
  source("kCovariance.R")
  source("distance.R")
  source("Visualization.R")
  
  
  #print(sprintf("Epsilon: %.12f",eps))
  # compute inverse covariance matrix C
  C <- kCovariance(eps, cnstr, K)
  
  # compute pairwise distance between validation images of both datasets
  Mdist <- results(K, n_data, iVal, C)
  
  #Compute different rank matching rates
  nranks <- length(ranks)
  rankedDists <- vector("list",nranks)
  scores <- vector("list",nranks)
  for (i in seq(1,nranks)) {
    # get n=rank lowest distances
    rankedDists[[i]] <- rankedResults(Mdist, rank=ranks[i])
    # compute matching rate based on the samples with lowest distance
    scores[[i]] <- score(rankedDists[[i]])
    #print(sprintf("Rank-%d Matching Rate: %.2f", ranks[i],scores[[i]]))
  }
  
  if (plotrank) {
      # PLOT
      plot_idx = sample(1:length(iVal), 4)
      results <- rankedResults(Mdist, plotrank)
      image_dataframe <- results[plot_idx, c(T,F)]
      plot_rank(image_dataframe, plotrank, dir)   
  }
  
  return(scores)
}