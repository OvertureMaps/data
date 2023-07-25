Welcome to the Overture Maps Data Repo
===
This repository includes instructions and sample queries to access Overture Maps Data.

We also welcome feedback about Overture Maps data in the [Discussions](https://github.com/OvertureMaps/data/discussions). Feedback on the *data schema*, is best provided in the [discussions in the *schema* repository](https://github.com/OvertureMaps/schema/discussions).


Accessing Overture Maps Data
---

Overture Maps data is available in cloud-native [Parquet](https://parquet.apache.org/docs/) format. There is no single Overture "entire planet" file to be downloaded, instead, we have organized the data by theme and type at the following locations:

### Data Location
|Theme| Amazon S3 | Microsoft Azure |
|-----|--------|----|
|Admins| s3://overturemaps-us-west-2/release/2023-07-26/theme=admins | overturemapswestus2.dfs.core.windows.net/release/ |
|Buildings| s3://overturemaps-us-west-2/release/2023-07-26/theme=buildings | overturemapswestus2.dfs.core.windows.net/release/ |
|Places| s3://overturemaps-us-west-2/release/2023-07-26/theme=places | overturemapswestus2.dfs.core.windows.net/release/ |
|Transportation| s3://overturemaps-us-west-2/release/2023-07-26/theme=transportation | overturemapswestus2.dfs.core.windows.net/release/ |

#### Parquet Schema
The parquet files match the Overture Data Schema for each theme with the following enhancments:

1. The `geometry` column is encoded as WKB.
2. The `bbox` column is a `struct` with the following attributes: `minX`, `maxX`, `minY`, `maxY`.
3. The `id` column contains _temporary_ ids that are not yet part of the [Global Entity Reference System (GERS)](https://docs.overturemaps.org/gers/). There is no guarantee of stability or consistenty with the ids in this data release.

## Accessing Overture Maps Data
The parquet files can be accessed either in the cloud or downloaded locally. We encourage users to access the data in the cloud via one of the methods below that interface with the parquet files through SQL queries. This will allow you to download only the data that you want.

### 1. Amazon Athena (SQL)
1. You will need an AWS account with access to Athena.
2. Run the queries in the [athena_setup_queries.sql](https://github.com/overturemaps/data/ ... ) file to set up the tables.
3. Be sure to load the partitions by running `MSCK REPAIR <tablename>;` or choosing "Load Partitions" from the table options menu.

Example query to download a CSV of places in Seattle:

```sql
SELECT
   CAST(names) AS JSON,
   wkt AS wkt_geometry
FROM
   places
WHERE
   <bbox filter>
```

This CSV includes


### 2. Microsoft Synapse (SQL)
You can also explore Overture data using Azure Synapse Serverless SQL Pool.

First, you will need to create a [Synapse workspace](https://learn.microsoft.com/en-us/azure/synapse-analytics/get-started-create-workspace).

Here is an example query to read places data in Seattle bounding box:

```sql
SELECT TOP 10
    *
FROM
    OPENROWSET(
        BULK 'https://mdpcosmostoolsgen2.blob.core.windows.net/froms3/m5places/type=place/*',
        FORMAT = 'PARQUET'
    )
    WITH (
        names VARCHAR(MAX),
        categories VARCHAR(MAX),
        websites VARCHAR(MAX),
        phones VARCHAR(MAX),
        bbox VARCHAR(200),
        geometry VARCHAR(MAX)
    )
     AS [result]
     WHERE
     TRY_CONVERT(FLOAT, JSON_VALUE(bbox, '$.minx')) > -122.4447744 AND TRY_CONVERT(FLOAT, JSON_VALUE(bbox, '$.maxx')) < -122.2477071 AND
     TRY_CONVERT(FLOAT, JSON_VALUE(bbox, '$.miny')) > 47.5621587 AND TRY_CONVERT(FLOAT, JSON_VALUE(bbox, '$.maxy')) < 47.7120663
```

More information is available at [Query files using a serverless SQL pool - Training | Microsoft Learn](https://learn.microsoft.com/en-us/training/modules/query-data-lake-using-azure-synapse-serverless-sql-pools/3-query-files).

### 3. DuckDB (SQL)
DuckDB can read the parquet files on S3 directly while downloading only what is required to execute your query.

If, for example, you wanted to download the administrative boundaries for all adminLevel=2 features, you could run:

```sql
COPY (
    SELECT
        type,
        subtype,
        localitytype,
        adminlevel,
        isocountrycodealpha2,
        JSON(names) as names,
        JSON(sources) as sources,
        ST_GeomFromText(geometry) as geometry
    FROM read_parquet('s3://omf-internal-usw2/staging/admins/type=*/*', filename=true, hive_partitioning=1)
    WHERE adminlevel = 2 and ST_GeometryType(ST_GeomFromText(geometry)) IN ('POLYGON','MULTIPOLYGON')
) TO 'countries.geojson'
WITH (FORMAT GDAL, DRIVER 'GeoJSON');
```
This will create a countries.geojson file containing 265 country polygons and multipolygons.

#### Jupyter Notebooks + DuckDB
Check out [example notebooks here]() for instructions on how to use DuckDB inside a notebook for a more interactive experience.


### 4. Download the Parquet files.
You can download the parquet files from both Azure blob storage and Amazon S3 at the locations in the table at the top of the page.

After installing the [Amazon CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), you can copy the Overture files from S3 with the following command:
```bash
aws s3 cp --recursive s3://overturemaps-us-west-2-parquet/release/blahblah/ [LOCAL_PATH]
```

For more information on Azure Storage Explorer or `azcopy`, see [Copy or move data to Azure Storage by using AzCopy](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json&bc=%2Fazure%2Fstorage%2Fblobs%2Fbreadcrumb%2Ftoc.json#download-azcopy) or
[Azure Storage Explorer](https://azure.microsoft.com/en-us/products/storage/storage-explorer/).

Example command to download a directory from Azure Blob storage:

```bash
azcopy copy "https://overturemapswestus2.dfs.core.windows.net/release/<<directory path>>" "<<local directory path>>"  --recursive```
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
