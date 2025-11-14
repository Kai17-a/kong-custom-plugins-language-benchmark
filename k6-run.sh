#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tests=("default" "lua" "go" "py" "js")

for test in "${tests[@]}"; do
    echo "== k6 run ${test}-test.js ========"

    k6 run $SCRIPT_DIR/k6/$test-test.js

    echo "========================"

    sleep 120
done