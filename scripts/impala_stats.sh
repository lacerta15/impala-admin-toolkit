#!/usr/bin/env bash
# Compute Impala table statistics
DB="${1:?Usage: $0 db [table]}"; TABLE="${2:-}"
IMPALA_HOST="${IMPALA_HOST:-localhost}"
if [ -n "$TABLE" ]; then
    echo "Computing stats for ${DB}.${TABLE}..."
    impala-shell -i "$IMPALA_HOST" -d "$DB" -q "COMPUTE STATS ${TABLE}; SHOW TABLE STATS ${TABLE};"
else
    echo "Computing stats for all tables in ${DB}..."
    impala-shell -i "$IMPALA_HOST" -d "$DB" -q "SHOW TABLES;" 2>/dev/null | grep -v "^$\|^#\|rows" | while read tbl; do
        echo "  Processing: $tbl"
        impala-shell -i "$IMPALA_HOST" -d "$DB" -q "COMPUTE STATS ${tbl};" 2>/dev/null
    done
fi
echo "Stats complete at $(date)"
