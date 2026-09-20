#!/bin/bash
# usage: COOLIFY_TOKEN=… deploy-seis.sh <coolify-host> <app-uuid> <commit-prefix> [max-polls]
# Polls the application's deployment list until the deployment for <commit-prefix>
# is finished/failed/cancelled, then prints the app status. Never echoes the token.
H="Authorization: Bearer $COOLIFY_TOKEN"; HOST=$1; U=$2; C=$3; N=${4:-40}
for i in $(seq 1 "$N"); do
  S=$(curl -s -H "$H" "https://$HOST/api/v1/deployments/applications/$U" | python3 -c "
import sys,json; d=json.load(sys.stdin); xs=[x for x in d['deployments'] if (x.get('commit') or '').startswith('$C')]
print(xs[0]['status'] if xs else 'puudub')")
  echo "$(date -u +%H:%M:%S) $C $S"
  case "$S" in finished|failed|cancelled) break;; esac
  sleep 20
done
curl -s -H "$H" "https://$HOST/api/v1/applications/$U" | python3 -c "import sys,json; print('app', json.load(sys.stdin).get('status'))"
