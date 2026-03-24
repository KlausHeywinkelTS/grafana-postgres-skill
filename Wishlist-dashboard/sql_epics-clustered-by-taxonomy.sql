-- ============================================================
-- Datei:       sql_epics-clustered-by-taxonomy.sql
-- Ziel:        Prozentuale Verteilung aller Epics auf die Cluster-Level
--              von customfield_10698 (Taxonomie), projektübergreifend.
--              Basis-Wert = Teil vor dem ersten "-" (btrim + split_part).
--              Cluster-Mapping:
--                Revenue & Growth       ← Reach & Acquisition
--                                          Engagement & Conversion
--                                          Loyalty & Retention
--                Trust & Risk           ← Trust & Risk
--                Operational Excellence ← Operational Excellence
--                Platform & Ecosystem   ← Platform & Ecosystem
-- Panel-Typ:   Pie Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter
-- Basis-SQL:   –
-- Erstellt:    2026-03-24
-- ============================================================

SELECT
  cluster                                               AS "Taxonomie",
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)  AS "Anteil %"
FROM (
  SELECT
    CASE btrim(split_part(custom_fields->'customfield_10698'->>'value', '-', 1))
      WHEN 'Reach & Acquisition'     THEN 'Revenue & Growth'
      WHEN 'Engagement & Conversion' THEN 'Revenue & Growth'
      WHEN 'Loyalty & Retention'     THEN 'Revenue & Growth'
      WHEN 'Trust & Risk'            THEN 'Trust & Risk'
      WHEN 'Operational Excellence'  THEN 'Operational Excellence'
      WHEN 'Platform & Ecosystem'    THEN 'Platform & Ecosystem'
    END AS cluster
  FROM jira_issues
  WHERE issue_type = 'Epic'
    AND custom_fields->'customfield_10698'->>'value' IS NOT NULL
    AND custom_fields->'customfield_10698'->>'value' <> ''
    AND $__timeFilter(created_at)
) sub
WHERE cluster IS NOT NULL
GROUP BY cluster
ORDER BY "Anteil %" DESC
