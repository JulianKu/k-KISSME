plot_rank = function(image_dataframe, rank, dir) {
    # Plots pictures from camera a and the corresponding pictures from camera b which have the lowest distance 
    # INPUT
    #   image_dataframe: dataframe, where rowlabels are pictures from cam a and entries 
    #                    are pics from cam b ordered by distance
    #   rank:            number of samples with lowest distance that are to be taken into account
    # OUTPUT
    #   one plot with all the images from input
    
    
    library('magick')
    
    num_test = dim(image_dataframe)[1]
    rank = dim(image_dataframe)[2]
    
    # set background to black
    par(bg = 'black') 
    
    # create frame for multiple plots
    op <- par(mfrow = c(num_test, rank+1),
        oma = c(0, 0.5, 1.5, 0.5), # space at the outside
        mar = c(1.5, 0.3, 0, 0)) # space at the right and bottom of each plot
    
    for (i in 1:num_test) {
        # select image from camera a
        image_name = rownames(image_dataframe)[i]
        
        # convert to string
        # substring( ,x) deletes first x chars
        image_path <- sprintf("%s/cam_a/%s", dir, substring(image_name, 2))
        
        img <- image_read(image_path)
        
        # create color hex values
        m <- as.raster(img, max = 255)
        
        plot(0, type = "n", axes = FALSE, xlab = "", ylab = "")
        #title(image_name)
        usr <- par("usr")
        rasterImage(m, usr[1], usr[3], usr[2], usr[4])
        mtext(substring(image_name,2), side = 3, col='white')
        
        for (j in 1:rank) {
            # select image from camera b 
            image_name = image_dataframe[i,j]
            
            # convert to string
            image_path <- sprintf("%s/cam_b/%s", dir, substring(image_name, 2))
            
            img <- image_read(image_path)
            m <- as.raster(img, max = 255)
            
            plot(0, type = "n", axes = FALSE, xlab = "", ylab = "")
            #title(image_name)
            usr <- par("usr")
            rasterImage(m, usr[1], usr[3], usr[2], usr[4])
            mtext(substring(image_name,2), side = 3, col='white')
        }
    }   
}

