CREATE TABLE eventcentcoords AS (
  SELECT
      filename,
      ST_X(ST_Centroid(ST_Extent(rast::geometry))) AS lon,
      ST_Y(ST_Centroid(ST_Extent(rast::geometry))) AS lat
  FROM 
      floodmaps
  GROUP BY
      filename
);
