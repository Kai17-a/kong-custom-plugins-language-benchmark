#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# goコードをビルド
cd $SCRIPT_DIR

docker compose down

echo y | docker volume prune