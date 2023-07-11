-- Use nwmflows.gpkg, wbd.gpkg, and a table created from eventsamplecomids.csv
-- To get a new table that has the id's and nwm flowlines for the huc8's within which the rapid events occur
CREATE TABLE huc8ids AS
SELECT n.id, n.geom, subquery.huc8, subquery.filename
FROM nwmflows n
JOIN (
    SELECT w.huc8, w.geom AS huc8_geom, e.filename
    FROM wbd w, eventsampid e
    WHERE ST_Within(
        (SELECT geom FROM nwmflows WHERE id = e.comid),
        w.geom
    )
    AND w.huc8 IS NOT NULL
    AND e.comid IN (SELECT comid FROM eventsampid ORDER BY filename)
) AS subquery
ON ST_Within(n.geom, subquery.huc8_geom);
