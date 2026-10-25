-- TARGET: PostgreSQL 2 (MART)
-- Run after sql_postgres2_core.sql. These are views, not duplicated storage tables.
-- Historical metric snapshots are reduced to the latest record per object and source.
BEGIN;
CREATE SCHEMA IF NOT EXISTS mart;
CREATE OR REPLACE VIEW mart.publication_summary AS
SELECT
    p.publication_id,
    p.title,
    p.publication_date,
    COALESCE(p.publication_year,
             EXTRACT(YEAR FROM p.publication_date)::SMALLINT) AS publication_year,
    p.category,
    v.venue_name,
    v.venue_type,
    v.publisher,
    COUNT(pa.author_id)::INTEGER AS author_count,
    STRING_AGG(a.name, ', ' ORDER BY pa.author_order)
        FILTER (WHERE a.author_id IS NOT NULL) AS author_names
FROM core.publications AS p
LEFT JOIN core.publication_venues AS v ON v.venue_id = p.venue_id
LEFT JOIN core.publication_authors AS pa ON pa.publication_id = p.publication_id
LEFT JOIN core.authors AS a ON a.author_id = pa.author_id
GROUP BY p.publication_id, p.title, p.publication_date, p.publication_year,
         p.category, v.venue_name, v.venue_type, v.publisher;
-- One row per author-publication relation, suitable for lecturer/publication analysis.
CREATE OR REPLACE VIEW mart.lecturer_publication AS
SELECT
    a.author_id,
    a.name AS author_name,
    a.sinta_id,
    a.scholar_id,
    a.scopus_id,
    f.faculty_name,
    sp.program_name,
    p.publication_id,
    p.title AS publication_title,
    COALESCE(p.publication_year,
             EXTRACT(YEAR FROM p.publication_date)::SMALLINT) AS publication_year,
    p.publication_date,
    v.venue_name,
    v.venue_type,
    pa.author_order,
    pa.is_corresponding_author
FROM core.publication_authors AS pa
JOIN core.authors AS a ON a.author_id = pa.author_id
JOIN core.publications AS p ON p.publication_id = pa.publication_id
LEFT JOIN core.study_programs AS sp ON sp.study_program_id = a.study_program_id
LEFT JOIN core.faculties AS f ON f.faculty_id = sp.faculty_id
LEFT JOIN core.publication_venues AS v ON v.venue_id = p.venue_id;
-- Publications by year and category. Records without a known year are excluded.
CREATE OR REPLACE VIEW mart.publication_by_year AS
SELECT
    COALESCE(p.publication_year,
             EXTRACT(YEAR FROM p.publication_date)::SMALLINT) AS publication_year,
    COALESCE(p.category, 'Uncategorized') AS category,
    COUNT(*)::BIGINT AS publication_count
FROM core.publications AS p
WHERE p.publication_year IS NOT NULL OR p.publication_date IS NOT NULL
GROUP BY COALESCE(p.publication_year,
                  EXTRACT(YEAR FROM p.publication_date)::SMALLINT),
         COALESCE(p.category, 'Uncategorized');
-- Latest known citation count per publication/source, aggregated by source and year.
-- This view is source-based, not an assertion that different sources share one index definition.
CREATE OR REPLACE VIEW mart.publication_by_index AS
WITH latest_metrics AS (
    SELECT DISTINCT ON (pm.publication_id, pm.source_id)
        pm.publication_id, pm.source_id, pm.citation_count,
        pm.source_score, pm.retrieved_at
    FROM core.publication_metrics AS pm
    ORDER BY pm.publication_id, pm.source_id,
             pm.retrieved_at DESC, pm.publication_metric_id DESC
)
SELECT
    ms.source_name,
    COALESCE(p.publication_year,
             EXTRACT(YEAR FROM p.publication_date)::SMALLINT) AS publication_year,
    COUNT(*) FILTER (WHERE lm.citation_count IS NOT NULL)::BIGINT
        AS publications_with_citation_data,
    SUM(lm.citation_count)::NUMERIC AS citation_count_sum,
    MAX(lm.retrieved_at) AS latest_retrieval_at
FROM latest_metrics AS lm
JOIN core.metric_sources AS ms ON ms.source_id = lm.source_id
JOIN core.publications AS p ON p.publication_id = lm.publication_id
GROUP BY ms.source_name,
         COALESCE(p.publication_year,
                  EXTRACT(YEAR FROM p.publication_date)::SMALLINT);
-- High-level citation summary, counting only the latest observation per publication/source.
CREATE OR REPLACE VIEW mart.citation_summary AS
WITH latest_metrics AS (
    SELECT DISTINCT ON (pm.publication_id, pm.source_id)
        pm.publication_id, pm.source_id, pm.citation_count,
        pm.retrieved_at, pm.publication_metric_id
    FROM core.publication_metrics AS pm
    ORDER BY pm.publication_id, pm.source_id,
             pm.retrieved_at DESC, pm.publication_metric_id DESC
)
SELECT
    ms.source_name,
    COUNT(*) FILTER (WHERE lm.citation_count IS NOT NULL)::BIGINT
        AS publications_with_citation_data,
    COALESCE(SUM(lm.citation_count), 0)::NUMERIC AS total_citations,
    AVG(lm.citation_count)::NUMERIC(14,2) AS average_citations,
    MAX(lm.citation_count) AS maximum_citations,
    MAX(lm.retrieved_at) AS latest_retrieval_at
FROM latest_metrics AS lm
JOIN core.metric_sources AS ms ON ms.source_id = lm.source_id
GROUP BY ms.source_name;
COMMIT;
