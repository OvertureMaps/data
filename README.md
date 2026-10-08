# Welcome to the Overture Maps Data Repo <!-- omit in toc -->

We welcome feedback about Overture Maps data in the [Discussions](https://github.com/OvertureMaps/data/discussions/new/choose). Feedback on the data *schema*, is best provided in the [Discussions in the *schema* repository](https://github.com/OvertureMaps/schema/discussions).

## Overture Maps Data <!-- omit in toc -->

- [Location](#location)
  - [Amazon S3](#amazon-s3)
  - [Microsft Azure](#microsft-azure)
- [Parquet Schema](#parquet-schema)
- [Release Discovery](#release-discovery)
- [Data Release Feedback](#data-release-feedback)

### Location

Overture Maps data is available in cloud-native [Parquet](https://parquet.apache.org/docs/) format.
There is no single Overture "entire planet" file to download. Instead, the data is partitioned by both `theme` and `type` and made available on Amazon S3 and Microsoft Azure Blob Storage. Read more about Overture data and schema at [docs.overturemaps.org](https://docs.overturemaps.org).

The latest data release is available at the following locations:

#### Amazon S3

```text
s3://overturemaps-us-west-2/release/__OVERTURE_RELEASE/
  |-- theme=addresses/
  |-- theme=base/
  |-- theme=buildings/
  |-- theme=divisions/
  |-- theme=places/
  |-- theme=transportation/
```

#### Microsft Azure

```text
https://overturemapswestus2.blob.core.windows.net/release/__OVERTURE_RELEASE/
 |- theme=addresses
 |- theme=base
 |- theme=buildings
 |- theme=divisions
 |- theme=places
 |- theme=transportation
```

### Parquet Schema

The Parquet files match the [Overture Data Schema](https://docs.overturemaps.org/schema/)
for each theme with the following enhancements:

1. The `id` column contains unique identifiers in the [Global Entity Reference System (GERS)](https://docs.overturemaps.org/gers/) format.
2. The `bbox` column is a `struct` with the following attributes:
   `xmin`, `xmax`, `ymin`, `ymax`. This column allows you to craft more
   efficient spatial queries when running SQL against the cloud.
3. The `geometry` column is encoded as WKB (the files are geoparquet).

### Release Discovery

Use the [Overture STAC](https://stac.overturemaps.org/catalog.json) (SpatioTemporal Asset Catalog) for authoritative release data discovery and to determine the "latest"data.

For upcoming release dates, see the [docs.overturemaps.org/release-calendar.json](https://docs.overturemaps.org/release-calendar.json) ([schema](https://docs.overturemaps.org/release-calendar.schema.json)).

### Data Release Feedback

We are very interested in feedback on the Overture data. Please use the [Discussion](https://github.com/OvertureMaps/data/discussions) section of this repo to comment. Tagging it with the release and relevant theme name (Places, Transportation) will help direct your ideas. Please include as much detail as possible. The associated Task Force will carefully review each submission and offer feedback where required.
