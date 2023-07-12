#!/bin/bash

# your file path
file="/home/postgres/HANDextents/eventhuc8list.txt"

# Your local folder path
local_folder="/home/postgres/HANDextents/HANDfabrics"

# Read file line by line
while IFS= read -r line
do
    # Remove quotes
    huc8=$(echo $line | tr -d '"')

    # AWS S3 copy command
    aws s3 cp --recursive s3://noaa-nws-owp-fim/hand_fim/outputs/fim_4_3_11_0/$huc8 \
    $local_folder/$huc8 --request-payer requester

done < "$file"