# Grafana PostgreSQL Macro-Referenz

## Zeit-Filter Macros

| Macro | Beispiel | Beschreibung |
|-------|----------|--------------|
| `$__timeFilter(col)` | `WHERE $__timeFilter(created_at)` | Filtert auf das Dashboard-Zeitfenster (empfohlen) |
| `$__timeFrom()` | `WHERE col >= $__timeFrom()` | Start des Zeitfensters |
| `$__timeTo()` | `WHERE col <= $__timeTo()` | Ende des Zeitfensters |
| `$__timeGroup(col, iv)` | `GROUP BY $__timeGroup(ts, $__interval)` | Gruppiert Zeit in Buckets |
| `$__timeGroupAlias(col, iv)` | Wie `$__timeGroup` + fügt `AS time` hinzu | Empfohlen für Time Series |
| `$__interval` | `$__timeGroup(col, $__interval)` | Aktuelles Dashboard-Intervall |
| `$__intervalMs` | Intervall in Millisekunden | Selten benötigt |
| `$__unixEpochFilter(col)` | Für UNIX-Timestamp-Spalten (INTEGER) | Filter auf unix epoch |
| `$__unixEpochGroup(col, iv)` | Für UNIX-Timestamp-Spalten (INTEGER) | Group auf unix epoch |

## Dashboard-Variablen

| Syntax | Beispiel | Wann verwenden |
|--------|----------|----------------|
| `'${var}'` | `WHERE device = '${device}'` | Einzelwert, Text |
| `${var:raw}` | `WHERE id IN (${ids:raw})` | Multi-Value, kein Quoting |
| `${var:sqlstring}` | `WHERE name = ${var:sqlstring}` | Einzelwert mit Quoting (sicher) |
| `${var:csv}` | Kommagetrennte Liste | Selten |

### Multi-Value-Variable (IN-Klausel)
```sql
-- Dashboard-Variable "devices" mit Multi-Select:
WHERE device_id IN (${devices:raw})
```

### Variable in LIKE
```sql
WHERE device_name ILIKE '%${search}%'
```

## Timezone-Behandlung

Grafana überträgt Zeitangaben in **UTC**. Falls die DB lokale Zeit speichert:

```sql
-- Spalte in UTC konvertieren:
WHERE $__timeFilter(timestamp AT TIME ZONE 'Europe/Berlin')

-- Oder bei der Ausgabe zurückkonvertieren:
SELECT
  (timestamp AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Berlin') AS time,
  value
FROM my_table
WHERE $__timeFilter(timestamp)
```

## Typische Muster

### Lückenfüllung (fill gaps) bei aggregierten Daten
Wenn Zeitbuckets ohne Daten trotzdem angezeigt werden sollen:
```sql
SELECT
  $__timeGroupAlias(timestamp_col, $__interval, 0),  -- 0 = Fill-Wert
  AVG(value) AS "Durchschnitt"
FROM my_table
WHERE $__timeFilter(timestamp_col)
GROUP BY 1
ORDER BY 1 ASC
```

### Mehrere Metriken als separate Spalten (für Time Series)
```sql
SELECT
  $__timeGroupAlias(timestamp_col, $__interval),
  AVG(temperature) AS "Temperatur",
  AVG(humidity)    AS "Luftfeuchtigkeit"
FROM sensor_data
WHERE $__timeFilter(timestamp_col)
  AND device_id = '${device}'
GROUP BY 1
ORDER BY 1 ASC
```

### Mehrere Metriken als Zeilen (für dynamische Legenden)
```sql
SELECT
  timestamp_col AS time,
  device_id     AS metric,
  value
FROM sensor_data
WHERE $__timeFilter(timestamp_col)
ORDER BY time ASC
```
> Grafana erstellt dann eine Serie pro `metric`-Wert.

## Performance-Hinweise

- `$__timeFilter` **immer** verwenden – verhindert Full Table Scans
- Index auf Timestamp-Spalte empfohlen: `CREATE INDEX ON table (timestamp_col DESC)`
- Bei Table-Panels immer `LIMIT` setzen (z.B. `LIMIT 1000`)
- Für hochfrequente Daten `$__timeGroupAlias` + Aggregation statt Rohdaten
- `SELECT *` vermeiden – nur benötigte Spalten abfragen
