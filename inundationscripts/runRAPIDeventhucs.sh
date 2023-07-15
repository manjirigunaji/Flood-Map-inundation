#!/bin/bash

hydrofabric_dir="/home/dylan/HANDfabrics"
forecast_dir="/home/dylan/HANDextents/flowfiles"
output_base_dir="/home/dylan/HANDmaps"  # replace with your actual output base directory

# iterate through huc numbers
while IFS= read -r huc; do
    # Remove quotes from huc
    huc=${huc//\"}
    echo "$huc"
    cp "$hydrofabric_dir/$huc/branch_ids.csv" "$hydrofabric_dir/fim_inputs.csv"

    # construct forecast file name
    forecast_file="$forecast_dir/20190112T000258_$huc.txt"
    echo $forecast_file

    # generate output directory path for current huc number
    output_dir="$output_base_dir/$huc"
    # create output directory if it doesn't exist
    mkdir -p "$output_dir"
    # generate --inundation-raster argument value
    inundation_raster="$output_dir/${huc}.tiff"
    # call python script with current arguments
    python inundate_mosaic_wrapper.py --hydrofabric_dir "$hydrofabric_dir" --huc "$huc" --forecast "$forecast_file" --inundation-raster "$inundation_raster" --log-file "log.txt"

done < "/home/dylan/HANDextents/eventhuc8list.txt"
