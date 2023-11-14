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

-- The October 2023 Release (and after) uses a unified schema for all themes. There's no need to create separate tables for each theme if you are only interested in the October 2023 Release data.

CREATE EXTERNAL TABLE `overture` (
  `categories` struct<main:string,alternate:array<string>>,
  `level` int,
  `geopoldisplay` string,
  `socials` array<string>,
  `subtype` string,
  `numfloors` int,
  `class` string,
  `sourcetags` map<string,string>,
  `contextid` string,
  `localitytype` string,
  `emails` array<string>,
  `ismaritime` boolean,
  `drivingside` string,
  `localityid` string,
  `adminlevel` int,
  `road` string,
  `isocountrycodealpha2` string,
  `isosubcountrycode` string,
  `updatetime` string,
  `wikidata` string,
  `confidence` double,
  `defaultlanguage` string,
  `brand` struct<names:struct<common:array<struct<value:string,language:string>>,official:array<struct<value:string,language:string>>,alternate:array<struct<value:string,language:string>>,short:array<struct<value:string,language:string>>>,wikidata:string>,
  `addresses` array<struct<freeform:string,locality:string,postCode:string,region:string,country:string>>,
  `names` struct<common:array<struct<value:string,language:string>>,official:array<struct<value:string,language:string>>,alternate:array<struct<value:string,language:string>>,short:array<struct<value:string,language:string>>>,
  `isintermittent` boolean,
  `connectors` array<string>,
  `surface` string,
  `version` int,
  `phones` array<string>,
  `id` string,
  `height` double,
  `sources` array<struct<property:string,dataset:string,recordId:string,confidence:double>>,
  `websites` array<string>,
  `issalt` boolean,
  `geometry` binary,
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>)
PARTITIONED BY (
  `theme` string,
  `type` string)
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/<release-version>/'


-- Load partitions
MSCK REPAIR TABLE `overture`;


-- =====================================================================
-- The below queries are for the July 2023 Data Release



-- Admins theme
-- =====================================================================

CREATE EXTERNAL TABLE `admins`(
  `geopoldisplay` string,
  `subtype` string,
  `sourcetags` map<string,string>,
  `contextid` string,
  `localitytype` string,
  `ismaritime` boolean,
  `drivingside` string,
  `localityid` string,
  `adminlevel` int,
  `isocountrycodealpha2` string,
  `isosubcountrycode` string,
  `updatetime` string,
  `defaultlanguage` string,
  `names` struct<common:array<struct<value:string,language:string>>,official:array<struct<value:string,language:string>>,alternate:array<struct<value:string,language:string>>,short:array<struct<value:string,language:string>>>,
  `version` int,
  `id` string,
  `sources` array<struct<property:string,dataset:string,recordId:string,confidence:double>>,
  `geometry` binary,
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>)
PARTITIONED BY (
  `type` string)
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/<release-version>/theme=admins'


-- Load partitions
MSCK REPAIR TABLE `admins`

-- =====================================================================
-- Base theme
-- =====================================================================

CREATE EXTERNAL TABLE `base`(
  `subtype` string,
  `class` string,
  `sourcetags` map<string,string>,
  `updatetime` string,
  `wikidata` string,
  `isintermittent` boolean,
  `surface` string,
  `names` struct<common:array<struct<value:string,language:string>>,official:array<struct<value:string,language:string>>,alternate:array<struct<value:string,language:string>>,short:array<struct<value:string,language:string>>>,
  `version` int,
  `id` string,
  `sources` array<struct<property:string,dataset:string,recordId:string,confidence:double>>,
  `issalt` boolean,
  `geometry` binary,
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>)
PARTITIONED BY (
  `type` string)
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/<release-version>/theme=base'


-- Load partitions
MSCK REPAIR TABLE `base`

-- =====================================================================
-- Buildings theme
-- =====================================================================

CREATE EXTERNAL TABLE `buildings`(
  `level` int,
  `numfloors` int,
  `class` string,
  `sourcetags` map<string,string>,
  `names` struct<common:array<struct<value:string,language:string>>,official:array<struct<value:string,language:string>>,alternate:array<struct<value:string,language:string>>,short:array<struct<value:string,language:string>>>,
  `version` int,
  `id` string,
  `height` double,
  `sources` array<struct<property:string,dataset:string,recordId:string,confidence:double>>,
  `geometry` binary,
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>)
PARTITIONED BY (
  `type` string)
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/<release-version>/theme=buildings'


-- Load partitions
MSCK REPAIR TABLE `buildings`


-- =====================================================================
-- Places theme
-- =====================================================================

CREATE EXTERNAL TABLE `places`(
  `categories` struct<main:string,alternate:array<string>>,
  `socials` array<string>,
  `sourcetags` map<string,string>,
  `emails` array<string>,
  `updatetime` string,
  `confidence` double,
  `brand` struct<names:struct<common:array<struct<value:string,language:string>>,official:array<struct<value:string,language:string>>,alternate:array<struct<value:string,language:string>>,short:array<struct<value:string,language:string>>>,wikidata:string>,
  `addresses` array<struct<freeform:string,locality:string,postCode:string,region:string,country:string>>,
  `names` struct<common:array<struct<value:string,language:string>>,official:array<struct<value:string,language:string>>,alternate:array<struct<value:string,language:string>>,short:array<struct<value:string,language:string>>>,
  `phones` array<string>,
  `id` string,
  `sources` array<struct<property:string,dataset:string,recordId:string,confidence:double>>,
  `websites` array<string>,
  `geometry` binary,
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>)
PARTITIONED BY (
  `type` string)
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/<release-version>/theme=places'


-- Load partitions
MSCK REPAIR TABLE `places`


-- =====================================================================
-- Transportation theme
-- =====================================================================

CREATE EXTERNAL TABLE `transportation`(
  `subtype` string,
  `sourcetags` map<string,string>,
  `road` string,
  `updatetime` string,
  `names` struct<common:array<struct<value:string,language:string>>,official:array<struct<value:string,language:string>>,alternate:array<struct<value:string,language:string>>,short:array<struct<value:string,language:string>>>,
  `connectors` array<string>,
  `version` int,
  `id` string,
  `sources` array<struct<property:string,dataset:string,recordId:string,confidence:double>>,
  `geometry` binary,
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>)
PARTITIONED BY (
  `type` string)
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/<release-version>/theme=transportation'


-- Load partitions
MSCK REPAIR TABLE `transportation`
