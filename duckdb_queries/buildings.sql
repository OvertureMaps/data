LOAD httpfs;
LOAD spatial;

COPY (
    SELECT
        type,
        version,
        CAST(update_time as varchar) as update_time,
        height,
        num_floors,
        level,
        class,
        JSON(names) as names,
        JSON(sources) as sources,
        ST_GeomFromWKB(geometry) as geometry
    FROM
        read_parquet('s3://overturemaps-us-west-2/release/<release-version>/theme=buildings/type=*/*', hive_partitioning=1)
    LIMIT
        100
    ) TO 'buildings_sample.geojsonseq'
WITH (FORMAT GDAL, DRIVER 'GeoJSONSeq');
