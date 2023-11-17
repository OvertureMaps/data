-- A script to get a set of views for interacting with Overture data
-- You get:
-- * httpfs and spatial support for reading Overture's remote
--   parquet files on AWS
-- * A single overture planet containing all themes and types
-- * A view for admins
-- * A view for base
-- * A view for buildings
-- * A view for places
-- * A view for transportation
INSTALL httpsfs;
INSTALL spatial;

LOAD httpfs;
LOAD spatial;


SET s3_region='us-west-2';
CREATE VIEW overture AS
SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=*/type=*/*', filename=true, hive_partitioning=1);

CREATE VIEW admins AS
SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=admins/type=*/*', filename=true, hive_partitioning=1);

CREATE VIEW base AS
SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=base/type=*/*', filename=true, hive_partitioning=1);

CREATE VIEW buildings AS
SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=buildings/type=*/*', filename=true, hive_partitioning=1);

CREATE VIEW places AS
SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=places/type=*/*', filename=true, hive_partitioning=1);

CREATE VIEW transportation AS
SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=transportation/type=*/*', filename=true, hive_partitioning=1);
