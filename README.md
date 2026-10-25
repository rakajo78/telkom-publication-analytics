# Telkom Publication Analytics — CORE & MART

Repository untuk bagian **Application Analytics / CORE / MART** milik Jonatan, mengikuti dokumen `Pertemuan_2_Update.docx`.

## Isi
- `sql/ddl/postgres2/001_core.sql`: membuat schema `core` dan sembilan tabel bisnis beserta constraint/index.
- `sql/ddl/postgres2/002_mart_views.sql`: membuat lima view analitik di schema `mart`.
- `scripts/apply_sql.py`: menjalankan file SQL dengan koneksi PostgreSQL dari environment.
- `compose.yml`: database PostgreSQL utama yang sudah ada lokal untuk pengembangan.
- `docs/`: panduan setup dan aturan model data.
- `tests/`: pemeriksaan dasar untuk keberadaan file dan objek SQL.

## Persyaratan
- macOS Apple Silicon (M1) atau komputer lain yang mendukung Docker Desktop.
- Docker Desktop (opsional, untuk database lokal dengan Compose).
- Python 3.10+ dan `psql` atau paket Python `psycopg[binary]`.

## Jalankan database lokal
1. Salin `.env.example` menjadi `.env`, lalu sesuaikan password.
2. Jalankan `docker compose up -d`.
3. Install dependensi: `python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`.
4. Terapkan schema CORE lalu view MART:
   ```bash
   python scripts/apply_sql.py sql/ddl/postgres2/001_core.sql
   python scripts/apply_sql.py sql/ddl/postgres2/002_mart_views.sql
   ```
5. Periksa schema/tabel/view dengan pgAdmin atau `psql`.

> Kedua skrip SQL menargetkan **database PostgreSQL utama yang sudah ada**. Jangan jalankan skrip ini ke database PostgreSQL 1 milik RAW/STAGING.
> SQL diambil dari dokumen rancangan tim. Jalankan di database pengembangan terlebih dahulu dan verifikasi sebelum digunakan di environment bersama/produksi.

## GitHub
Buat repository bernama `telkom-publication-analytics`, ekstrak folder ini, lalu dari terminal di dalam folder:
```bash
git init
git add .
git commit -m "Initial CORE and MART structure"
git branch -M main
git remote add origin https://github.com/USERNAME/telkom-publication-analytics.git
git push -u origin main
```
Ganti `USERNAME` dengan username GitHub kamu. Pastikan `.env` tidak pernah di-commit.


## Integrasi dengan konfigurasi database tim
Project ini menggunakan `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, dan `POSTGRES_PASSWORD` dari `.env` yang sudah ada. Tidak perlu membuat database atau container kedua. Lihat `docs/runbooks/database-setup.md` untuk urutan menjalankan skrip CORE dan MART.
