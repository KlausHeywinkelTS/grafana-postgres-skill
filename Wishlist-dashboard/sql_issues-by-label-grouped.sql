-- ============================================================
-- Datei:       sql_issues-by-label-grouped.sql
-- Ziel:        Anzahl der Issues im Projekt WISH gruppiert nach Label,
--              mit Zusammenfassung review-bezogener Labels unter "Reviews"
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   $__timeFilter, ${source} (Multi-Value, description-Filter)
-- Basis-SQL:   sql_issues-by-label.sql
-- Erstellt:    2026-04-23
-- Änderungen:  - CASE-Gruppierung: ReviewManagement, Widgets, ProductReviews,
--                Invite, Questionnaire, Analytics, SRA, ServiceReviews,
--                ReputationManager, Invites, SentimentAnalyse → 'Reviews'
--              - btrim() auf lbl für saubere Label-Werte
-- ============================================================

SELECT
  CASE
    WHEN btrim(lbl) IN (
      'ReviewManagement',
      'Widgets',
      'ProductReviews',
      'Invite',
      'Questionnaire',
      'Analytics',
      'SRA',
      'ServiceReviews',
      'ReputationManager',
      'Invites',
      'SentimentAnalyse'
    )
    THEN 'Reviews'
    ELSE btrim(lbl)
  END AS label,
  COUNT(*) AS issue_count
FROM jira_issues ji
CROSS JOIN LATERAL unnest(
  string_to_array(
    trim(both '{}' from COALESCE(ji.labels, '')),
    ','
  )
) AS lbl
WHERE
  $__timeFilter(ji.created_at)
  AND ji.project_key = 'WISH'
  AND COALESCE(ji.labels, '') <> ''
  AND lbl NOT IN ('Enhancement', 'New', 'Removal')
  AND (
    ji.description ~* '${source:pipe}'
    OR (
      '${source:pipe}' ~* 'Customer Voice Uncensored'
      AND ji.description ILIKE '%teams message%'
    )
  )
GROUP BY
  CASE
    WHEN btrim(lbl) IN (
      'ReviewManagement',
      'Widgets',
      'ProductReviews',
      'Invite',
      'Questionnaire',
      'Analytics',
      'SRA',
      'ServiceReviews',
      'ReputationManager',
      'Invites',
      'SentimentAnalyse'
    )
    THEN 'Reviews'
    ELSE btrim(lbl)
  END
ORDER BY
  issue_count DESC,
  label;
