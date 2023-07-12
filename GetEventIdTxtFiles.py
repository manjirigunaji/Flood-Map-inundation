# This script generates the first half of the flowfiles. 
# Need flowfiles to be organized by huc8 so can feed in a different flowfile for each huc8 involved in the event.
# This file won't work unless you have the password to the database
import psycopg2
import csv

# Establish a connection to your database
conn = psycopg2.connect(database="geodat", user="postgres", password="")

# Create a cursor object
cur = conn.cursor()

# Fetch unique huc8 values
cur.execute("SELECT DISTINCT huc8 FROM nwmflows_within;")
huc8_values = cur.fetchall()

for huc8_tuple in huc8_values:
    huc8 = huc8_tuple[0]
    # For each huc8, fetch associated data
    cur.execute("SELECT id AS feature_id FROM nwmflows_within WHERE huc8 = %s;", (huc8,))
    data = cur.fetchall()
    print(huc8) 
    # Define the filename
    filename = "20190112T000258_" + huc8 + ".txt"
    
    # Write to the file
    with open(filename, 'w') as f:
        writer = csv.writer(f)
        writer.writerow(['feature_id'])  # Writing headers
        writer.writerows(data)  # Writing data

# Close the connection
conn.close()