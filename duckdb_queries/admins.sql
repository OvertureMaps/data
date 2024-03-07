LOAD httpfs;
LOAD spatial;

CREATE VIEW admins_view AS
SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/<release-version>/theme=admins/type=*/*', filename=true, hive_partitioning=1);

COPY (
    SELECT
            admins.id,
            admins.subtype,
            admins.iso_country_code_alpha_2,
            JSON(admins.names) AS names,
            JSON(admins.sources) AS sources,
            areas.area_id,
            ST_GeomFromWKB(areas.area_geometry) as geometry
    FROM admins_view AS admins
    INNER JOIN (
        SELECT 
            id as area_id, 
            locality_id, 
            geometry AS area_geometry
        FROM admins_view
    ) AS areas ON areas.locality_id == admins.id
    WHERE admins.admin_level = 2
    LIMIT 10    
) TO 'admins_sample.geojsonseq'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');
