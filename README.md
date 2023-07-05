# Flood-Map-inundation

## Installing nwm_client_new

To successfully install and import this library you need to be operating in an environment with python 3.1 or greater. Run these commands is the 2i2c terminal:

\# Create and activate python environment, requires python >= 3.8

$ python3 -m venv env

$ source env/bin/activate

$ python3 -m pip install --upgrade pip wheel

# Install nwm_client
$ python3 -m pip install hydrotools.nwm_client_new

## Querying nwm_feature_id's that aren't at a usgs site code

By default when you use nwm_client to query streamflow records it will return just the nwm_feature_id's associated with gauges. It can return other features though. You just have to explicitely ask for them by setting the "nwm_feature_id" argument in the NWMFileClient() get request. 

## Linking RAPID NRT flood maps to discharges

The structure for the archived RAPID NRT flood maps is: MMM_BB_TTTR_LFPP_YYYYMMDDTHHMMSS_YYYYMMDDTHHMMSS_OOOOOO_DDDDDD_CCCC. YYYYMMDDTHHMMSS_YYYYMMDDTHHMMSS represents the time range that the sensor was aquiring data. For the flood maps being examined this time range is very narrow (seconds). To estimate the discharge that was occuring during the image acquisition, the current discharge reading/s from the NWM are pulled durring the time range in question for a representative discharge associated with the flood map. Then the max discharge is chosen and linked to the image id. To get the nwm_feature_id from which to obtain the discharge estimate a centroid is found for a given flod map and then that centroid is associated to it's nearest nwm_feature_id using the comid/position endpoint of the NLDI api to the USGS water data services.
