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

        # Extract the filename without the extension
        BASENAME=$(basename "$FILE" .tiff)
        echo $BASENAME 
        # Prepend "hand_extent_" to the base filename
        TABLE="hand_extent_$BASENAME"

        # Convert the TIFF to SQL format using raster2pgsql
        raster2pgsql -C -I -M -t auto -s 4326 -F "$FILE" $TABLE | psql -d $DBNAME -U $USER

    fi
done