#!/usr/bin/env python3
\"\"\"Apply a SQL file to PostgreSQL 2 using PG2_DSN or PG2_* variables.\"\"\"
import os
import sys
from pathlib import Path

from dotenv import load_dotenv
import psycopg


def make_dsn() -> str:
    load_dotenv()
    # Optional override for local setups; do not commit secrets in this value.
    dsn = os.getenv("POSTGRES_DSN")
    if dsn:
        return dsn
    required = ["POSTGRES_HOST", "POSTGRES_PORT", "POSTGRES_DB", "POSTGRES_USER", "POSTGRES_PASSWORD"]
    missing = [key for key in required if not os.getenv(key)]
    if missing:
        raise SystemExit(
            "Missing environment variables: " + ", ".join(missing)
            + ". Copy .env.example to .env and configure it."
        )
    # Keyword DSN avoids URI-escaping issues for passwords containing characters like @.
    return (
        f"host={os.environ['POSTGRES_HOST']} port={os.environ['POSTGRES_PORT']} "
        f"dbname={os.environ['POSTGRES_DB']} user={os.environ['POSTGRES_USER']} "
        f"password={os.environ['POSTGRES_PASSWORD']}"
    )


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python scripts/apply_sql.py path/to/script.sql")
    sql_path = Path(sys.argv[1])
    if not sql_path.is_file() or sql_path.suffix.lower() != ".sql":
        raise SystemExit(f"SQL file not found or not .sql: {sql_path}")
    sql = sql_path.read_text(encoding="utf-8")
    with psycopg.connect(make_dsn(), autocommit=True) as conn:
        conn.execute(sql)
    print(f"Applied SQL successfully: {sql_path}")


if __name__ == "__main__":
    main()
