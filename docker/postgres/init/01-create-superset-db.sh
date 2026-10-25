#!/bin/bash
set -e

psql \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  -v ON_ERROR_STOP=1 \
  -v superset_user="$SUPERSET_DB_USER" \
  -v superset_password="$SUPERSET_DB_PASSWORD" \
  -v superset_db="$SUPERSET_DB_NAME" <<'SQL'
CREATE USER :"superset_user" WITH PASSWORD :'superset_password';
CREATE DATABASE :"superset_db" OWNER :"superset_user";
SQL
