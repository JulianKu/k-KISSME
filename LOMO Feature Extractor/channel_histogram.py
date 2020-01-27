import numpy as np

def jointHistogram(img, boundary, bin_size):
    '''
    Calculation of the histogram for every channel of the image
    
    Input:
        img:        numpy array of shape (height, width, channels): image (subwindow) to perform operation on
        boundary:   list (len = 2): boundary[0] gives the lower and boundary[1] the upper color scale bound to be considered
        bin_size:   int: number of bins for each channel
    Output:
        histogram:  numpy array of length bin_size**channels: contains frequency for every bin in the histogram
    '''
    
    # compute interval that each bin covers
    interval = (boundary[1] - boundary[0] + 1) / bin_size
    
    # if color image
    if len(img.shape) > 2:
        # total number of bins (depending on number of color channels)
        hist_size = bin_size ** img.shape[2]
        img_bin = np.zeros([img.shape[0], img.shape[1]], np.int32)
        # map every pixel of the image to a color bin (based on all channels)
        for i in range(img.shape[2]):
            img_bin = img_bin + np.floor((img[:, :, i] - boundary[0]) / interval) * (bin_size ** i)
    # else (grayscale image)
    else:
        hist_size = bin_size
        img_bin = (img - boundary[0]) / interval
    
    # get bins and frequency for each bin
    unique, count = np.unique(img_bin, return_counts=True)
    unique = unique.astype(np.int64)
    # initialize histogram with zeros
    histogram = np.zeros([hist_size])
    # fill histogram
    for u, c in zip(unique, count):
        histogram[u] = c

    return histogram
