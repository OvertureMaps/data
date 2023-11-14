LOAD httpfs;
LOAD spatial;

CREATE VIEW admins_view AS
SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/<release-version>/theme=admins/type=*/*', filename=true, hive_partitioning=1);

COPY (
    SELECT
            admins.id,
            admins.subType,
            admins.isoCountryCodeAlpha2,
            JSON(admins.names) AS names,
            JSON(admins.sources) AS sources,
            areas.areaId,
            ST_GeomFromWKB(areas.areaGeometry) as geometry
    FROM admins_view AS admins
    INNER JOIN (
        SELECT 
            id as areaId, 
            localityId, 
            geometry AS areaGeometry
        FROM admins_view
    ) AS areas ON areas.localityId == admins.id
    WHERE admins.adminLevel = 2
    LIMIT 10    
) TO 'admins_sample.geojsonseq'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');
