# Ziel

Prozentuale Verteilung aller Epics (projektübergreifend) auf die Cluster-Level des Custom-Fields `customfield_10698` (Taxonomie). Der Basis-Wert wird per `btrim(split_part(..., '-', 1))` aus dem Feld extrahiert und auf folgende Cluster gemappt:
- **Revenue & Growth** ← Reach & Acquisition, Engagement & Conversion, Loyalty & Retention
- **Trust & Risk** ← Trust & Risk
- **Operational Excellence** ← Operational Excellence
- **Platform & Ecosystem** ← Platform & Ecosystem

Epics ohne befülltes `customfield_10698` oder mit unbekanntem Basis-Wert werden ausgeschlossen.

## Panel-Typ

Pie Chart

## Tabellen

jira_issues

## Zeit-Spalte

created_at

## Ausgabe-Spalten

Cluster-Name → "Taxonomie"
Prozentualer Anteil des Clusters (bezogen auf alle gemappten Epics) → "Anteil %"
Kein absoluter Count in der Ausgabe.

## Aggregation

COUNT pro Wert in `customfield_10698`, dann prozentualer Anteil berechnen

# Filter / Bedingungen

- `issue_type = 'Epic'` (alle Projekte)
- `customfield_10698` ist nicht leer / NULL
- `$__timeFilter` auf `created_at`

## Grafana-Variablen

- `$__timeFilter` (Standard-Zeitfilter)

## Referenz

–

## Hinweise

- Zugriff auf den Wert: `custom_fields->'customfield_10698'->>'value'`
- Sortierung nach Anteil absteigend
- `customfield_10698` ist noch nicht in der bekannten Custom-Field-Liste in `resources/table_jira_issues.md` dokumentiert – echter Feldname und Strukturtyp müssen ggf. aus der DB geprüft werden
