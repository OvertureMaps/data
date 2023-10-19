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

-- October 2023 Release: 

CREATE EXTERNAL TABLE `overture_2023_10_19_alpha_0`(
  `categories` struct<main:string,alternate:array<string>>, 
  `level` int, 
  `socials` array<string>, 
  `subtype` string, 
  `numfloors` int, 
  `entityid` string, 
  `class` string, 
  `sourcetags` map<string,string>, 
  `localitytype` string, 
  `emails` array<string>, 
  `drivingside` string, 
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
  `geometry` binary, 
  `context` string, 
  `height` double, 
  `maritime` boolean, 
  `sources` array<struct<property:string,dataset:string,recordId:string,confidence:double>>, 
  `websites` array<string>, 
  `issalt` boolean, 
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>)
PARTITIONED BY ( 
  `theme` string, 
  `type` string)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION
  's3://overturemaps-us-west-2/release/2023-10-19-alpha.0'



-- =====================================================================
-- The below queries are for the July 2023 Data Release



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
  's3://overturemaps-us-west-2/release/2023-10-19-alpha.0/theme=admins'


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
  's3://overturemaps-us-west-2/release/2023-10-19-alpha.0/theme=buildings'


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
  's3://overturemaps-us-west-2/release/2023-10-19-alpha.0/theme=places'


MSCK REPAIR TABLE `places`


-- =====================================================================
-- Transportation theme
-- =====================================================================

CREATE EXTERNAL TABLE `transportation`(
  `id` string,
  `updateTime` timestamp,
  `version` int,
  `level` int,
  `subType` varchar(4),
  `connectors` array<string>,
  `road` string,
  `sources` array<map<string,string>>,
  `bbox` struct<minX:double,maxX:double,minY:double,maxY:double>,
  `geometry` binary)
PARTITIONED BY (
  `type` varchar(9))
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/2023-10-19-alpha.0/theme=transportation'


MSCK REPAIR TABLE `transportation`
