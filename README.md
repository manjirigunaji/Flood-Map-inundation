# Flood-Map-inundation

The goal of this repository is to present a codebase capable of comparing a flood map created from SAR satellite imagery to flood maps created from a height above nearest drainage (HAND) model. The SAR flood maps are obtained from the [RAPID NRT dataset](https://github.com/QingYang6/RAPID-NRT-flood-maps-on-AWS/blob/master/README.md) and the HAND inundation maps were created using NOAA's Office of Water Predictions [inundation mapping repository](https://github.com/NOAA-OWP/inundation-mapping).

# Project workflow

## Acquiring RAPID images

The RAPID data is available for free as part of the Amazon Sustainability Data Initiative. The script **GetFloodMasks.sh** shows how we downloaded the processed flood masks from this dataset. The method for obtaining these floodmasks is described in *find paper and insert link here*. This script exports all 1000 flood masks available. Due to time constraints only one of these masks was analyzed from an event in January, 2019 that occured on and near the Mississipi river south of Memphis, Tennessee.

## Importing RAPID images into postGIS

Once the RAPID images were acquired a subset of these images were imported into postGIS using raster2pgsql with syntax similar to:

```
raster2pgsql -R -I -C -M /path/to/geotiffs/*.tif -F -t auto public.rasters | psql -d your_database -U your_user 
```

The rasters were imported out-of-database to speed up future analysis. To analyze out-of-db rasters it is important to make sure that postgis.gdal_enabled_drivers is set to 'ENABLE_ALL' and that postgis.enable_outdb_rasters is set to 'on' or 'true'.

## Getting the extent of the RAPID flood mask

It was necessary to get the extent of the flood mask so that the information necessary to run the HAND model could be queried from within this extent. The first query in **GetEventExtentIdsHucs.sql** does this for the raster tiles associated with the event we are analyzing (these tiles were moved to a table called "singflood"). ST_ConvexHull was used to get the extent since it is skewed relative to the map orientation. 

## Finding which National Water Model feature id's occur inside an event

Once an extent for the flood event of interest was obtained the extent was used to find which national water model features occur within the extent boundaries. This is done in the second query in 

## Querying NWM archival data to finish constructing flow files

### Linking RAPID NRT flood maps time to discharges

The structure for the archived RAPID NRT flood maps is: MMM_BB_TTTR_LFPP_YYYYMMDDTHHMMSS_YYYYMMDDTHHMMSS_OOOOOO_DDDDDD_CCCC. YYYYMMDDTHHMMSS_YYYYMMDDTHHMMSS represents the time range that the sensor was aquiring data. For the flood maps being examined this time range is very narrow (seconds). To estimate the discharge that was occuring during the image acquisition, the current discharge reading/s from the NWM are pulled durring the time range in question for a representative discharge associated with the flood map. Then the max discharge is chosen and linked to the image id. To get the nwm_feature_id from which to obtain the discharge estimate a centroid is found for a given flod map and then that centroid is associated to it's nearest nwm_feature_id using the comid/position endpoint of the NLDI api to the USGS water data services.

#### Correspondance between RAPID NRT timestamp acquisition timezone and archived data time zone

Both times are the sentinel 1 file naming convention and the NWM archived zarr data use UTC. 
