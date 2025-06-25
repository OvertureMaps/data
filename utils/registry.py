import argparse
import csv
import json

import duckdb

REGISTRY_PATH = "s3://overturemaps-us-west-2/registry/2025-06-25.0/*.parquet"
RELEASE_PATH = "s3://overturemaps-us-west-2/release/2025-06-25.0"


class RegistryQuery:

    def __init__(self, id: str):
        self.id = id
        self.con = duckdb.connect()
        self.con.execute(f"INSTALL spatial;")
        self.con.execute(f"LOAD spatial;")
        self.con.execute(f"SET VARIABLE registry_path = '{REGISTRY_PATH}';")
        self.con.execute(f"SET VARIABLE lookup_id = '{id.lower()}';")
        self.con.execute(f"SET VARIABLE release_path = '{RELEASE_PATH}'")

    def get_registry_result(self):
        self.con.execute(
            f"""
            CREATE OR REPLACE TABLE registry_result AS (
                SELECT
                    id,
                    bbox, 
                    concat(getvariable('release_path'), path) as filepath
                FROM read_parquet(getvariable('registry_path'))
                    WHERE id = getvariable('lookup_id')
            );
        """
        )

        self.con.execute(
            """
            SET variable filepath = (select filepath FROM registry_result);
            SET variable xmin = (select bbox.xmin FROM registry_result);
            SET variable ymin = (select bbox.ymin FROM registry_result);
            SET variable xmax = (select bbox.xmax FROM registry_result);
            SET variable ymax = (select bbox.ymax FROM registry_result);
        """
        )

        self.con.table("registry_result").show()

    def query_release(self):
        self.con.execute(
            """
            CREATE OR REPLACE TABLE result AS (
                SELECT *
                FROM read_parquet(getvariable('filepath')) WHERE id = getvariable('lookup_id') 
                    AND bbox.xmin = getvariable('xmin')
                    AND bbox.ymin = getvariable('ymin')
                    AND bbox.xmax = getvariable('xmax')
                    AND bbox.ymax = getvariable('ymax')
            );
        """
        )

        self.con.table("result").show()

        self.con.execute(
            f"""
            COPY(
                SELECT  id, 
                        geometry, 
                        JSON(sources) AS sources, 
                        JSON(bbox) AS bbox
                FROM result
            ) TO '{self.id}.geojson' WITH (FORMAT GDAL, DRIVER 'GeoJSON');
        """
        )

        self.con.execute(
            f"""
            COPY(
                SELECT * EXCLUDE (id,geometry, sources, bbox)
                FROM result
            ) TO '{self.id}.csv'
        """
        )

    def rewrite_output_as_geojson(self):
        with open(f"{args.id}.geojson", "r") as in_geojson:
            feature = json.load(in_geojson).get("features")[0]

            feature["bbox"] = [
                feature.get("properties").get("bbox").get("xmin"),
                feature.get("properties").get("bbox").get("ymin"),
                feature.get("properties").get("bbox").get("xmax"),
                feature.get("properties").get("bbox").get("ymin"),
            ]

            del feature["properties"]["bbox"]

            with open(f"{args.id}.csv", "r") as in_csv:
                csv_reader = csv.DictReader(in_csv)

                for row in csv_reader:
                    feature["properties"] = {**feature["properties"], **row}

                json.dump(feature, open(f"{args.id}.geojson", "w"), indent=2)

                return json.dumps(feature)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Query the GERS registry")
    parser.add_argument(
        "-id",
        "--id",
        help="ID of the feature",
        default="08b2ab2c0a0e6fff0200ce715cbdb439",
    )
    args = parser.parse_args()

    runner = RegistryQuery(args.id)

    runner.get_registry_result()

    runner.query_release()

    json_str = runner.rewrite_output_as_geojson()
