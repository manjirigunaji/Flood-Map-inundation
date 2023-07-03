#!/usr/bin/env python
# coding: utf-8

# In[7]:


import rasterio
import matplotlib.pyplot as plt

# Specify the path to the TIF file
tif_file = 'flood_WM_S1B_IW_GRDH_1SDV_20171008T234838_20171008T234907_007745_00DADB_62BF.tif'

# Open the TIF file
with rasterio.open(tif_file) as src:
    # Read the raster data
    raster_data = src.read(1)  # Read the first band (change the index if necessary)
    # Get the affine transformation
    transform = src.transform

    # Calculate the extent
    width = src.width
    height = src.height
    xmin, ymin = transform * (0, 0)
    xmax, ymax = transform * (width, height)

# Display the image
plt.imshow(raster_data, cmap='gray', extent=[xmin, xmax, ymin, ymax])
plt.colorbar(label='Pixel Value')
plt.title('TIF Image')
plt.show()


# In[ ]:





# In[ ]:




