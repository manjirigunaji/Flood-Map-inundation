#!/bin/bash

# PostgreSQL/PostGIS parameters
DBNAME="geodat"
USER="postgres"
TABLE="hand_extent"

# Create an empty table in the PostGIS database
psql -d $DBNAME -U $USER -W -c "DROP TABLE IF EXISTS $TABLE; CREATE TABLE $TABLE (rast raster);"

# Directory containing the TIFF files
DIR="/home/postgres/HANDmaps"

# Find all .tif files in the directory and its subdirectories
find $DIR -name "*.tiff" | while read FILE
do
    echo  $(basename "$FILE") 
    # If the file name does not contain an underscore
    if [[ $(basename "$FILE") != *'_'* ]]; then
        echo "foundfile"
        # Check if the file is projected in WGS84 (EPSG:4326)
        if ! gdalinfo "$FILE" | grep -q "AUTHORITY\[\"EPSG\",\"4326\"\]"; then
            # If not, reproject it using gdalwarp
            gdalwarp -t_srs EPSG:4326 "$FILE" "${FILE%.tif}_reprojected.tif"
            FILE="${FILE%.tif}_reprojected.tif"
        fi

        # Convert the TIFF to SQL format using raster2pgsql
        raster2pgsql -d -C -I -M -t auto -s 4326 "$FILE" -F -l 2,4,8,16,32 $TABLE | psql -d $DBNAME -U $USER
    fi
done
