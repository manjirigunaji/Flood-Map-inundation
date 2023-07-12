
-- Creating the table to calculate the overall convex hull
CREATE TABLE raster_geom AS
SELECT ST_ConvexHull(ST_Collect(convextest)) AS overall_convex_hull
FROM (
  SELECT ST_ConvexHull(rast) AS convextest
  FROM singflood
) AS subquery;

-- Use convex hull to clip out the features inside the events convex hull and the huc8 associated with those features
CREATE TABLE nwmflows_within AS
SELECT subquery.id, subquery.geom4326, subquery.huc8
FROM (
  SELECT n.id, n.geom4326, w.huc8
  FROM nwmflows_reproj n
  JOIN wbd_reproj w ON ST_Within(n.geom4326, w.geom4326)
  WHERE w.huc8 IS NOT NULL
) AS subquery
WHERE ST_Within(subquery.geom4326, (SELECT overall_convex_hull FROM raster_geom));
