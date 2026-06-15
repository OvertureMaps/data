import json
import urllib.request
from urllib.parse import urlparse

import duckdb

STAC_CATALOG = "https://stac.overturemaps.org/catalog.json"
S3_BASE = "s3://overturemaps-us-west-2/release"
_USER_AGENT = "overturemaps-data/1.0"

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


def fetch_catalog(url: str, timeout: int = 30) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": _USER_AGENT})
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return json.loads(response.read())


def _release_id_from_href(href: str) -> str:
    parts = [p for p in urlparse(href).path.split("/") if p and p != "."]
    return parts[0]


def parse_releases(catalog: dict) -> dict:
    latest = catalog["latest"]
    releases = sorted(
        [
            _release_id_from_href(link["href"])
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
    try:
        conn.sql(build_views_sql(latest, s3_base))
    finally:
        conn.close()


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
