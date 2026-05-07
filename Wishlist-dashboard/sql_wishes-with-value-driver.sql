-- ============================================================
-- Datei:       sql_wishes-with-value-driver.sql
-- Ziel:        Anzahl WISH-Issues im Filterzeitraum und per source-Filter,
--              die im Feld „Value Driver" (customfield_10698) einen Wert haben
-- Panel-Typ:   Stat
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter(created_at), ${source:pipe}
-- Basis-SQL:   sql_issues-by-taxonomy.sql
-- Erstellt:    2026-05-07
-- ============================================================

SELECT
  COUNT(*) AS "Wishes mit Value Driver"
FROM jira_issues ji
WHERE ji.project_key = 'WISH'
  AND $__timeFilter(ji.created_at)
  AND (ji.custom_fields->'customfield_10698') IS NOT NULL
  AND (ji.custom_fields->'customfield_10698') <> 'null'::jsonb
  AND (
    ji.description ~* '${source:pipe}'
    OR (
      '${source:pipe}' ~* 'Customer Voice Uncensored'
      AND ji.description ILIKE '%teams message%'
    )
  )
