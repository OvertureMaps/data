-- Setting up the Overture Maps Data Tables on AWS Athena


-- Buildings theme
CREATE EXTERNAL TABLE `buildings`(
  `theme` varchar(9),
  `version` int,
  `updatetime` string,
  `height` double,
  `numfloors` int,
  `level` int,
  `class` string,
  `names` map<string,array<map<string,string>>>,
  `sources` array<map<string,string>>,
  `geometry` string,
  `bbox` struct<minx:double,maxx:double,miny:double,maxy:double>)
PARTITIONED BY (
  `type` varchar(8))
STORED AS PARQUET
LOCATION
  's3://omf-internal-usw2/staging/buildings'
TBLPROPERTIES (
  'auto.purge'='false',
  'compression.level'='3',
  'has_encrypted_data'='false',
  'parquet.compression'='zstd'
)
