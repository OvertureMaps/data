------------------------------------------------------------------------
-- Set up the Overture Maps data tables in Amazon Athena on AWS
------------------------------------------------------------------------
-- The below Athena SQL queries will create tables in your AWS account's
-- data catalog pointing directly to data hosted on Overture's S3
-- bucket. You can then query Overture data directly from Athena without
-- needing to copy it.
--
-- 💡 TIP: Athena only allows one SQL statement to be run at a time, so
--         highlight and run each SQL query separately.
-- 💡 TIP: Overture's S3 bucket is located in the us-west-2 AWS region,
--         so use Athena in us-west-2 for best performance.
------------------------------------------------------------------------


-- =====================================================================
-- Admins theme
-- =====================================================================

CREATE EXTERNAL TABLE `admins`(
  `id` string,
  `updateTime` string,
  `version` int,
  `names` map<string,array<map<string,string>>>,
  `adminLevel` int,
  `maritime` string,
  `subType` string,
  `localityType` string,
  `context` string,
  `isoCountryCodeAlpha2` string,
  `isoSubCountryCode` string,
  `defaultLanugage` string,
  `drivingSide` string,
  `sources` array<map<string,string>>,
  `bbox` struct<minX:double,maxX:double,minY:double,maxY:double>,
  `geometry` binary)
PARTITIONED BY (
  `type` string)
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/2023-07-26-alpha.0/theme=admins'


MSCK REPAIR TABLE `admins`


-- =====================================================================
-- Buildings theme
-- =====================================================================

CREATE EXTERNAL TABLE `buildings`(
  `id` string,
  `updateTime` string,
  `version` int,
  `names` map<string,array<map<string,string>>>,
  `level` int,
  `height` double,
  `numFloors` int,
  `class` string,
  `sources` array<map<string,string>>,
  `bbox` struct<minX:double,maxX:double,minY:double,maxY:double>,
  `geometry` binary)
PARTITIONED BY (
  `type` varchar(8))
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/2023-07-26-alpha.0/theme=buildings'


MSCK REPAIR TABLE `buildings`


-- =====================================================================
-- Places theme
-- =====================================================================

CREATE EXTERNAL TABLE `places`(
  `id` string,
  `updateTime` string,
  `version` int,
  `names` map<string,array<map<string,string>>>,
  `categories` struct<main:string,alternate:array<string>>,
  `confidence` double,
  `websites` array<string>,
  `socials` array<string>,
  `emails` array<string>,
  `phones` array<string>,
  `brand` struct<names:map<string,array<map<string,string>>>,wikidata:string>,
  `addresses` array<map<string,string>>,
  `sources` array<map<string,string>>,
  `bbox` struct<minX:double,maxX:double,minY:double,maxY:double>,
  `geometry` binary)
PARTITIONED BY (
  `type` varchar(5))
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/2023-07-26-alpha.0/theme=places'

MSCK REPAIR TABLE `places`


-- =====================================================================
-- Transportation theme
-- =====================================================================

CREATE EXTERNAL TABLE `transportation`(
  `id` string,
  `updatetime` timestamp,
  `version` int,
  `level` int,
  `subtype` varchar(4),
  `connectors` array<string>,
  `road` string,
  `sources` array<map<string,string>>,
  `bbox` struct<minX:double,maxX:double,minY:double,maxY:double>,
  `geometry` binary)
PARTITIONED BY (
  `type` varchar(9))
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/2023-07-26-alpha.0/theme=transportation'
