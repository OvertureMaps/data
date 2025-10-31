import duckdb, json
from obstore.store import S3Store

store = S3Store("overturemaps-us-west-2", region="us-west-2", skip_signature=True)

releases = store.list_with_delimiter("release/")

output = {}

for idx, release in enumerate(sorted(releases.get("common_prefixes"), reverse=True)):
    path = release.split("/")[1]
    if idx == 0:
        output["latest"] = path
        output["releases"] = []
    output["releases"].append(path)

    print(f" - {path}")

with open("releases.json", "w") as output_file:
    output_file.write(json.dumps(output, indent=4))

conn = duckdb.connect("latest.ddb")

conn.sql(
    f"""
INSTALL spatial;
LOAD spatial;

CREATE OR REPLACE VIEW address AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=addresses/type=address/*.parquet')
);

CREATE OR REPLACE VIEW bathymetry AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=base/type=bathymetry/*.parquet')
);

CREATE OR REPLACE VIEW building AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=buildings/type=building/*.parquet')
);

CREATE OR REPLACE VIEW building_part AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=buildings/type=building_part/*.parquet')
);

CREATE OR REPLACE VIEW connector AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=transportation/type=connector/*.parquet')
);

CREATE OR REPLACE VIEW division AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=divisions/type=division/*.parquet')
);

CREATE OR REPLACE VIEW division_area AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=divisions/type=division_area/*.parquet')
);

CREATE OR REPLACE VIEW division_boundary AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=divisions/type=division_boundary/*.parquet')
);

CREATE OR REPLACE VIEW infrastructure AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=base/type=infrastructure/*.parquet')
);

CREATE OR REPLACE VIEW land AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=base/type=land/*.parquet')
);

CREATE OR REPLACE VIEW land_cover AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=base/type=land_cover/*.parquet')
);

CREATE OR REPLACE VIEW land_use AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=base/type=land_use/*.parquet')
);

CREATE OR REPLACE VIEW place AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=places/type=place/*.parquet')
);

CREATE OR REPLACE VIEW segment AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=transportation/type=segment/*.parquet')
);

CREATE OR REPLACE VIEW water AS (
  SELECT * FROM read_parquet('s3://overturemaps-us-west-2/release/{output.get("latest")}/theme=base/type=water/*.parquet')
);
"""
)
