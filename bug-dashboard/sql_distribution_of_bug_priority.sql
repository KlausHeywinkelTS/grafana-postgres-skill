-- ============================================================
-- Datei:       sql_distribution_of_bug_priority.sql
-- Ziel:        Verteilung der offenen Bug-Issues nach Priorität anzeigen;
--              Anzahl Bugs je Prioritätsgruppe.
--              Offen = Status nicht Done/Closed/Rejected.
--              Gruppen: Showstopper, High (High/Major/High Standard),
--              Medium (Medium/Normal), Low (Low/Trivial/Minor), None;
--              übrige Werte unverändert.
-- Panel-Typ:   Bar Chart
-- Tabellen:    jira_issues
-- Variablen:   ${project:sqlstring}, $__timeFilter
-- Basis-SQL:   –
-- Erstellt:    2026-08-05
-- ============================================================

WITH filtered_bugs AS (
  SELECT
    i.created_at,
    regexp_replace(
      btrim(replace(COALESCE(i.priority, ''), E'\u00A0', ' ')),
      '[[:space:]]+',
      ' ',
      'g'
    ) AS priority_norm
  FROM jira_issues AS i
  WHERE i.issue_type = 'Bug'
    AND (
      i.status IS NULL
      OR i.status NOT IN ('Done', 'Closed', 'Rejected')
    )
    AND i.project_key IN (
      'INV', 'QUE', 'REVIN', 'RM', 'CC', 'LSRT', 'PL',
      'TBI', 'TPSCON', 'GUARANTEE', 'SEO', 'CA', 'TCM'
    )
    AND (
      'All' IN (${project:sqlstring})
      OR i.project_key IN (${project:sqlstring})
    )
),
grouped_bugs AS (
  SELECT
    created_at,
    CASE
      WHEN priority_norm ILIKE 'Show stopper'
        OR priority_norm ILIKE 'Showstopper'
        THEN 'Showstopper'
      WHEN priority_norm ILIKE 'High Standard'
        OR priority_norm ILIKE 'High'
        OR priority_norm ILIKE 'Major'
        THEN 'High'
      WHEN priority_norm ILIKE 'Medium'
        OR priority_norm ILIKE 'Normal'
        THEN 'Medium'
      WHEN priority_norm ILIKE 'Low'
        OR priority_norm ILIKE 'Trivial'
        OR priority_norm ILIKE 'Minor'
        THEN 'Low'
      WHEN priority_norm ILIKE 'None'
        OR priority_norm = ''
        THEN 'None'
      ELSE priority_norm
    END AS priority_group
  FROM filtered_bugs
)
SELECT
  b.priority_group AS "Priorität",
  COUNT(*) AS "Number of bugs"
FROM grouped_bugs AS b
WHERE $__timeFilter(b.created_at)
GROUP BY b.priority_group
ORDER BY
  CASE b.priority_group
    WHEN 'Showstopper' THEN 1
    WHEN 'High' THEN 2
    WHEN 'Medium' THEN 3
    WHEN 'Low' THEN 4
    WHEN 'None' THEN 5
    ELSE 6
  END,
  b.priority_group;
