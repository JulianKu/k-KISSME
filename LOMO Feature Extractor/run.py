'''
Main script for LOMO feature extraction
Reads image one by one and performs LOMO on each
Saves descriptors for every set of images in *.dat file
'''

# import dependencies
import os
import json
import cv2
import csv
from tqdm import tqdm
import lomo

# load configuration parameters
with open('config.json', 'r') as f:
    config = json.load(f)

# read images from given path
data_path = 'data/VIPeR/'
for directory in os.listdir(data_path):
    if os.path.isdir(data_path + directory):
        
        #list of images
        img_list = os.listdir(data_path + directory)
        if len(img_list) == 0:
            print('Data directory ' + data_path + directory + ' is empty.')
            continue
        print('Processing images in directory ' + data_path + directory)
        
        # initialize dictionary for the feature vectors of all the images (img_name as key)
        lomos = {}
        
        #iterate over images
        for counter, img_name in enumerate(tqdm(img_list[:20], desc='images processed')):
            # verify that file is image -> only perform lomo on images
            if not img_name.lower().endswith(('.jpg','.jpeg','.bmp','.png')):
                continue
            
            # read image
            img = cv2.imread(os.path.join(data_path + directory, img_name))
            
            # compute LOMO feature vector
            lomo_vec = lomo.LOMO(img, config)
            
            # append image and corresponding vector to dict
            lomos[img_name] = lomo_vec
            
        print('directory ' + directory + ' finished')
        
        # write data in dat file
        print('start writing data into file')
        with open(data_path + 'lomo_' + directory + '.dat', 'w') as l_file:
            csvwriter = csv.writer(l_file, dialect='excel', delimiter=',')
            header = lomos.keys()
            csvwriter.writerow(header)
            for element in tqdm(range(lomos[img_name].size), desc='images processed'):
                row = []
                for key in header:
                    row.append(lomos[key][element])
                csvwriter.writerow(row)
        l_file.close()
        print('writing finished')
print('process finished')