# This script is an example of how to pull data from the analysis_assim folder of the google cloud bucket of nwm outputs. 
# Use the /linked-data/comid/position endpoint at https://labs.waterdata.usgs.gov/api/nldi/swagger-ui/index.html to get the feature (nwm_feature_id = comid) most closely associated with the latitude and longitude you care about.

# Import the NWM Client
from hydrotools.nwm_client_new.NWMFileClient import NWMFileClient

# Instantiate model data client
#  By default, NWM values are in SI units
#  If you prefer US standard units, nwm_client can return
#  values in US standard units by setting the unit_system parameter 
#  to MeasurementUnitSystem.US
# 
# from hydrotools.nwm_client_new.NWMClientDefaults import MeasurementUnitSystem
# model_data_client = NWMFileClient(unit_system=MeasurementUnitSystem.US)
model_data_client = NWMFileClient()

# Retrieve forecast data
forecast_data = model_data_client.get(
    configurations = ["analysis_assim"],
    reference_times = ["20210101T01Z"],
    nwm_feature_ids = [6965851]
    )

# Look at the data
print(forecast_data.head())
