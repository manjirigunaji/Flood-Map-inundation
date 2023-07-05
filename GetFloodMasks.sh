#!/bin/bash

#This script queries the RAPID NRT flood dataset as it was structured circa July 2023
# and returns the flood masks for floods that occured after September 17, 2018 in 
# the dataset

# Define your S3 bucket and local directory
s3bucket="rapid-nrt-flood-maps/RAPID_Archive_Flood_Maps"
localdirectory="/home/dylan/RAPID_Masks"

# Get the list of all objects in the S3 bucket
aws s3 ls s3://$s3bucket --recursive --human-readable --summarize | awk '{print $5}' > object_list.txt

# Loop through each object
while IFS= read -r line
do
    # Get the date string from the object name
    date_string=$(echo $line | grep -Eo '[0-9]{8}')

    # Skip the object if no date string is found
    if [ -z "$date_string" ]; then
        continue
    fi

    # Convert the date string to a format that can be compared
    date=$(date -d "${date_string:0:4}-${date_string:4:2}-${date_string:6:2}" +%s)
    cutoff=$(date -d "2018-09-17" +%s)

    # Check if the object meets the criteria
    if [[ $line == *"flood_WM_"* ]] && [[ $line != *"non_"* ]] && [[ $date -gt $cutoff ]]; then
        echo "Copying $line"
        # Remove the prefix from the line
        line=${line#RAPID_Archive_Flood_Maps/}
        # Copy the object to the local directory
        aws s3 cp s3://$s3bucket/$line $localdirectory
    fi
done < object_list.txt

# Remove the temporary file
rm object_list.txt
