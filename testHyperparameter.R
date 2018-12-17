testHyperparamter <- function(cnstr,n_data, iTest, eps, k){
  # import functions
  source("constraints.R")
  source("kCovariance.R")
  source("distance.R")
  source("Visualization.R")
  
  print("Test:")
  C <- kCovariance(eps, cnstr, k)
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
  
}