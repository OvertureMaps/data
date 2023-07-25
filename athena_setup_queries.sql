-- Setting up the Overture Maps Data Tables on Amazon Athena

-- Admins theme
CREATE EXTERNAL TABLE `admins`(
  `id` string,
  `updatetime` string,
  `version` int,
  `names` map<string,array<map<string,string>>>,
  `adminlevel` int,
  `maritime` string,
  `subtype` string,
  `localitytype` string,
  `context` string,
  `isocountrycodealpha2` string,
  `isosubcountrycode` string,
  `defaultlanugage` string,
  `drivingside` string,
  `sources` array<map<string,string>>,
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>,
  `geometry` binary)
PARTITIONED BY (
  `type` string)
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/2023-07-26-alpha.0/theme=admins'


-- Buildings theme
CREATE EXTERNAL TABLE `buildings`(
  `id` string,
  `updatetime` string,
  `version` int,
  `names` map<string,array<map<string,string>>>,
  `level` int,
  `height` double,
  `numfloors` int,
  `class` string,
  `sources` array<map<string,string>>,
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>,
  `geometry` binary)
PARTITIONED BY (
  `type` varchar(8))
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/2023-07-26-alpha.0/theme=buildings'


-- Places theme
CREATE EXTERNAL TABLE `places`(
  `id` string,
  `updatetime` string,
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
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>,
  `geometry` binary)
PARTITIONED BY (
  `type` varchar(5))
STORED AS PARQUET
LOCATION
  's3://overturemaps-us-west-2/release/2023-07-26-alpha.0/theme=places'


-- Transportation theme
