-- Phase D-2 Feedback Schema (Codex 推奨)
-- SQLite with WAL mode for concurrent read access from Streamlit UI + future MCP feedback writes.
--
-- Created at first run by kb_feedback_ui.py.
-- Path: $HOME/.kb/feedback.sqlite3

PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;

CREATE TABLE IF NOT EXISTS feedback (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  ts                TEXT    NOT NULL,                -- ISO 8601 UTC
  run_id            TEXT    NOT NULL,                -- UUID per search session
  query             TEXT    NOT NULL,                -- raw user query
  doc_id            TEXT    NOT NULL,                -- e.g. "agora#4#chunk_03"
  chunk_hash        TEXT,                            -- sha256 of doc text (for de-dup across re-embed)
  rank              INTEGER,                         -- 1-based position in result list
  distance          REAL,                            -- cosine distance from Chroma
  label             INTEGER NOT NULL,                -- 1=useful, 0=not_useful
  reason            TEXT,                            -- optional free-text note
  retriever_version TEXT,                            -- e.g. "phase_d_v1"
  embedding_model   TEXT                             -- e.g. "nomic-embed-text"
);

CREATE INDEX IF NOT EXISTS idx_feedback_query  ON feedback(query);
CREATE INDEX IF NOT EXISTS idx_feedback_doc    ON feedback(doc_id);
CREATE INDEX IF NOT EXISTS idx_feedback_ts     ON feedback(ts);
CREATE INDEX IF NOT EXISTS idx_feedback_label  ON feedback(label);

-- For pairwise re-ranker training export (Codex 推奨)
-- VIEW: 同一 query で label=1 (positive) と label=0 (negative) のペア
CREATE VIEW IF NOT EXISTS feedback_pairs AS
SELECT
  p.query                AS query,
  p.doc_id               AS positive_doc,
  n.doc_id               AS negative_doc,
  p.ts                   AS ts,
  p.embedding_model      AS embedding_model
FROM feedback p
JOIN feedback n
  ON p.query = n.query
 AND p.run_id = n.run_id
 AND p.label = 1
 AND n.label = 0
 AND p.doc_id <> n.doc_id;
