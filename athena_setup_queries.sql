-- Setting up the Overture Maps Data Tables on Amazon Athena

-- Admins theme
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


-- Buildings theme
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


-- Places theme
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


-- Transportation theme
