{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
    in rec {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
	  gcc
	  gdal
	  python3Full
          (python3.withPackages(ps: with ps; [
		fsspec
		zarr
		s3fs
		python-dotenv
       		tqdm
		cftime
		numpy
		pandas
		numba
		rasterio
		fiona
		shapely
		xarray
		geopandas
		scipy
		pyproj   
		affine
		psycopg2
		pip
		  ]))
        ];
      };
    }
  );
}
