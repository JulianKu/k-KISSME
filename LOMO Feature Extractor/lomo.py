import numpy as np
import cv2

import retinex
import siltp
import channel_histogram

def averagePooling(img):
    '''
    Perform average pooling operation on image (filter size 2x2)
    
    Input:
        img:        numpy array of shape (height, width, channels): image to perform operation on
    Output:
        img_pool:   numpy array of shape (0.5*height, 0.5*width, channels): processed image
    '''
    
    #remove single lines that cannot be processed with 2x2 filter size
    if img.shape[0] % 2 != 0:
        img = img[:-1]    
    if img.shape[1] % 2 != 0:
        img = img[:, :-1]
        
    # add two consecutive rows
    img_pool = img[0::2] + img[1::2]
    # add to consecutive columns
    img_pool = img_pool[:, 0::2] + img_pool[:, 1::2]
    # average over the four pixels that were pooled
    img_pool = img_pool // 4

    return img_pool    

def LOMO(img, config):
    '''
    Extract LOMO features from image
    
    Input:
        img:        numpy array of shape (height, width, channels): image to extract features from
        config:     dict: dictionary of configuration parameters
    Output:
        lomo:       numpy array: LOMO feature vector (length depending on image size and configuration parameters)
    '''
    
    # load relevant configuration parameters from config dictionary
    sigma_list   = config['retinex']['sigma_list']
    G            = config['retinex']['G']
    b            = config['retinex']['b']
    alpha        = config['retinex']['alpha']
    beta         = config['retinex']['beta']
    low_clip     = config['retinex']['low_clip']
    high_clip    = config['retinex']['high_clip']
    R_list       = config['lomo']['R_list']
    tau          = config['lomo']['tau']
    hsv_bin_size = config['lomo']['hsv_bin_size']
    block_size   = config['lomo']['block_size']
    block_step   = config['lomo']['block_step']
    
    # perform retinex transformation on image
    img_retinex = retinex.MSRCP(img, sigma_list, low_clip, high_clip)
    
    # initialize SILTP feature vector and HSV color feature vector
    siltp_feat = np.array([])
    hsv_feat = np.array([])
    
    # process original image and two downsampled versions by pooling
    for pool in range(3):
        # determine the number of subwindows to process row- and column-wise
        row_num = (img.shape[0] - (block_size - block_step)) / block_step
        col_num = (img.shape[1] - (block_size - block_step)) / block_step
        # iterate over all subwindows
        for row in range(int(row_num)):
            for col in range(int(col_num)):
                # extract subwindow from image
                img_block = img[
                    row*block_step:row*block_step+block_size,
                    col*block_step:col*block_step+block_size
                ]
                # initialize array of multiple SILTP histograms
                siltp_hist = np.array([])
                # multiple SILTP histograms are computed for different radii given by configuration
                for R in R_list:
                    # compute SILTP features for every pixel in the subwindow                                   
                    siltp4 = siltp.SILTP4(img_block, R, tau)
                    # get bins and frequency for each bin
                    unique, count = np.unique(siltp4, return_counts=True)
                    # initialize histogram with zeros
                    siltp_hist_r = np.zeros([3**4])
                    # fill histogram
                    for u, c in zip(unique, count):
                        siltp_hist_r[u] = c
                    # concatenate SILTP for all radii   
                    siltp_hist = np.concatenate([siltp_hist, siltp_hist_r], 0)
                
                # extract subwindow from retinex image
                img_block = img_retinex[
                    row*block_step:row*block_step+block_size,
                    col*block_step:col*block_step+block_size
                ]                
                # transform retinex image to HSV color space for color feature extraction    
                img_hsv = cv2.cvtColor(img_block, cv2.COLOR_BGR2HSV)
                # build color histogram based on HSV image
                hsv_hist = channel_histogram.jointHistogram(
                    img_hsv,
                    [0, 255],
                    hsv_bin_size
                )
                
                # compute maximal occurrence over all subwindows of the same row
                if col == 0:
                    siltp_feat_col = siltp_hist
                    hsv_feat_col = hsv_hist
                else:
                    # maximal occurrence for SILTP histogram
                    siltp_feat_col = np.maximum(siltp_feat_col, siltp_hist)
                    # maximal occurrence for HSV histogram
                    hsv_feat_col = np.maximum(hsv_feat_col, hsv_hist)
            
            # concatenate the histograms over all rows
            siltp_feat = np.concatenate([siltp_feat, siltp_feat_col], 0)
            hsv_feat = np.concatenate([hsv_feat, hsv_feat_col], 0)
        
        # apply pooling and perform feature extraction with downsampled image
        img = averagePooling(img)
        img_retinex = averagePooling(img_retinex)
    
    # log transform
    siltp_feat = np.log(siltp_feat + 1.0)
    # normalize to unit length
    siltp_feat[:siltp_feat.shape[0]//2] /= np.linalg.norm(siltp_feat[:siltp_feat.shape[0]//2])
    siltp_feat[siltp_feat.shape[0]//2:] /= np.linalg.norm(siltp_feat[siltp_feat.shape[0]//2:])    
    # log transform
    hsv_feat = np.log(hsv_feat + 1.0)
    # normalize to unit length
    hsv_feat /= np.linalg.norm(hsv_feat)
    
    # concatenate all features to final LOMO descriptor
    lomo = np.concatenate([siltp_feat, hsv_feat], 0)
    
    return lomo
