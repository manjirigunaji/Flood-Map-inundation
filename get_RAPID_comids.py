import csv
import requests
import json

input_file = "eventcentcoords.csv"
output_file = "eventsamplecomid.csv"

# Open the CSV file
with open(input_file, newline='') as csvfile:
    # Read the CSV file
    reader = csv.DictReader(csvfile)
    
    # Write to the output file
    with open(output_file, 'w', newline='') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(["filename", "comid"])

        # Loop through each row in the CSV
        for row in reader:
            filename = row['filename']
            lon = row['lon']
            lat = row['lat']

            # Debug echo
            print(f"Reading file: {filename} with lon: {lon} and lat: {lat}")

            url = f"https://labs.waterdata.usgs.gov/api/nldi/linked-data/comid/position?coords=POINT%28{lon}%20{lat}%29"
            
            # Debug echo
            print(f"URL: {url}")

            # Send a GET request to the URL
            response = requests.get(url, headers={'accept': 'application/json'})

            # Parse the JSON response
            data = json.loads(response.text)

            # Get the comid value
            comid = data['features'][0]['properties']['comid']

            # Write to the output file
            writer.writerow([filename, comid])
