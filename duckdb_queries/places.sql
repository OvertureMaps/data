LOAD httpfs;
LOAD spatial;

COPY (

    SELECT
       CAST(names AS JSON),
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
