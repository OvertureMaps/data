import json
import logging

import pyarrow.dataset as ds
import pyarrow.fs as fs

# Set up logging
logging.basicConfig()
logger = logging.getLogger("registry-manifest")
logger.setLevel(logging.INFO)


def create_registry_manifest():
    """
    Simple script to read all parquet files in s3://overturemaps-us-west-2/registry/
    and create a JSON manifest with min/max IDs and file paths.
    """

    # Initialize S3 filesystem (following the pattern from registry-manifest.py)
    filesystem = fs.S3FileSystem(anonymous=True, region="us-west-2")

    # Registry path (without s3:// prefix for filesystem operations)
    registry_path = "overturemaps-us-west-2/registry"

    logger.info(f"Scanning registry path: {registry_path}")

    # Get all files in the registry directory using proper FileSelector
    registry_selector = fs.FileSelector(registry_path, recursive=True)
    all_files = filesystem.get_file_info(registry_selector)

    # Filter for parquet files only
    parquet_files = [
        f
        for f in all_files
        if f.path.endswith(".parquet") and f.type == fs.FileType.File
    ]

    logger.info(f"Found {len(parquet_files)} parquet files in registry")

    # Simple arrays for bounds and files
    bounds = []
    files = []

    # Process each parquet file
    for file_info in parquet_files:
        logger.info(f"Processing: {file_info.path}")

        try:
            # Create dataset for this single file
            file_dataset = ds.dataset(
                file_info.path, filesystem=filesystem, format="parquet"
            )

            # Get fragments
            fragments = list(file_dataset.get_fragments())

            if not fragments:
                logger.warning(f"No fragments found for {file_info.path}")
                continue

            # Use first fragment to get schema
            fragment = fragments[0]
            schema = fragment.metadata.schema.to_arrow_schema()

            # Check if 'id' column exists
            has_id_column = "id" in [field.name for field in schema]

            if has_id_column:
                # Since ID field is always sorted, we only need first and last row group
                min_id = None
                max_id = None

                # Find the ID column index
                id_column_index = next(
                    i for i, field in enumerate(schema) if field.name == "id"
                )

                # Get min from first row group and max from last row group
                first_fragment = fragments[0]
                last_fragment = fragments[-1]

                # Get min from first row group of first fragment
                first_metadata = first_fragment.metadata
                if first_metadata.num_row_groups > 0:
                    first_row_group = first_metadata.row_group(0)
                    first_id_column = first_row_group.column(id_column_index)

                    if (
                        first_id_column.statistics
                        and first_id_column.statistics.has_min_max
                    ):
                        min_id = first_id_column.statistics.min
                        if isinstance(min_id, bytes):
                            min_id = min_id.decode("utf-8")

                # Get max from last row group of last fragment
                last_metadata = last_fragment.metadata
                if last_metadata.num_row_groups > 0:
                    last_row_group = last_metadata.row_group(
                        last_metadata.num_row_groups - 1
                    )
                    last_id_column = last_row_group.column(id_column_index)

                    if (
                        last_id_column.statistics
                        and last_id_column.statistics.has_min_max
                    ):
                        max_id = last_id_column.statistics.max
                        if isinstance(max_id, bytes):
                            max_id = max_id.decode("utf-8")

                filename = file_info.path.replace(
                    "overturemaps-us-west-2/registry/", ""
                )
                bounds.append([min_id, max_id])
                files.append(filename)

                logger.info(
                    f"Successfully processed {file_info.path}: {min_id} - {max_id}"
                )
            else:
                logger.warning(f"No 'id' column found in {file_info.path}")

        except Exception as e:
            logger.error(f"Error processing {file_info.path}: {e}")

    # Create simple manifest
    manifest = {"bounds": bounds, "files": files}

    # Write manifest to JSON file (compact format for smallest size)
    output_file = "registry-manifest.json"
    with open(output_file, "w") as f:
        json.dump(manifest, f, separators=(",", ":"))

    print(f"Registry manifest written to {output_file}")
    print(f"Total files processed: {len(manifest['files'])}")

    return manifest


if __name__ == "__main__":
    manifest = create_registry_manifest()
