# Database setup — existing PostgreSQL

Folder ini menggunakan konfigurasi PostgreSQL utama yang sudah ada (`POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`). Tidak membuat database/container PostgreSQL kedua.

## Setup
1. Gabungkan folder dan file project ini ke repository tim tanpa menimpa `.env` atau konfigurasi bersama yang sudah ada.
2. Pastikan `.env` lokal sudah berisi variabel `POSTGRES_*`. Jangan commit `.env`.
3. Nyalakan database menggunakan Compose milik project utama:
   ```bash
   docker compose up -d postgres
   ```
4. Install dependensi Python di virtual environment:
   ```bash
   python -m pip install -r requirements.txt
   ```
5. Jalankan skrip CORE lalu MART secara manual terhadap database yang sudah berjalan:
   ```bash
   python scripts/apply_sql.py sql/ddl/postgres2/001_core.sql
   python scripts/apply_sql.py sql/ddl/postgres2/002_mart_views.sql
   ```

## Catatan penting
- Skrip pada `sql/ddl/postgres2/` berada di subfolder. Mount `./sql/ddl:/docker-entrypoint-initdb.d` pada Compose tidak otomatis menjalankan skrip di subfolder tersebut; jalankan perintah manual di atas.
- Skrip init Docker hanya otomatis dijalankan ketika volume data PostgreSQL masih kosong. Untuk database yang sudah berisi data, gunakan skrip manual dan pastikan dulu tidak ada objek dengan nama sama.
- Jalankan `001_core.sql` sebelum `002_mart_views.sql`.
- Konfigurasi Superset metadata tetap terpisah; skrip ini hanya memakai `POSTGRES_*` untuk database publikasi.

## Verifikasi
```sql
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema IN ('core', 'mart')
ORDER BY table_schema, table_name;
```
Ekspektasi dari skrip ini: sembilan tabel `core` dan lima view `mart`.
