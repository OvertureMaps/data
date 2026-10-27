<p align="center">
  <a href="https://overturemaps.org">
    <img src="assets/overture-maps-foundation.png" alt="Overture Maps Foundation" width="450">
  </a>
</p>

<h1 align="center">Overture Maps Data</h1>

<p align="center">
  Open map data in cloud-native Parquet, free to use under open licenses.
</p>

<p align="center">
  <a href="https://docs.overturemaps.org">Docs</a> ·
  <a href="https://docs.overturemaps.org/schema/">Schema</a> ·
  <a href="https://stac.overturemaps.org/catalog.json">STAC</a> ·
  <a href="https://docs.overturemaps.org/release-calendar.json">Release calendar</a> ·
  <a href="https://github.com/OvertureMaps/data/discussions">Discussions</a>
</p>

A reference for where Overture Maps data lives, how it is laid out, and where to send feedback. For tutorials, guides, and examples, see [docs.overturemaps.org](https://docs.overturemaps.org).

## Contents <!-- omit in toc -->

- [Location](#location)
- [Parquet Schema](#parquet-schema)
- [Release Discovery](#release-discovery)
- [Feedback](#feedback)

## Location

Overture Maps data is available in cloud-native [Parquet](https://parquet.apache.org/docs/) format. There is no single "entire planet" file to download. The data is partitioned by `theme` and `type` and hosted on Amazon S3 and Microsoft Azure Blob Storage.

Replace `<release>` below with a release version from the [STAC](#release-discovery), for example `2026-10-21.0`.

### Amazon S3

```text
s3://overturemaps-us-west-2/release/<release>/
  |-- theme=addresses/
  |-- theme=base/
  |-- theme=buildings/
  |-- theme=divisions/
  |-- theme=places/
  |-- theme=transportation/
```

### Microsoft Azure

```text
https://overturemapswestus2.blob.core.windows.net/release/<release>/
  |-- theme=addresses/
  |-- theme=base/
  |-- theme=buildings/
  |-- theme=divisions/
  |-- theme=places/
  |-- theme=transportation/
```

## Parquet Schema

The Parquet files match the [Overture Data Schema](https://docs.overturemaps.org/schema/) for each theme, with these additions:

1. The `id` column contains unique identifiers in the [Global Entity Reference System (GERS)](https://docs.overturemaps.org/gers/) format.
2. The `bbox` column is a `struct` with `xmin`, `xmax`, `ymin`, and `ymax`. Filter on it to make spatial queries against cloud storage more efficient.
3. The `geometry` column is WKB-encoded (the files are GeoParquet).

## Release Discovery

The [Overture STAC](https://stac.overturemaps.org/catalog.json) (SpatioTemporal Asset Catalog) is the authoritative source for discovering releases and determining which is the latest.

The STAC also serves [latest.ddb](https://stac.overturemaps.org/latest.ddb), a DuckDB file with one view per feature type over the latest release. It is linked from the root `catalog.json`. Run `LOAD spatial;` before querying it.

For upcoming release dates, see the [release calendar](https://docs.overturemaps.org/release-calendar.json) ([schema](https://docs.overturemaps.org/release-calendar.schema.json)).

## Feedback

Share feedback on Overture data in [Discussions](https://github.com/OvertureMaps/data/discussions/new/choose). Tag the post with the release and theme (for example Places or Transportation) and include as much detail as possible. The relevant task force reviews each submission.

Feedback on the data schema belongs in the [schema repository's Discussions](https://github.com/OvertureMaps/schema/discussions).

Use the issue templates to report a [data bug](https://github.com/OvertureMaps/data/issues/new?template=data_bug.yml) or propose a [new data source](https://github.com/OvertureMaps/data/issues/new?template=new_data_source_proposal.yml).
