from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_core_sql_has_nine_business_tables():
    sql = (ROOT / "sql/ddl/postgres2/001_core.sql").read_text(encoding="utf-8")
    assert sql.count("CREATE TABLE IF NOT EXISTS core.") == 9


def test_mart_sql_has_five_views():
    sql = (ROOT / "sql/ddl/postgres2/002_mart_views.sql").read_text(encoding="utf-8")
    assert sql.count("CREATE OR REPLACE VIEW mart.") == 5
