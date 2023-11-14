LOAD httpfs;
LOAD spatial;

-- This will create a 5mb GeoJSONSeq file with 23k places in Seattle.

COPY (
    SELECT
       id,
       updatetime,
       version,
       CAST(names AS JSON) AS names,
       CAST(categories AS JSON) AS categories,
       confidence,
       CAST(websites AS JSON) AS websites,
       CAST(socials AS JSON) AS socials,
       CAST(emails AS JSON) AS emails,
       CAST(phones AS JSON) AS phones,
       CAST(brand AS JSON) AS brand,
       CAST(addresses AS JSON) AS addresses,
       CAST(sources AS JSON) AS sources,
       ST_GeomFromWKB(geometry)
    FROM
       read_parquet('s3://overturemaps-us-west-2/release/<release-version>/theme=places/type=*/*', hive_partitioning=1)
    WHERE
        bbox.minx > -122.4447744
        AND bbox.maxx < -122.2477071
        AND bbox.miny > 47.5621587
        AND bbox.maxy < 47.7120663
    ) TO 'places_seattle.geojsonseq'
WITH (FORMAT GDAL, DRIVER 'GeoJSONSeq', SRS 'EPSG:4326');

-- Tip: Replace the last 2 lines with:
--
--      ) TO 'places_seattle.shp'
--   WITH (FORMAT GDAL, DRIVER 'ESRI Shapefile');
--
-- to write the data directly to a shapefile.
