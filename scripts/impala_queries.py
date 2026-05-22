#!/usr/bin/env python3
"""Monitor Impala queries via Impala Web UI API.
Usage: python3 impala_queries.py --host impala-daemon --state running
"""
import argparse, json, urllib.request, sys

def get_queries(host, port, state):
    url = f"http://{host}:{port}/queries?json"
    try:
        with urllib.request.urlopen(url, timeout=10) as r:
            data = json.loads(r.read())
    except Exception as e:
        print(f"Cannot connect to Impala {host}:{port} — {e}"); sys.exit(1)
    queries = data.get('in_flight_queries',[]) + data.get('completed_queries',[])
    if state != 'all':
        queries = [q for q in queries if q.get('state','').lower() == state]
    return queries

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--host', default='localhost')
    p.add_argument('--port', type=int, default=25000)
    p.add_argument('--state', default='running', choices=['running','finished','exception','all'])
    args = p.parse_args()
    queries = get_queries(args.host, args.port, args.state)
    print(f"\n=== Impala Queries [{args.state.upper()}] on {args.host} ===")
    print(f"  {'User':<15} {'DB':<15} {'Duration':<12} {'State':<12} {'SQL'}")
    print("-"*85)
    for q in queries[:30]:
        user = q.get('effective_user','?')[:14]
        db   = q.get('default_db','?')[:14]
        dur  = q.get('duration','?')[:11]
        st   = q.get('state','?')[:11]
        sql  = q.get('stmt','').replace('\n',' ')[:50]
        print(f"  {user:<15} {db:<15} {dur:<12} {st:<12} {sql}")
    print(f"\nTotal: {len(queries)}")

if __name__ == '__main__': main()
