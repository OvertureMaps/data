LOAD httpfs;
LOAD spatial;

-- This will create a 5mb GeoJSONSeq file with 23k places in Seattle.

COPY (
    SELECT
       CAST(names AS JSON) as name,
       ST_GeomFromWKB(geometry)
    FROM
       read_parquet('s3://overturemaps-us-west-2/release/2023-07-26-alpha.0/theme=places/type=*/*', hive_partitioning=1)
    WHERE
        bbox.minx > -122.4447744
        AND bbox.maxx < -122.2477071
        AND bbox.miny > 47.5621587
        AND bbox.maxy < 47.7120663
    ) TO 'places_seattle.geojsonseq'
WITH (FORMAT GDAL, DRIVER 'GeoJSONSeq');

-- Tip: Replace the last 2 lines with:
--
--      ) TO 'places_seattle.shp'
--   WITH (FORMAT GDAL, DRIVER 'ESRI Shapefile');
--
-- to write the data directly to a shapefile.
