#!/usr/bin/env python
# coding: utf-8

# In[1]:


from hydrotools.nwis_client.iv import IVDataService
import matplotlib.pyplot as plt
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
    reference_time = date.strftime("%Y%m%dT00Z")
    forecast_data = model_data_service.get(
        configuration="short_range",
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


# Instantiate the IVDataService
service = IVDataService(value_time_label="value_time")

# Retrieve gauge streamflow data
observations_data = service.get(
    sites='01646500',
    startDT='2022-01-01',
    endDT='2022-01-07'
)

# Plotting the data
fig, ax = plt.subplots()

# Plot gauge streamflow data
ax.plot(observations_data['value_time'], observations_data['value'], color='blue', label='Gauge Data')

# Create a second y-axis
ax2 = ax.twinx()

# Plot the model streamflow data
ax2.plot(filtered_data['value_time'], filtered_data['value'], color='red', label='Model Data')

# Set labels and title
ax.set_xlabel('Time')
ax.set_ylabel('Gauge Streamflow', color='blue')
ax2.set_ylabel('Model Streamflow', color='red')
plt.title('Gauge Streamflow vs Model Streamflow')

# Add legend
lines, labels = ax.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax.legend(lines + lines2, labels + labels2)

# Rotate x-axis tick labels
plt.xticks(rotation=45)

# Display the plot
plt.show()


# In[ ]:




