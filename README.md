Welcome to the Overture Maps Data Repo
===
This repository includes instructions and sample queries to access Overture Maps Data.

We also welcome feedback about Overture Maps data in the [Discussions](https://github.com/OvertureMaps/data/discussions/new/choose). Feedback on the data *schema*, is best provided in the [discussions in the *schema* repository](https://github.com/OvertureMaps/schema/discussions).


Accessing Overture Maps Data
---

Overture Maps data is available in cloud-native [Parquet](https://parquet.apache.org/docs/) format.
There is no single Overture "entire planet" file to be downloaded. Instead, we
have organized the data for the `Overture 2024-03-12-alpha.0` release by theme and type at the following locations:

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
        <li>Amazon S3: <code>s3://overturemaps-us-west-2/release/2024-03-12-alpha.0/theme=admins</code></li>
        <li>Microsoft Azure: <code>https://overturemapswestus2.blob.core.windows.net/release/2024-03-12-alpha.0/theme=admins</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <th>Buildings</th>
    <td>
      <ul>
        <li>Amazon S3: <code>s3://overturemaps-us-west-2/release/2024-03-12-alpha.0/theme=buildings</code></li>
        <li>Microsoft Azure: <code>https://overturemapswestus2.blob.core.windows.net/release/2024-03-12-alpha.0/theme=buildings</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <th>Places</th>
    <td>
      <ul>
        <li>Amazon S3: <code>s3://overturemaps-us-west-2/release/2024-03-12-alpha.0/theme=places</code></li>
        <li>Microsoft Azure: <code>https://overturemapswestus2.blob.core.windows.net/release/2024-03-12-alpha.0/theme=places</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <th>Transportation</th>
    <td>
      <ul>
        <li>Amazon S3: <code>s3://overturemaps-us-west-2/release/2024-03-12-alpha.0/theme=transportation</code></li>
        <li>Microsoft Azure: <code>https://overturemapswestus2.blob.core.windows.net/release/2024-03-12-alpha.0/theme=transportation</code></li>
      </ul>
    </td>
  </tr>
    <tr>
    <th>Base</th>
    <td>
      <ul>
        <li>Amazon S3: <code>s3://overturemaps-us-west-2/release/2024-03-12-alpha.0/theme=base</code></li>
        <li>Microsoft Azure: <code>https://overturemapswestus2.blob.core.windows.net/release/2024-03-12-alpha.0/theme=base</code></li>
      </ul>
    </td>
  </tr>
</table>

### Parquet Schema
The Parquet files match the [Overture Data Schema](https://docs.overturemaps.org/)
for each theme with the following enhancements:

1. The `id` column contains unique identifiers in the [Global Entity Reference System (GERS)](https://docs.overturemaps.org/gers/) format.
2. The `bbox` column is a `struct` with the following attributes:
   `minX`, `maxX`, `minY`, `maxY`. This column allows you to craft more
   efficient spatial queries when running SQL against the cloud.
3. The `geometry` column is encoded as WKB (the files are geoparquet).

## Accessing Overture Maps Data
You can access Overture Parquet data files directly from the cloud, or copy them
to your preferred destination, or download them locally. We do encourage you to
fetch the data directly from the cloud using one of the SQL query options. 

### [See instructions on our how-to pages (labs.overturemaps.org/how-to/)](https://labs.overturemaps.org/how-to/accessing-data/)


### 4. Apache Sedona (Python + Spatial SQL)

You can get a single-node Sedona Docker image from [Apache Software Foundation DockerHub](https://hub.docker.com/r/apache/sedona) and run `docker run -p 8888:8888 apache/sedona:latest`. A Jupyter Lab and notebook examples will be available at http://localhost:8888/. You can also install Sedona to Databricks, AWS EMR and Snowflake using [Wherobots](https://www.wherobots.ai/demo).

The following Python + Spatial SQL code reads the Places dataset and runs a spatial filter query on it.

```
from sedona.spark import *

config = SedonaContext.builder().config("fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.AnonymousAWSCredentialsProvider").getOrCreate()
sedona = SedonaContext.create(config)

df = sedona.read.format("geoparquet").load("s3a://overturemaps-us-west-2/release/2024-03-12-alpha.0/theme=places/type=place")
df.filter("ST_Contains(ST_GeomFromWKT('POLYGON((-122.48 47.43,-122.20 47.75,-121.92 47.37,-122.48 47.43))'), geometry) = true").show()
```

For more examples from wherobots, check out their Overture-related [Notebook examples](https://github.com/wherobots/OvertureMaps).
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
