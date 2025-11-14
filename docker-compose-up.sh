#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# goコードをビルド
cd $SCRIPT_DIR/kong/plugins/go
go mod tidy
go build


# docker 起動
cd $SCRIPT_DIR
docker compose up --build $1