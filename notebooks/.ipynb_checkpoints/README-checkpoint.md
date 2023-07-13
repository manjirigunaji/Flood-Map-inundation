# Flood-Map-inundation

## Installing nwm_client_new

To successfully install and import this library you need to be operating in an environment with python 3.1 or greater. Run these commands is the 2i2c terminal:

# Create and activate python environment, requires python >= 3.8
$ python3 -m venv env
$ source env/bin/activate
$ python3 -m pip install --upgrade pip wheel

# Install nwm_client
$ python3 -m pip install hydrotools.nwm_client_new

## Querying nwm_feature_id's that aren't at a usgs site code

By default when you use nwm_client to query streamflow records it will return just the nwm_feature_id's associated with gauges. It can return other features though. You just have to explicitely ask for them by setting the "nwm_feature_id" argument in the NWMFileClient() get request. 