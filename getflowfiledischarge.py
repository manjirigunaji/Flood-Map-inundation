import pandas as pd
import os
import xarray as xr


def get_aws_data(start, end, features):
    """Get data from AWS"""

    # Base URL
    url = r's3://noaa-nwm-retrospective-2-1-zarr-pds/chrtout.zarr'

    # Get xarray.dataset
    # Requires s3fs be installed
    ds = xr.open_dataset(
        url,
        backend_kwargs={
            "storage_options": {"anon": True},
            "consolidated": True
        },
        engine="zarr"
    )

    # Extract time series data
    ts = ds.streamflow.sel(time=slice(start, end), feature_id=features)

    # Return DataFrame
    return ts.to_dataframe().reset_index()

def process_file(filename, query_time):
    # Load the file into a DataFrame
    df_file = pd.read_csv(filename)

    # Get the feature_ids from the file
    features = df_file['feature_id'].unique()

    # Get the corresponding data from AWS
    df_aws = get_aws_data(
        start=query_time,
        end=query_time,
        features=features
    )

    # Map the 'streamflow' data from df_aws onto the 'discharge' column in df_file
    # Note that this assumes the 'feature_id' column can be used to align the data
    df_file['discharge'] = df_file['feature_id'].map(df_aws.set_index('feature_id')['streamflow'])

    # Overwrite the file with the updated DataFrame
    df_file.to_csv(filename, index=False)


def main():
    directory = "/home/dylan/HANDextents/flowfiles"
    query_time = "2019-01-12 00:00"

    # Iterate over all text files in the directory
    for filename in os.listdir(directory):
        if filename.endswith(".txt"):
            process_file(os.path.join(directory, filename), query_time)

if __name__ == "__main__":
    main()

