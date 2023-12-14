#!/bin/bash

DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

export FUNC_RT="${1:-spin}"
export FUNC_LANG="${2:-js}"
export OUT_DIR="${3:-$DIR}"

VUS="${4:-100}"
DURATION="${5:-30s}"
SCRIPT="$DIR/${6:-smoke-json.js}"

LOCAL_PORT=8080
POD_PORT=80

# clean up the background port forward process on exit
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

echo "starting port forward to service $FUNC_RT-$FUNC_LANG"
kubectl port-forward "svc/$FUNC_RT-$FUNC_LANG" $LOCAL_PORT:$POD_PORT > /dev/null 2>&1 &

echo "waiting for port forward to be ready"
timeout 5 sh -c 'until nc -z $0 $1; do sleep 1; done' '127.0.0.1' $LOCAL_PORT

FUNC_URL='http://127.0.0.1:8080/json' k6 run --vus $VUS --duration $DURATION $SCRIPT
