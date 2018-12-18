## kernelized KISSME

## Description
This is an implementation for the kernelized KISSME algorithm in R as described by Nguyen and De Baets (2019)

## How to
1. The run.py script in the LOMO Feature Extractor folder needs to be run in order to create the features
2. Start the test.R in the main directory. It automatically 
	* imports the feature vectors
	* splits up the dataset into training, validation and test
	* genereates must-link and cannot-link constraints on the training dataset
	* evaluates different hyperparameter combinations (kernel methods and epsilon) on the validation set
	* returns test scores
	* visualizes the results
	
## Reference
* ["Kernel Distance Metric Learning Using Pairwise Constraints for Person Re-Identification", Nguyen and De Baets, 2019] (https://ieeexplore.ieee.org/document/8469088)

