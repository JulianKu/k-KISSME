import os

import json
import cv2
import csv

import lomo

with open('config.json', 'r') as f:
    config = json.load(f)

data_path = 'data/VIPeR/'
for directory in os.listdir(data_path):
    if os.path.isdir(data_path + directory):
    
        img_list = os.listdir(data_path + directory)
        if len(img_list) == 0:
            print('Data directory ' + data_path + directory + ' is empty.')
            continue
        
        lomos = {} # create dictionary for the feature vectors of all the images (img_name as key)
        for counter, img_name in enumerate(img_list):
            if not img_name.lower().endswith(('.jpg','.jpeg','.bmp','.png')): # only perform lomo on images
                continue
        
            img = cv2.imread(os.path.join(data_path + directory, img_name)) # read image
        
            lomo_vec = lomo.LOMO(img, config) # compute LOMO feature vector
            
            lomos[img_name] = lomo_vec # append image and corresponding vector to dict
            
            print('Number of images processed: ', counter)
        print('directory ' + directory ' finished')
        
        # write data in dat file
        print('start writing data into file')
        with open(data_path + 'lomo_' + directory + '.dat', 'w') as l_file:
            csvwriter = csv.writer(l_file, dialect='excel', delimiter=',')
            header = lomos.keys()
            csvwriter.writerow(header)
            for element in range(lomos[img_name].size):
                row = []
                for key in header:
                    row.append(lomos[key][element])
                csvwriter.writerow(row)
        l_file.close()
print('process finished')