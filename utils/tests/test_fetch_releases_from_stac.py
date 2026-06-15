import json
import sys
import os
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from fetch_releases_from_stac import (
    VIEWS,
    build_views_sql,
    create_duckdb_views,
    fetch_catalog,
    parse_releases,
)

SAMPLE_CATALOG = {
    "type": "Catalog",
    "id": "Overture Releases",
    "stac_version": "1.1.0",
    "description": "All Overture Releases",
    "links": [
        {"rel": "root", "href": "./catalog.json", "type": "application/json"},
        {
            "rel": "child",
            "href": "./2026-05-20.0/catalog.json",
            "type": "application/json",
            "latest": True,
        },
        {
            "rel": "child",
            "href": "./2026-04-15.0/catalog.json",
            "type": "application/json",
        },
    ],
    "latest": "2026-05-20.0",
}


class TestFetchCatalog:
    def test_returns_parsed_json(self):
        mock_response = MagicMock()
        mock_response.__enter__ = lambda s: s
        mock_response.__exit__ = MagicMock(return_value=False)
        mock_response.read.return_value = json.dumps(SAMPLE_CATALOG).encode()

        with patch("urllib.request.urlopen", return_value=mock_response):
            result = fetch_catalog("https://stac.overturemaps.org/catalog.json")

        assert result == SAMPLE_CATALOG

    def test_uses_provided_url(self):
        mock_response = MagicMock()
        mock_response.__enter__ = lambda s: s
        mock_response.__exit__ = MagicMock(return_value=False)
        mock_response.read.return_value = json.dumps(SAMPLE_CATALOG).encode()

        with patch("urllib.request.urlopen", return_value=mock_response) as mock_open:
            fetch_catalog("https://custom.example.com/catalog.json")
            req = mock_open.call_args[0][0]
            assert req.full_url == "https://custom.example.com/catalog.json"

    def test_applies_timeout(self):
        mock_response = MagicMock()
        mock_response.__enter__ = lambda s: s
        mock_response.__exit__ = MagicMock(return_value=False)
        mock_response.read.return_value = json.dumps(SAMPLE_CATALOG).encode()

        with patch("urllib.request.urlopen", return_value=mock_response) as mock_open:
            fetch_catalog("https://stac.overturemaps.org/catalog.json", timeout=10)
            assert mock_open.call_args[1]["timeout"] == 10


class TestParseReleases:
    def test_extracts_latest(self):
        result = parse_releases(SAMPLE_CATALOG)
        assert result["latest"] == "2026-05-20.0"

    def test_extracts_child_releases(self):
        result = parse_releases(SAMPLE_CATALOG)
        assert "2026-05-20.0" in result["releases"]
        assert "2026-04-15.0" in result["releases"]

    def test_excludes_root_link(self):
        result = parse_releases(SAMPLE_CATALOG)
        # root link href is "./catalog.json" — split("/")[1] would be "catalog.json"
        # but more importantly rel="root" should be excluded
        assert "catalog.json" not in result["releases"]
        assert len(result["releases"]) == 2

    def test_releases_sorted_descending(self):
        result = parse_releases(SAMPLE_CATALOG)
        assert result["releases"] == sorted(result["releases"], reverse=True)

    def test_returns_dict_with_expected_keys(self):
        result = parse_releases(SAMPLE_CATALOG)
        assert set(result.keys()) == {"latest", "releases"}

    def test_empty_links(self):
        catalog = {**SAMPLE_CATALOG, "links": [], "latest": "2026-05-20.0"}
        result = parse_releases(catalog)
        assert result["latest"] == "2026-05-20.0"
        assert result["releases"] == []

    def test_single_release(self):
        catalog = {
            **SAMPLE_CATALOG,
            "links": [
                {"rel": "child", "href": "./2026-05-20.0/catalog.json"},
            ],
            "latest": "2026-05-20.0",
        }
        result = parse_releases(catalog)
        assert result["releases"] == ["2026-05-20.0"]

    def test_absolute_href_parsed_correctly(self):
        catalog = {
            **SAMPLE_CATALOG,
            "links": [
                {
                    "rel": "child",
                    "href": "https://stac.overturemaps.org/2026-05-20.0/catalog.json",
                },
            ],
            "latest": "2026-05-20.0",
        }
        result = parse_releases(catalog)
        assert result["releases"] == ["2026-05-20.0"]

    def test_relative_href_without_dotslash_parsed_correctly(self):
        catalog = {
            **SAMPLE_CATALOG,
            "links": [
                {"rel": "child", "href": "2026-05-20.0/catalog.json"},
            ],
            "latest": "2026-05-20.0",
        }
        result = parse_releases(catalog)
        assert result["releases"] == ["2026-05-20.0"]


    def test_contains_install_spatial(self):
        sql = build_views_sql("2026-05-20.0")
        assert "INSTALL spatial" in sql

    def test_contains_load_spatial(self):
        sql = build_views_sql("2026-05-20.0")
        assert "LOAD spatial" in sql

    def test_all_views_present(self):
        sql = build_views_sql("2026-05-20.0")
        for view_name, _, _ in VIEWS:
            assert f"CREATE OR REPLACE VIEW {view_name}" in sql

    def test_latest_release_in_paths(self):
        release = "2026-05-20.0"
        sql = build_views_sql(release)
        assert release in sql

    def test_custom_s3_base(self):
        sql = build_views_sql("2026-05-20.0", s3_base="s3://my-bucket/release")
        assert "s3://my-bucket/release" in sql

    def test_correct_theme_type_mapping(self):
        sql = build_views_sql("2026-05-20.0")
        assert "theme=addresses/type=address" in sql
        assert "theme=buildings/type=building_part" in sql
        assert "theme=transportation/type=segment" in sql
        assert "theme=divisions/type=division_boundary" in sql

    def test_view_count_matches_views_constant(self):
        sql = build_views_sql("2026-05-20.0")
        count = sql.count("CREATE OR REPLACE VIEW")
        assert count == len(VIEWS)


class TestCreateDuckdbViews:
    def test_creates_all_views(self):
        mock_conn = MagicMock()
        with patch("duckdb.connect", return_value=mock_conn):
            create_duckdb_views(":memory:", "2026-05-20.0")
            mock_conn.sql.assert_called_once()
            sql_arg = mock_conn.sql.call_args[0][0]
            for view_name, _, _ in VIEWS:
                assert f"CREATE OR REPLACE VIEW {view_name}" in sql_arg

    def test_views_reference_correct_release(self):
        release = "2026-05-20.0"
        mock_conn = MagicMock()
        with patch("duckdb.connect", return_value=mock_conn):
            create_duckdb_views(":memory:", release)
            sql_arg = mock_conn.sql.call_args[0][0]
            assert release in sql_arg

    def test_closes_connection(self):
        mock_conn = MagicMock()
        with patch("duckdb.connect", return_value=mock_conn):
            create_duckdb_views(":memory:", "2026-05-20.0")
            mock_conn.close.assert_called_once()

