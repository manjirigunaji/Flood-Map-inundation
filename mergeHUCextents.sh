
# Directory containing the TIFF files
DIR="/home/postgres/HANDmaps"
OUTPUTDIR="/home/postgres/HANDmaps_output"

# Find all .tif files in the directory and its subdirectories
find $DIR -name "*.tiff" | while read FILE
do
    # If the file name does not contain an underscore
    if [[ $(basename "$FILE") != *'_'* ]]; then
        FILE_BASENAME="$(basename "$FILE" .tiff)"

        # Check if the file is projected in WGS84 (EPSG:4326)
        if ! gdalinfo "$FILE" | grep -q "AUTHORITY\[\"EPSG\",\"4326\"\]"; then
        # If not, reproject it using gdalwarp
        gdalwarp -t_srs EPSG:4326 "$FILE" "${FILE%.tiff}_reprojected.tif"
        FILE="${FILE%.tiff}_reprojected.tif"
        echo $FILE
        fi

        # Replace -9999 values with 0 and make all positive values 1
        gdal_calc.py -A "$FILE" --outfile="${OUTPUTDIR}/${FILE_BASENAME}_changed.tif" --calc="(A>0)*2 + (A<=0)*0"
        gdal_translate -a_nodata 0 "${OUTPUTDIR}/${FILE_BASENAME}_changed.tif" "${OUTPUTDIR}/${FILE_BASENAME}_changed2.tif"

    fi
done

# Merging all the changed TIFF files into one, ignoring pixels with value 0
rm $OUTPUTDIR/*_changed.tif
gdal_merge.py -n 0 -o $OUTPUTDIR/merged.tiff $OUTPUTDIR/*_changed2.tif
gdal_translate -ot Byte -scale 0 2 0 255 -a_nodata 0 "${OUTPUTDIR}/merged.tiff" "${OUTPUTDIR}/mergedfinal.tiff"