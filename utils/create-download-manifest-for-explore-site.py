import json
import logging
import re

import pyarrow.dataset as ds
import pyarrow.fs as fs

logging.basicConfig()
logger = logging.getLogger("Explore Site Download Manifest")
logger.setLevel(logging.INFO)


# First, read the releases.json to get the latest release path
releases = json.load(open("releases.json", "r"))
logger.info(f"Latest release: {releases.get('latest')}")

# Now read the paths
filesystem = fs.S3FileSystem(anonymous=True, region="us-west-2")

# Registry path (without s3:// prefix for filesystem operations)
release_path = f"overturemaps-us-west-2/release/{releases.get('latest')}"

logger.info(f"Scanning path: {release_path}")

# Get all files in the registry directory using proper FileSelector
registry_selector = fs.FileSelector(release_path, recursive=True)
all_files = filesystem.get_file_info(registry_selector)

# Filter for parquet files only
parquet_files = [
    f for f in all_files if f.path.endswith(".parquet") and f.type == fs.FileType.File
]

download_manifest = {"release_version": releases.get("latest"), "types": {}}

# Process each parquet file
for file_info in parquet_files:
    logger.info(f"Processing: {file_info.path}")

    # Create dataset for this single file
    file_dataset = ds.dataset(file_info.path, filesystem=filesystem, format="parquet")

    metadata = file_dataset.schema.metadata[b"geo"]
    meta_str = metadata.decode("utf-8")
    metadata_obj = json.loads(meta_str)
    bbox = metadata_obj["columns"]["geometry"]["bbox"]

    match = re.search(r"theme=([^/]+)/type=([^/]+)", file_info.path)
    if match:
        ovt_theme = match.group(1)
        ovt_type = match.group(2)
        print(ovt_theme, ovt_type, bbox)

        if download_manifest["types"].get(ovt_type) is None:
            download_manifest["types"][ovt_type] = []

        download_manifest["types"][ovt_type].append(
            {"path": "/".join(file_info.path.split("/")[-3:]), "bbox": bbox}
        )

with open("explore-site-download-manifest.json", "w") as outfile:
    outfile.write(json.dumps(download_manifest, indent=4))
