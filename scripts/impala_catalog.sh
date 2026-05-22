#!/usr/bin/env bash
# Invalidate and refresh Impala catalog metadata
# Usage: ./impala_catalog.sh invalidate [db] [table]
#        ./impala_catalog.sh refresh mydb mytable
IMPALA_HOST="${IMPALA_HOST:-localhost}"
ACTION="${1:-invalidate}"; DB="${2:-}"; TABLE="${3:-}"

run_sql() { impala-shell -i "$IMPALA_HOST" -q "$1" 2>/dev/null; }

case "$ACTION" in
  invalidate)
    if [ -n "$TABLE" ]; then
        echo "Invalidating ${DB}.${TABLE}..."
        run_sql "INVALIDATE METADATA ${DB}.${TABLE};"
    else
        echo "Invalidating all metadata..."
        run_sql "INVALIDATE METADATA;"
    fi ;;
  refresh)
    echo "Refreshing ${DB}.${TABLE}..."
    run_sql "REFRESH ${DB}.${TABLE};" ;;
  *)
    echo "Usage: $0 [invalidate|refresh] [db] [table]" ;;
esac
echo "Done at $(date)"
