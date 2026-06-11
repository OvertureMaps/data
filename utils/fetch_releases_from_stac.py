import json
import urllib.request

import duckdb

STAC_CATALOG = "https://stac.overturemaps.org/catalog.json"
S3_BASE = "s3://overturemaps-us-west-2/release"

VIEWS = [
    ("address", "addresses", "address"),
    ("bathymetry", "base", "bathymetry"),
    ("building", "buildings", "building"),
    ("building_part", "buildings", "building_part"),
    ("connector", "transportation", "connector"),
    ("division", "divisions", "division"),
    ("division_area", "divisions", "division_area"),
    ("division_boundary", "divisions", "division_boundary"),
    ("infrastructure", "base", "infrastructure"),
    ("land", "base", "land"),
    ("land_cover", "base", "land_cover"),
    ("land_use", "base", "land_use"),
    ("place", "places", "place"),
    ("segment", "transportation", "segment"),
    ("water", "base", "water"),
]


def fetch_catalog(url: str) -> dict:
    with urllib.request.urlopen(url) as response:
        return json.loads(response.read())


def parse_releases(catalog: dict) -> dict:
    latest = catalog["latest"]
    releases = sorted(
        [
            link["href"].split("/")[1]
            for link in catalog["links"]
            if link["rel"] == "child"
        ],
        reverse=True,
    )
    return {"latest": latest, "releases": releases}


def build_views_sql(latest: str, s3_base: str = S3_BASE) -> str:
    stmts = ["INSTALL spatial;", "LOAD spatial;"]
    for view_name, theme, type_ in VIEWS:
        path = f"{s3_base}/{latest}/theme={theme}/type={type_}/*.parquet"
        stmts.append(
            f"CREATE OR REPLACE VIEW {view_name} AS (\n"
            f"  SELECT * FROM read_parquet('{path}')\n);"
        )
    return "\n\n".join(stmts)


def create_duckdb_views(db_path: str, latest: str, s3_base: str = S3_BASE) -> None:
    conn = duckdb.connect(db_path)
    conn.sql(build_views_sql(latest, s3_base))


def main():
    catalog = fetch_catalog(STAC_CATALOG)
    output = parse_releases(catalog)

    for release in output["releases"]:
        print(f" - {release}")

    with open("releases.json", "w") as f:
        f.write(json.dumps(output, indent=4))

    create_duckdb_views("latest.ddb", output["latest"])


if __name__ == "__main__":
    main()
