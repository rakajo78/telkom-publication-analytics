-- TARGET: PostgreSQL 2 (CORE + MART)
-- Run this script on the PostgreSQL instance/database for trusted business data.
-- The nine business tables below are in the core schema.
BEGIN;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS mart;
CREATE TABLE IF NOT EXISTS core.faculties (
    faculty_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_name VARCHAR(150) NOT NULL UNIQUE,
    CONSTRAINT chk_faculty_name_nonempty CHECK (length(btrim(faculty_name)) > 0)
);
CREATE TABLE IF NOT EXISTS core.study_programs (
    study_program_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_id BIGINT NOT NULL,
    program_name VARCHAR(150) NOT NULL,
    CONSTRAINT uq_program_faculty UNIQUE (faculty_id, program_name),
    CONSTRAINT chk_program_name_nonempty CHECK (length(btrim(program_name)) > 0),
    CONSTRAINT fk_program_faculty FOREIGN KEY (faculty_id)
        REFERENCES core.faculties(faculty_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS ix_study_programs_faculty
    ON core.study_programs (faculty_id);
CREATE TABLE IF NOT EXISTS core.authors (
    author_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    sinta_id VARCHAR(50) UNIQUE,
    scholar_id VARCHAR(100) UNIQUE,
    scopus_id VARCHAR(50) UNIQUE,
    study_program_id BIGINT,
    CONSTRAINT chk_author_name_nonempty CHECK (length(btrim(name)) > 0),
    CONSTRAINT fk_author_study_program FOREIGN KEY (study_program_id)
        REFERENCES core.study_programs(study_program_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS ix_authors_study_program
    ON core.authors (study_program_id);
CREATE INDEX IF NOT EXISTS ix_authors_name
    ON core.authors (name);
CREATE TABLE IF NOT EXISTS core.publication_venues (
    venue_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venue_name VARCHAR(255) NOT NULL,
    venue_type VARCHAR(30) NOT NULL DEFAULT 'other'
        CHECK (venue_type IN ('journal', 'conference', 'book', 'repository', 'other')),
    publisher VARCHAR(200),
    issn VARCHAR(20),
    isbn VARCHAR(20),
    CONSTRAINT uq_venue_name_type UNIQUE (venue_name, venue_type),
    CONSTRAINT chk_venue_name_nonempty CHECK (length(btrim(venue_name)) > 0)
);
CREATE INDEX IF NOT EXISTS ix_venues_publisher
    ON core.publication_venues (publisher);
CREATE TABLE IF NOT EXISTS core.publications (
    publication_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title TEXT NOT NULL,
    publication_date DATE,
    -- Optional year-only value supports sources that do not provide an exact date.
    publication_year SMALLINT,
    venue_id BIGINT,
    volume VARCHAR(50),
    pages VARCHAR(50),
    description TEXT,
    category VARCHAR(80),
    doi VARCHAR(255) UNIQUE,
    CONSTRAINT chk_publication_title_nonempty CHECK (length(btrim(title)) > 0),
    CONSTRAINT chk_publication_year CHECK (
        publication_year IS NULL OR publication_year BETWEEN 1500 AND 2200
    ),
    CONSTRAINT chk_publication_year_matches_date CHECK (
        publication_date IS NULL OR publication_year IS NULL OR
        EXTRACT(YEAR FROM publication_date)::INTEGER = publication_year
    ),
    CONSTRAINT fk_publication_venue FOREIGN KEY (venue_id)
        REFERENCES core.publication_venues(venue_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS ix_publications_date
    ON core.publications (publication_date);
CREATE INDEX IF NOT EXISTS ix_publications_year
    ON core.publications (publication_year);
CREATE INDEX IF NOT EXISTS ix_publications_venue
    ON core.publications (venue_id);
CREATE TABLE IF NOT EXISTS core.publication_authors (
    publication_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,
    author_order SMALLINT NOT NULL CHECK (author_order >= 1),
    is_corresponding_author BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (publication_id, author_id),
    CONSTRAINT uq_publication_author_order UNIQUE (publication_id, author_order),
    CONSTRAINT fk_pa_publication FOREIGN KEY (publication_id)
        REFERENCES core.publications(publication_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_pa_author FOREIGN KEY (author_id)
        REFERENCES core.authors(author_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS ix_publication_authors_author
    ON core.publication_authors (author_id);
CREATE TABLE IF NOT EXISTS core.metric_sources (
    source_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_name VARCHAR(100) NOT NULL UNIQUE,
    source_url VARCHAR(255),
    CONSTRAINT chk_metric_source_name_nonempty CHECK (length(btrim(source_name)) > 0)
);
CREATE TABLE IF NOT EXISTS core.author_metrics (
    author_metric_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id BIGINT NOT NULL,
    source_id BIGINT NOT NULL,
    h_index INTEGER CHECK (h_index IS NULL OR h_index >= 0),
    source_score NUMERIC(12,4) CHECK (source_score IS NULL OR source_score >= 0),
    retrieved_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_author_metric_author FOREIGN KEY (author_id)
        REFERENCES core.authors(author_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_author_metric_source FOREIGN KEY (source_id)
        REFERENCES core.metric_sources(source_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS ix_author_metric_latest
    ON core.author_metrics (author_id, source_id, retrieved_at DESC);
CREATE TABLE IF NOT EXISTS core.publication_metrics (
    publication_metric_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    publication_id BIGINT NOT NULL,
    source_id BIGINT NOT NULL,
    citation_count BIGINT CHECK (citation_count IS NULL OR citation_count >= 0),
    source_score NUMERIC(12,4) CHECK (source_score IS NULL OR source_score >= 0),
    retrieved_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_publication_metric_publication FOREIGN KEY (publication_id)
        REFERENCES core.publications(publication_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_publication_metric_source FOREIGN KEY (source_id)
        REFERENCES core.metric_sources(source_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE INDEX IF NOT EXISTS ix_publication_metric_latest
    ON core.publication_metrics (publication_id, source_id, retrieved_at DESC);
CREATE INDEX IF NOT EXISTS ix_publication_metric_source_time
    ON core.publication_metrics (source_id, retrieved_at DESC);
COMMIT;
-- OPTIONAL INITIAL SOURCE LIST (edit to match sources actually used):
-- INSERT INTO core.metric_sources (source_name, source_url) VALUES
--   ('Google Scholar', 'https://scholar.google.com/'),
--   ('Scopus', 'https://www.scopus.com/'),
--   ('SINTA', 'https://sinta.kemdiktisaintek.go.id/')
-- ON CONFLICT (source_name) DO NOTHING;
