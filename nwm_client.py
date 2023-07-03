#!/usr/bin/env python
# coding: utf-8

# In[1]:


import matplotlib.pyplot as plt

# Import the nwm Client
from hydrotools.nwm_client import gcp as nwm
import pandas as pd

# Instantiate model data service
model_data_service = nwm.NWMDataService()

# Define the range of dates
start_date = pd.to_datetime('2022-01-01')
end_date = pd.to_datetime('2022-01-07')

# Create an empty list to store the forecast data
forecast_data_list = []

# Retrieve forecast data for each date
for date in pd.date_range(start=start_date, end=end_date, freq='D'):
    reference_time = "20220101T16Z"  # Modify the reference time here
    forecast_data = model_data_service.get(
        configuration="analysis_assim_extend",  # Modify the configuration here
        reference_time=reference_time
    )
    forecast_data_list.append(forecast_data)

# Concatenate the forecast data from all dates
forecast_data = pd.concat(forecast_data_list)

# Look at the data
print(forecast_data.info(memory_usage='deep'))
print(forecast_data[['value_time', 'value']].head())

# Filter the dataset for a specific site code or feature id
site_code = '01030350'
feature_id = 3109
filtered_data = forecast_data[(forecast_data['usgs_site_code'] == site_code) | (forecast_data['nwm_feature_id'] == feature_id)]

# Print the filtered data for the 'value_time' and 'value' columns
print(filtered_data[['value_time', 'value']])

# Plot the filtered data
plt.plot(filtered_data['value_time'], filtered_data['value'])
plt.xlabel('Value Time')
plt.ylabel('Value')
plt.title('Filtered Data')
plt.show()


# In[2]:


forecast_data


# In[3]:


filtered_data


# In[32]:


import matplotlib.pyplot as plt

# Create a figure and axes
fig, ax1 = plt.subplots()

# Plot the gauge data
ax1.plot(filtered_data['value_time'], filtered_data['value'], color='blue')
ax1.set_xlabel('Time')
ax1.set_ylabel('Gauge Data', color='blue')

# Create a second y-axis
ax2 = ax1.twinx()

# Plot the assimilation data
ax2.plot(filtered_data['value_time'], filtered_data['value_time'], color='red')
ax2.set_ylabel('Assimilation Data', color='red')

# Set title and legends
plt.title('Gauge Data and Assimilation Data')
ax1.legend(['Gauge Data'], loc='upper left')
ax2.legend(['Assimilation Data'], loc='upper right')

# Rotate x-axis tick labels
plt.xticks(rotation=45)

# Display the plot
plt.show()


# In[ ]:





# In[ ]:




