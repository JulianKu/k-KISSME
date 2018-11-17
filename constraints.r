rm(list = ls())

directory =  "LOMO\ Feature\ Extractor/data/VIPeR"
filename_a =  sprintf("%s/lomo_cam_a.dat", directory);
filename_b =  sprintf("%s/lomo_cam_b.dat", directory);

# read data and sort by filename
features_a = read.delim(filename_a, sep=",")
features_b = read.delim(filename_b, sep=",")
features_a = features_a[ , order(names(features_a))]
features_b = features_b[ , order(names(features_b))]

# file dimensions
num_files = dim(features_a)[2]
half_files = round(num_files/2)

# random permutation
perm = sample(1:num_files)

# create equal sized train and test indexes
idx_train = perm[1:half_files]
idx_test = perm[-1:-half_files]

# must-link constraints
S <- data.frame(idx_train, idx_train)
names(S) <- c("cam_a", "cam_b")

# change indexes for the cannot-link constraints
perm2 = sample(1:half_files)                   # new permutation
mask = idx_train == perm2                      # look for indexes that have not changed in the permutation
perm2[mask] = perm2[mask] %% half_files +1     # Just add +1 so the index changes and we get a cannot-link
D <- data.frame(idx_train, perm2)              # cannot-link constraints
names(D) <- c("cam_a", "cam_b") 

####################################################### EXAMPLES ####################################################

# example how to access the training data (permutated training data)
train_a = features_a[,c(idx_train)]

# view the first must-link constraint
x1 = S[1, c("cam_a")]
x2 = S[1, c("cam_b")]

x1_name = colnames(features_a)[x1]
x2_name = colnames(features_b)[x2]

library('bmp')
pic = read.bmp(sprintf("%s/cam_a/%s", directory, substring(x1_name, 2)))

m <- as.raster(pic, max = 255)
plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
usr <- par("usr")
rasterImage(m, usr[1], usr[3], usr[2], usr[4])

pic = read.bmp(sprintf("%s/cam_b/%s", directory, substring(x2_name, 2)))

m <- as.raster(pic, max = 255)
plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
usr <- par("usr")
rasterImage(m, usr[1], usr[3], usr[2], usr[4])

####

#view the first cannot-link constraint
x1 = D[1, c("cam_a")]
x2 = D[1, c("cam_b")]

x1_name = colnames(features_a)[x1]
x2_name = colnames(features_b)[x2]

pic = read.bmp(sprintf("%s/cam_a/%s", directory, substring(x1_name, 2)))

m <- as.raster(pic, max = 255)
plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
usr <- par("usr")
rasterImage(m, usr[1], usr[3], usr[2], usr[4])

pic = read.bmp(sprintf("%s/cam_b/%s", directory, substring(x2_name, 2)))

m <- as.raster(pic, max = 255)
plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
usr <- par("usr")
rasterImage(m, usr[1], usr[3], usr[2], usr[4])
           
