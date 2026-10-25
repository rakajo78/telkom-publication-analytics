# Data dictionary — CORE/MART

## CORE (9 tabel)
1. `core.faculties`
2. `core.study_programs`
3. `core.authors`
4. `core.publication_venues`
5. `core.publications`
6. `core.publication_authors`
7. `core.metric_sources`
8. `core.author_metrics`
9. `core.publication_metrics`

## MART (5 views)
- `mart.publication_summary`
- `mart.lecturer_publication`
- `mart.publication_by_year`
- `mart.publication_by_index`
- `mart.citation_summary`

CORE adalah model bisnis tepercaya; MART menyajikan bentuk siap analitik. View metrik publikasi memilih snapshot terbaru per publikasi dan sumber agar histori tidak dijumlahkan berulang.
