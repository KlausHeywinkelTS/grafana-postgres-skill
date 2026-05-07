-- ============================================================
-- Datei:       sql_issues-by-taxonomy-raw.sql
-- Ziel:        Anzahl der Issues im Projekt WISH gruppiert nach dem rohen Wert
--              von customfield_10698 – ohne Splitting, Gruppierung oder CASE.
--              Nützlich zur Diagnose der tatsächlich gespeicherten Feldwerte.
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter(created_at), ${source:pipe}
-- Basis-SQL:   –
-- Erstellt:    2026-05-07
-- ============================================================

SELECT
  (ji.custom_fields->'customfield_10698'->>'value') AS customfield_10698_value,
  COUNT(*) AS issue_count
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
GROUP BY 1
ORDER BY issue_count DESC, customfield_10698_value;
