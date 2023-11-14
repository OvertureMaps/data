Welcome to the Overture Maps Data Repo
===
This repository includes instructions and sample queries to access Overture Maps Data.

We also welcome feedback about Overture Maps data in the [Discussions](https://github.com/OvertureMaps/data/discussions/new/choose). Feedback on the data *schema*, is best provided in the [discussions in the *schema* repository](https://github.com/OvertureMaps/schema/discussions).


Accessing Overture Maps Data
---

Overture Maps data is available in cloud-native [Parquet](https://parquet.apache.org/docs/) format.
There is no single Overture "entire planet" file to be downloaded. Instead, we
have organized the data for the `Overture 2023-11-14-alpha.0` release by theme and type at the following locations:

### Data Location

<table>
  <tr>
    <th>Theme</th>
    <th>Location</th>
  </tr>
  <tr>
    <th>Admins</th>
    <td>
      <ul>
        <li>Amazon S3: <code>s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=admins</code></li>
        <li>Microsoft Azure: <code>https://overturemapswestus2.blob.core.windows.net/release/2023-11-14-alpha.0/theme=admins</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <th>Buildings</th>
    <td>
      <ul>
        <li>Amazon S3: <code>s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=buildings</code></li>
        <li>Microsoft Azure: <code>https://overturemapswestus2.blob.core.windows.net/release/2023-11-14-alpha.0/theme=buildings</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <th>Places</th>
    <td>
      <ul>
        <li>Amazon S3: <code>s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=places</code></li>
        <li>Microsoft Azure: <code>https://overturemapswestus2.blob.core.windows.net/release/2023-11-14-alpha.0/theme=places</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <th>Transportation</th>
    <td>
      <ul>
        <li>Amazon S3: <code>s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=transportation</code></li>
        <li>Microsoft Azure: <code>https://overturemapswestus2.blob.core.windows.net/release/2023-11-14-alpha.0/theme=transportation</code></li>
      </ul>
    </td>
  </tr>
    <tr>
    <th>Base</th>
    <td>
      <ul>
        <li>Amazon S3: <code>s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=base</code></li>
        <li>Microsoft Azure: <code>https://overturemapswestus2.blob.core.windows.net/release/2023-11-14-alpha.0/theme=base</code></li>
      </ul>
    </td>
  </tr>
</table>

### Parquet Schema
The Parquet files match the [Overture Data Schema](https://docs.overturemaps.org/)
for each theme with the following enhancements:

1. The `id` column contains _temporary_ IDs that are not yet part of the [Global Entity Reference System (GERS)](https://docs.overturemaps.org/gers/).
   These IDs are not yet stable and are likely to change significantly up
   to the point that GERS is released.
2. The `bbox` column is a `struct` with the following attributes:
   `minX`, `maxX`, `minY`, `maxY`. This column allows you to craft more
   efficient spatial queries when running SQL against the cloud.
3. The `geometry` column is encoded as WKB.

## Accessing Overture Maps Data
You can access Overture Parquet data files directly from the cloud, or copy them
to your preferred destination, or download them locally. We do encourage you to
fetch the data directly from the cloud using one of the SQL query options
documented below.

### 1. Amazon Athena (SQL)
1. You will need an AWS account.
2. Ensure that you are operating in the us-west-2 region.
3. In the [Amazon Athena](https://aws.amazon.com/athena/) console on AWS:
   - Run `CREATE EXTERNAL TABLE` queries to set up your view of the tables: [click for queries](athena_setup_queries.sql).
   - Be sure to load the partitions by running `MSCK REPAIR <tablename>;` or choosing "Load Partitions" from the table options menu.

Example Athena SQL query to download a CSV of places in Seattle:

```sql
SELECT
       CAST(names AS JSON),
       geometry -- WKB
FROM
       places
WHERE
       bbox.minX > -122.4447744
   AND bbox.maxX < -122.2477071
   AND bbox.minY > 47.5621587
   AND bbox.maxY < 47.7120663
```

More information on using Athena is available in the [Amazon Athena User Guide](https://docs.aws.amazon.com/athena/latest/ug/what-is.html).

### 2. Microsoft Synapse (SQL)

1. You will need an Azure account.
2. Create a [Synapse workspace](https://learn.microsoft.com/en-us/azure/synapse-analytics/get-started-create-workspace).

Example SQL query to read places in Seattle:

```sql
SELECT TOP 10 *
  FROM
       OPENROWSET(
           BULK 'https://overturemapswestus2.blob.core.windows.net/release/2023-11-14-alpha.0/theme=places/type=place/',
           FORMAT = 'PARQUET'
       )
  WITH
       (
           names VARCHAR(MAX),
           categories VARCHAR(MAX),
           websites VARCHAR(MAX),
           phones VARCHAR(MAX),
           bbox VARCHAR(200),
           geometry VARBINARY(MAX)
       )
    AS
       [result]
 WHERE
       TRY_CONVERT(FLOAT, JSON_VALUE(bbox, '$.minx')) > -122.4447744
   AND TRY_CONVERT(FLOAT, JSON_VALUE(bbox, '$.maxx')) < -122.2477071
   AND TRY_CONVERT(FLOAT, JSON_VALUE(bbox, '$.miny')) > 47.5621587
   AND TRY_CONVERT(FLOAT, JSON_VALUE(bbox, '$.maxy')) < 47.7120663
```

More information is available at [Query files using a serverless SQL pool - Training | Microsoft Learn](https://learn.microsoft.com/en-us/training/modules/query-data-lake-using-azure-synapse-serverless-sql-pools/3-query-files).

### 3. DuckDB (SQL)
[DuckDB](https://duckdb.org/) is an analytics tool you can install
locally that can efficiently query remote Parquet files using SQL. It
will only download the subset of files it needs to fulfil your queries.

Ensure you are using DuckDB >= 0.9.1 to support the `SRS` parameter. 

If, for example, you wanted to download the administrative boundaries
for all `adminLevel=2` features, you could run:

```sql
CREATE VIEW admins_view AS
SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=admins/type=*/*', filename=true, hive_partitioning=1);
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
) TO 'countries.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');
```

This will create a `countries.geojson` file containing 280 country
polygons and multipolygons.

To make this query work in DuckDB, you may need a couple of one-time
setup items to install the [duckdb_spatial](https://github.com/duckdblabs/duckdb_spatial)
and [httpfs](https://duckdb.org/docs/guides/import/s3_import.html) extensions:

```sql
INSTALL spatial;
INSTALL httpfs;
```

And a couple of per-session items to load the extensions and tell DuckDB which
S3 region to find Overture's data bucket in:

```sql
LOAD spatial;
LOAD httpfs;
SET s3_region='us-west-2';
```
To get the same query working against Azure blob storage, you need to install and load Azure extension, and set connection string.

```sql
INSTALL azure;
LOAD azure;
SET azure_storage_connection_string = 'DefaultEndpointsProtocol=https;AccountName=overturemapswestus2;AccountKey=;EndpointSuffix=core.windows.net';
```
Here is an example path to be passed to ```read_parquet``` method: ```azure://release/2023-11-14-alpha.0/theme=admins/type=*/*```
<!-- #### Jupyter Notebooks + DuckDB

**TODO: Link below doesn't exist yet. 👇**

Check out [example notebooks here]() for instructions on how to use DuckDB inside a notebook for a more interactive experience. -->

### 4. Apache Sedona (Python + Spatial SQL)

You can get a single-node Sedona Docker image from [Apache Software Foundation DockerHub](https://hub.docker.com/r/apache/sedona) and run `docker run -p 8888:8888 apache/sedona:latest`. A Jupyter Lab and notebook examples will be available at http://localhost:8888/. You can also install Sedona to Databricks, AWS EMR and Snowflake using [Wherobots](https://www.wherobots.ai/demo).

The following Python + Spatial SQL code reads the Places dataset and runs a spatial filter query on it.

```
from sedona.spark import *

config = SedonaContext.builder().config("fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.AnonymousAWSCredentialsProvider").getOrCreate()
sedona = SedonaContext.create(config)

df = sedona.read.format("geoparquet").load("s3a://overturemaps-us-west-2/release/2023-11-14-alpha.0/theme=places/type=place")
df.filter("ST_Contains(ST_GeomFromWKT('POLYGON((-122.48 47.43,-122.20 47.75,-121.92 47.37,-122.48 47.43))'), geometry) = true").show()
```

For more examples from wherobots, check out their Overture-related [Notebook examples](https://github.com/wherobots/OvertureMaps).


### 5. Download the Parquet files
You can download the Parquet files from either Azure Blob Storage or Amazon S3 at the locations given in the table at the top of the page.

After installing the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html),
you can download the files from S3 using the below command. Set `<DESTINATION>` to a local directory path to
download the files, or to an `s3://` path you control to copy them into your S3 bucket.

```bash
aws s3 cp --region us-west-2 --no-sign-request --recursive s3://overturemaps-us-west-2/release/2023-11-14-alpha.0/ <DESTINATION>
```

The total size of all of the files is a little over 200 GB.

You can download the files from Azure Blob Storage using
[Azure Storage Explorer](https://azure.microsoft.com/en-us/products/storage/storage-explorer/)
or the [AzCopy](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json&bc=%2Fazure%2Fstorage%2Fblobs%2Fbreadcrumb%2Ftoc.json#download-azcopy)
command. An example `azcopy` command is given below.

```bash
azcopy copy "https://overturemapswestus2.dfs.core.windows.net/release/2023-11-14-alpha.0/" "<<local directory path>>"  --recursive```
```


---

Data Release Feedback
---
We are very interested in feedback on the Overture data. Please use the [Discussion](https://github.com/OvertureMaps/data/discussions) section of this repo to comment. Tagging it with the relevant theme name (Places, Transportation) will help direct your ideas.

### Submissions

**Category selection**
1. Click [HERE](https://github.com/OvertureMaps/data/discussions/new/choose) to submit your feedback
2. Select the layer discussion category
   - Administration Boundaries
   - Transportation
   - Places
   - Buildings

**Discussion outline**
1. Add a title
2. Outline your feedback with as much detail as possible
3. Click [Start Discussion]

### OMF Review
The associated Task Force will carefully review each submission and offer feedback where required.
