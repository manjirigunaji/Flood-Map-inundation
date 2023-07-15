# Flood-Map-inundation

The goal of this repository is to present a codebase capable of comparing a flood map created from SAR satellite imagery to flood maps created from a height above nearest drainage (HAND) model. The SAR flood maps are obtained from the [RAPID NRT dataset](https://github.com/QingYang6/RAPID-NRT-flood-maps-on-AWS/blob/master/README.md) and the HAND inundation maps were created using NOAA's Office of Water Predictions [inundation mapping repository](https://github.com/NOAA-OWP/inundation-mapping). The comparison will be based off of the agreement maps of the sort described in the readme to the [gval repository](https://github.com/noaa-owp/gval).

# Project workflow

## Acquiring RAPID images

The RAPID data is available for free as part of the Amazon Sustainability Data Initiative. The script **GetFloodMasks.sh** shows how we downloaded the processed flood masks from this dataset. The method for obtaining these floodmasks is described in *find paper and insert link here*. This script exports all 1000 flood masks available. Due to time constraints only one of these masks was analyzed from an event in January, 2019 that occured on and near the Mississipi river south of Memphis, Tennessee. 

This image acquisition script should be modified to also import the "non-flood" water masks. Because the RAPID NRT flood maps are designed to highlight areas that are inundated more than normal and rely on a change-detection based technique the final flood masks don't clasify areas as water that the HAND inundated extents will. This can be overcome by merging the binary non-flood water masks with the flood masks for the purposes of comparing the RAPID masks to the HAND extents. 

## Importing RAPID images into postGIS

Once the RAPID images were acquired a subset of these images were imported into postGIS using raster2pgsql with syntax similar to:

```
raster2pgsql -R -I -C -M /path/to/geotiffs/*.tif -F -t auto public.rasters | psql -d your_database -U your_user 
```

The rasters were imported out-of-database to speed up future analysis. To analyze out-of-db rasters it is important to make sure that postgis.gdal_enabled_drivers is set to 'ENABLE_ALL' and that postgis.enable_outdb_rasters is set to 'on' or 'true'.

## Getting the extent of the RAPID flood mask

It was necessary to get the extent of the flood mask so that the information necessary to run the HAND model could be queried from within this extent. The first query in **GetEventExtentIdsHucs.sql** does this for the raster tiles associated with the event we are analyzing (these tiles were moved to a table called "singflood"). ST_ConvexHull was used to get the extent since it is skewed relative to the map orientation. 

## Finding which National Water Model feature id's occur inside an event

Once an extent for the flood event of interest was obtained the extent was used to find which national water model features occur within the extent boundaries. This is done in the second query in **GetEventExtentIdsHucs.sql**. In this query there is a subquery that divides all the nwm features by huc8 and returns columns with feature id's, flowline segments, and the huc8 that the features fall within. The features organized by huc8 are then clipped to select only the features and huc8 values that lie within the extent of the flood event of interest. This query expects a table of raster tiles from the flood event as well as two tables with vector geometrise where one table contains feature id's and flowlines and the other table contains the huc8 codes and the geometries describing the huc8 boundaries.

### Importing wbd.gpkg and nwmflows.gpkg

Postgres tables from which the nwm features and the huc8 ids were pulled were constructed from the OWP FIM4 version of the [watershed boundary dataset](https://github.com/NOAA-OWP/inundation-mapping/wiki) and the National Water Model flowlines. These files are called "WBD_National.gpkg" and "nwm_flows.gpkg" respectively and are inside the inputs object in the OWP HAND bucket. The import command took a form similar to:

```
ogr2ogr -f "PostgreSQL" PG:"dbname=mydatabase host=myhost user=myuser password=mypassword" -nln new_table_name mydata.gpkg
```

## Exporting feature id's associated with the event

Once we have found which feature id's occur within the event we are analyzing we can then export these to a text file. This is done because the HAND model needs input files of feature id's and discharge values to compute extents within a watershed. Because the HAND model computes extents one huc8 subbasin at a time we need to output text files for each huc8 that intersects with the extent we are analyzing. We will only compute extents for the stream segments associated for the features inside a given huc8. The script **GetEventIdTxtFiles.py** uses the psycopg2 library to query the database that has the table where we have stored the feature id's and huc8's that occur within the flood event boundary. It finds the unique huc8 values that occur within the flood event boundary and then finds the features that occured within that huc8 within the flood event boundary. It then writes the features inside a given huc8 within the event boundary to a text file that is labeled with the event time stamp and the huc8 value. This is the first half of the flow files that will be fed into the code that computes inundate extents using the HAND model.

## Getting HAND models for all the huc8's to be analyzed

As mentioned previously, FIM4 uses relative elevation HAND models that have been computed for an entire huc8 to compute extents. We are going to be using the HAND models that have been precomputed by OWP. To do this we use the script **GetHANDfabrics.sh**. This script takes in a list of huc8's that occured within the event boundaries called eventhuc8list.txt (a list created using the text file names outputted by **GetEventIdTxtFiles.py**). These huc8s are then appended to a path that is used as an argument in an "aws cp" command that transfers over the HAND model and other data needed to compute extents to a local directory.

## Querying NWM archival data to finish constructing flow files

To compute inundation inside a given huc8 using HAND models we need two things: 

1. The nwm feature id's that occured within a given huc8 that we want to compute extents for. 
2. Discharge estimates for the portion of the stream linked to that feature id

To obtain the discharge estimates for our lists of feature id's we use the script **getflowfiledischarge.py**. This script queries a retrospective dataset of NWM output that is hosted on AWS. The script uses x-arrays to query the zarr archive that the historical model output is stored in. We are only querying the model time step that is closest to the time that the SAR image of the flood event was taken. We feed in all the features in our draft flow files and get the model output for each feature for the time we care about. Then we write these discharges to our completed flowfiles.

See below for a digression on how the time of acqusition of the RAPID NRT flood maps is used to get the time 

### Linking RAPID NRT flood maps time to discharges

The structure for the archived RAPID NRT flood maps is: MMM_BB_TTTR_LFPP_YYYYMMDDTHHMMSS_YYYYMMDDTHHMMSS_OOOOOO_DDDDDD_CCCC. YYYYMMDDTHHMMSS_YYYYMMDDTHHMMSS represents the time range that the sensor was aquiring data. For the flood maps being examined this time range is very narrow (seconds). To estimate the discharge that was occuring during the image acquisition, the current discharge reading/s from the NWM are pulled durring the time range in question for a representative discharge associated with the flood map. Then the max discharge is chosen and linked to the image id. To get the nwm_feature_id from which to obtain the discharge estimate a centroid is found for a given flod map and then that centroid is associated to it's nearest nwm_feature_id using the comid/position endpoint of the NLDI api to the USGS water data services.

#### Correspondance between RAPID NRT timestamp acquisition timezone and archived data time zone

Both times are the sentinel 1 file naming convention and the NWM archived zarr data use UTC so no offset needs to be computed.

## Using OWP inundation mapping code to generate inundation extents

### Data necessary to generate inundation extents
- Hydrofabrics
  - See [Section on Getting HAND models](#Getting HAND models for all the huc8's to be analyzed) for how these were obtained. The directory that these are stored needs to be set in the **runRAPIDeventhucs.sh** script in the "inundationscripts" folder.
- flowfiles
  - After the workflow described in the preceding sections to obtain flowfiles for each huc8 inside the event boundaries was run flowfiles were put into their own directory that is also referenced in **runRAPIDeventhucs.sh**
- WBD data
  - This needs to be the version that is in the "inputs" folder of the OWP HAND aws bucket. The filename is WBD_National.gpkg

### Creating a development environment capable of running code

To create a development environment capable of running the HAND inundation code we created a nix devshell using a flake.nix file that is in the inundationscripts folder. After [installing nix](https://zero-to-nix.com/concepts/nix-installer) using the determinate nix installer you should be able to enter into this development environment by navigating to the inundationscripts folder and running "nix develop"

### Generating inundation extents

Extents were generated by running the script **runRAPIDeventhucs.sh**. This script calls the script **inundate_mosaic_wrapper.py** repeatedly to generate extents for every huc being analyzed. Remember you need to be inside the nix dev shell for this script to run properly.

## Merging extents

Extents were reprojected and combined in the script **mergeHUCextents.sh** using calls to various gdal tools. This also needs to be done inside the inundationscripts nix devshell.

## Cropping merged extents

QGIS was used to crop the merged extents to the same boundary as the RAPID flood map. Then QGIS was also used to map the binary HAND and RAPID maps to values that could be fed into gval. The HAND flood map was mapped to 0 and 2 for no-water and water respectively and the RAPID flood map was mapped to 1 and 2 for no-water and water respectively. Also a reminder that before mapping the RAPID flood map was mapped to 1 and 2 we merged the RAPID flood mask with 1 non-flood mask to generate an estimate for total inundated extent and not just a flooded extent.

## Generating an agreement map

Agreement maps were generated using the code in this notebook: https://github.com/NOAA-OWP/gval/blob/main/notebooks/Tutorial.ipynb and substituting the RAPID maps and HAND maps in place of the example images used in the notebook.

# Data

- "WBD_National.gpkg": sitting on Sophias mac in the HAND FIM "inputs" directory
- "nwm_flows.gpkg": sitting on Sophias mac in the HAND FIM "inputs" directory
- flowfiles: gdrive
- hydrofabrics: These need to be pulled by the party that will be using them. The hydrofabric directories we use are 17 gb in size so it would be about $2 to query the HAND FIM bucket enough to download them.
- Merged, remapped RAPID flood image: gdrive
- Merged, remapped HAND flood image: gdrive
- Raw RAPID flood images of event: gdrive

For the data stored in gdrive, Dylan will be sending a link to other project participants shortly. 

