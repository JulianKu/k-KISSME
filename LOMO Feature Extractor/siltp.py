import cv2
import numpy as np

def SILTP4(img, R, tau):    
    '''
    Calculation of SILTP operator for every pixel in the image (considering 4 neighbors)
    
    Input:
        img:        numpy array of shape (height, width, channels): image (subwindow) to perform operation on
        R:          int: radius of circle where neighbors are distributed on
        tau:        float: scale factor for comparing range
    Output:
        siltp:      numpy array of shape (height, width): SILTP features for every pixel in img
    '''
    
    # if color image
    if len(img.shape) > 2:
        # convert to grayscale
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # pad image and borders with edge values to allow computation of SILTP features for edge pixels
    img_pad = np.pad(img, R, 'edge')
    
    R_ = -1 * R
    # upper neighbors for every pixel in img
    img_u = img_pad[:2*R_, R:R_]
    # lower neighbors for every pixel in img
    img_d = img_pad[2*R:, R:R_]
    # right neighbors for every pixel in img
    img_r = img_pad[R:R_, 2*R:]
    # left neighbors for every pixel in img
    img_l = img_pad[R:R_, :2*R_]
    
    # upper and lower limits for piecewise comparison
    up_limit = (1 + tau) * img
    low_limit = (1 - tau) * img
    
    # perform comparison of center pixel to neighbor pixels for every pixel in the image
    # returns not binary string for each pixel but interprets binary string as binary number 
    # and returns corresponding integer number 
    siltp = ((img_u < low_limit) + (img_u > up_limit) * 2) + \
            ((img_d < low_limit) + (img_d > up_limit) * 2) * 3 + \
            ((img_r < low_limit) + (img_r > up_limit) * 2) * (3 ** 2) + \
            ((img_l < low_limit) + (img_l > up_limit) * 2) * (3 ** 3) 
    
    return siltp
