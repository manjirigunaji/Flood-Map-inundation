#!/bin/bash
#!/bin/bash

# PostgreSQL/PostGIS parameters
DBNAME="geodat"
USER="postgres"

# Directory containing the TIFF files
DIR="/home/postgres/HANDmaps"

# Find all .tif files in the directory and its subdirectories
find $DIR -name "*.tiff" | while read FILE
do
    # If the file name does not contain an underscore
    if [[ $(basename "$FILE") != *'_'* ]]; then
        # Check if the file is projected in WGS84 (EPSG:4326)
        if ! gdalinfo "$FILE" | grep -q "AUTHORITY\[\"EPSG\",\"4326\"\]"; then
        # If not, reproject it using gdalwarp
        gdalwarp -t_srs EPSG:4326 "$FILE" "${FILE%.tiff}_reprojected.tif"
        FILE="${FILE%.tiff}_reprojected.tif"
        echo $FILE
        fi

        # Replace NoData values with 0
        gdal_translate -a_nodata 0 "$FILE" "${FILE%_reprojected.tif}_nodata0.tif"
        FILE="${FILE%_reprojected.tif}_nodata0.tif"
        echo $FILE

        # Extract the filename without the extension
        BASENAME=$(basename "$FILE" _nodata0.tif)
        echo $BASENAME 
        # Prepend "hand_extent_" to the base filename
        TABLE="hand_extent_$BASENAME"

        # Convert the TIFF to SQL format using raster2pgsql
        raster2pgsql -C -I -M -t auto -s 4326 -F "$FILE" $TABLE | psql -d $DBNAME -U $USER

    fi
done