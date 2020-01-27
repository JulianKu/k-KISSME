# kernelized KISSME

Universitat Politècnica de Catalunya (UPC), Barcelona
Faculty of Informatics (FIB)
Kernel-based Machine Learning and Multivariate Modelling (MAI-KMLMM)
Final Course Project


## Description
This is an implementation for the kernelized KISSME algorithm in R as described by Nguyen and De Baets (2019) for large-scale metric learning from equivalence constraints. The algorithm has been applied to the VIPeR dataset by Gray et al., a [python implementation of the LOMO feature extractor](https://github.com/dongb5/LOMO-feature-extractor) (original paper by Liao et al.) is used for preprocessing the data.
For more detail, please have a look into the [final report](Final_Report.pdf).

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
* Nguyen and De Baets, ["Kernel Distance Metric Learning Using Pairwise Constraints for Person Re-Identification,"](https://ieeexplore.ieee.org/document/8469088) IEEE Transactions on Image Processing, Vol. 28, 2019
* D. Gray, S. Brennan, and H. Tao, ["Evaluating Appearance Models for Recognition, Reacquisition, and Tracking,"](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.331.7285&rep=rep1&type=pdf), IEEE International Workshop on Performance Evaluation for Tracking and Surveillance (PETS), 2007
* Shengcai Liao, Yang Hu, Xiangyu Zhu, and Stan Z. Li, ["Person Re-identification by Local Maximal Occurrence Representation and Metric Learning,"](https://www.cv-foundation.org/openaccess/content_cvpr_2015/papers/Liao_Person_Re-Identification_by_2015_CVPR_paper.pdf) CVPR2015

