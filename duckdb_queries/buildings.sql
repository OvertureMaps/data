LOAD httpfs;
LOAD spatial;

COPY (
    SELECT
        'buildings' as theme,
        type,
        version,
        updatetime as updateTime,
        height,
        numfloors as numFloors,
        level,
        class,
        JSON(names) as names,
        JSON(sources) as sources,
        ST_GeomFromText(geometry) as geometry
    FROM
    read_parquet('s3://omf-internal-usw2/staging/buildings/type=*/*', hive_partitioning=1)
    WHERE
        bbox.miny > 45
        AND bbox.maxy < 48
        AND bbox.minx > -125
        AND bbox.maxx < -122
    ) TO 'buildings.geojsonseq'
WITH (FORMAT GDAL, DRIVER 'GeoJSONSeq');
