#!/usr/bin/env bash
# Check Impala impalad memory usage across all nodes
IMPALAD_PORT="${IMPALAD_PORT:-25000}"
echo "=== Impala Memory Usage ==="
for host in ${IMPALA_HOSTS:-localhost}; do
    echo "--- $host ---"
    curl -s "http://${host}:${IMPALAD_PORT}/memz?json" 2>/dev/null |     python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    print(f'  In use     : {d.get(\"in_use\",0)//1024//1024} MB')
    print(f'  Peak usage : {d.get(\"peak\",0)//1024//1024} MB')
    print(f'  Limit      : {d.get(\"limit\",0)//1024//1024} MB')
except: print('  (could not parse response)')
" || echo "  Cannot connect to $host:$IMPALAD_PORT"
done
