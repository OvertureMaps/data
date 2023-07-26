LOAD httpfs;
LOAD spatial;

COPY (
    SELECT
        theme,
        type,
        version,
        CAST(updatetime as varchar) as updateTime,
        height,
        numfloors as numFloors,
        level,
        class,
        JSON(names) as names,
        JSON(sources) as sources,
        ST_GeomFromText(geometry) as geometry
    FROM
        read_parquet('s3://overturemaps-us-west-2/release/2023-07-26/*/*', hive_partitioning=2)
    WHERE 
        theme = 'buildings'
    ) TO 'buildings_4.shp'
WITH (FORMAT GDAL, DRIVER 'ESRI Shapefile');
