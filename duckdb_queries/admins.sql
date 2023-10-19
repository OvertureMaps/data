LOAD httpfs;
LOAD spatial;

COPY (
    SELECT
        type,
        version,
        CAST(updatetime as varchar) as updateTime,
        JSON(names) as names,
        JSON(sources) as sources,
        ST_GeomFromWKB(geometry) as geometry
    FROM
        read_parquet('s3://overturemaps-us-west-2/release/2023-10-19-alpha.0/theme=admins/type=*/*', hive_partitioning=1)
    WHERE
        adminLevel = 2 AND ST_GeometryType(ST_GeomFromWKB(geometry)) IN ('POLYGON','MULTIPOLYGON')
    LIMIT
        10
    ) TO 'admins_sample.geojsonseq'
WITH (FORMAT GDAL, DRIVER 'GeoJSONSeq');
