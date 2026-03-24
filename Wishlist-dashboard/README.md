# Dashboard: Wishlist-dashboard

## Zweck

Visualisiert Metriken aus dem sogenannten Jira wishlist-Projekt. In die Wishlist fließen Kunden-Featurewünsche ein, die uns auf verschiedenen Kanälen erreichen (Teams-Channel 'Customer-Voice-Uncensored', Retention Survey, Control-Centre survey).)

## Zielgruppe

- Product Management

## Datenquellen

- jira_issues
- jira_issue_changelog

## Dashboard-Variablen (Grafana)
<!-- Variablen, die im Dashboard global verfügbar sind und in SQLs verwendet werden sollen.
     Format:
       - ${var_name}: Beschreibung, mögliche Werte / Query
     Beispiel:
       - ${project}: Projekt-Filter, Werte aus jira_issues.project_key
       - ${issue_type}: Issue-Typ-Filter, z.B. Story / Bug / Task           -->
<!-- TODO: ausfüllen oder "keine" -->
- `$__timeFilter`: Standard-Grafana-Zeitfilter;

## Zeitraum

Über den __timeFilter

## Panels

<!-- Pro Panel einen Abschnitt. Der Skill liest diese Liste und generiert daraus Prompt-Grundgerüste. -->
<!-- Mindestangaben pro Panel: Name, Typ, Beschreibung. Rest ist optional aber hilfreich. -->

### Panel: Issues per Month

- **Typ**: Time Series
- **Beschreibung**: Anzahl neu erstellter Issues im Projekt WISH pro Monat. Beantwortet: „Wie viele Issues wurden pro Monat angelegt?"
- **Metriken / Spalten**: `month` (Monat), `issue_count` (Anzahl Issues)
- **Filter**: `project_key = 'WISH'` (hartkodiert)
- **Aggregation**: COUNT pro Monat (`date_trunc('month', created_at)`)
- **Hinweise**: none

### Panel: Issues by Status

- **Typ**: Bar Chart
- **Beschreibung**: Anzahl der Issues im Projekt WISH gruppiert nach Status. Beantwortet: „Wie viele Issues befinden sich im gewählten Zeitraum in welchem Status?"
- **Metriken / Spalten**: `status` (Jira-Status), `issue_count` (Anzahl Issues)
- **Filter**: `project_key = 'WISH'` (hartkodiert)
- **Aggregation**: COUNT pro Status-Kategorie
- **Hinweise**: CTE `all_statuses` stellt sicher, dass alle Status-Werte erscheinen (auch bei 0 Issues); `$__timeFilter` liegt im LEFT JOIN ON-Clause

### Panel: Issues by Label

- **Typ**: Bar Chart
- **Beschreibung**: Anzahl der Issues im Projekt WISH gruppiert nach Label. Beantwortet: „Welche Labels werden im gewählten Zeitraum am häufigsten verwendet?"
- **Metriken / Spalten**: `label` (Jira-Label), `issue_count` (Anzahl Issues)
- **Filter**: `project_key = 'WISH'` (hartkodiert), Issues ohne Label ausgeschlossen
- **Aggregation**: COUNT pro Label (ein Issue kann mehrfach zählen, wenn es mehrere Labels hat)
- **Hinweise**: Labels werden per `CROSS JOIN LATERAL unnest` aus dem PostgreSQL-Array-String expandiert; Sortierung nach Häufigkeit absteigend

### Panel: Epics clustered by taxonomy

- **Typ**: Pie-Chart
- **Beschreibung**: Prozentuale Verteilung aller Epics auf die Cluster-Level von customfield_10698. Basis-Wert = Teil vor dem ersten „-"; gemappt auf Revenue & Growth, Trust & Risk, Operational Excellence, Platform & Ecosystem.
- **Metriken / Spalten**: Cluster-Name → "Taxonomie", prozentualer Anteil → "Anteil %"
- **Filter**: Epics aller Projekte mit befülltem customfield_10698 und bekanntem Basis-Wert
- **Aggregation**: % per Cluster
- **Hinweis**: berücksichtigt `$__timeFilter`

## Offene Fragen / TODOs
<!-- Ungeklärte Punkte zum Dashboard, die noch besprochen werden müssen -->
<!-- TODO: ausfüllen oder entfernen -->
