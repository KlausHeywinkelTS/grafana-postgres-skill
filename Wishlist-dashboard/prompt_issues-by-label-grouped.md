# Ziel
Zeigt die Anzahl der Issues im Projekt WISH gruppiert nach Label – mit Zusammenfassung
mehrerer review-bezogener Labels unter dem Sammelbegriff „Reviews".
Beantwortet die Frage: „Welche Produktbereiche haben die meisten Issues?"

# Panel-Typ
Bar Chart

# Tabellen
- jira_issues

# Zeit-Spalte
ji.created_at

# Ausgabe-Spalten
label        → "label"
COUNT(*)     → "issue_count"

# Aggregation
COUNT pro Label-Gruppe

# Filter / Bedingungen
- project_key = 'WISH' (hartkodiert)
- COALESCE(ji.labels, '') <> '' (leere Labels ausschließen)
- lbl NOT IN ('Enhancement', 'New', 'Removal') (technische/generische Labels ausschließen)

# Grafana-Variablen
- $__timeFilter(ji.created_at)

# Referenz
Wie sql_issues-by-label.sql – aber mit folgenden Änderungen:
- CASE-Ausdruck im SELECT und GROUP BY: folgende Labels werden zu 'Reviews' zusammengefasst:
  ReviewManagement, Widgets, ProductReviews, Invite, Questionnaire, Analytics,
  SRA, ServiceReviews, ReputationManager, Invites, SentimentAnalyse
- btrim() auf lbl angewendet (Leerzeichen-Bereinigung)

# Hinweise
- Labels sind als PostgreSQL-Array-String gespeichert (Format: `{label1,label2}`); die `{}` werden per `trim(both '{}' from ...)` entfernt, dann per `string_to_array(..., ',')` aufgespalten
- CROSS JOIN LATERAL unnest expandiert mehrere Labels einer Issue in separate Zeilen
- btrim() entfernt führende/nachfolgende Leerzeichen aus einzelnen Labels (wichtig bei Parsing aus dem Array-String)
- Der CASE-Ausdruck muss identisch in SELECT und GROUP BY stehen (kein Alias im GROUP BY möglich)
- Sortierung: issue_count DESC, dann label alphabetisch
