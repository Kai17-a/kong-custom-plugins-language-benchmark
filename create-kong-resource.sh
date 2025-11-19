#!/bin/bash

# 利用言語
pg_langs=("lua" "go" "py" "js")

# サービス作成
service_id=$(http POST localhost:8001/default/services -- name=test host=host.docker.internal port:=8888 name=kong-test | jq -r '.id')

# ルート作成
echo "== create route ========"
for lang in "" "${pg_langs[@]}"; do
    if [ -z "$lang" ]; then
        route_name="default-route"
        route_path="/api"
    else
        route_name="${lang}-route"
        route_path="/api/${lang}"
    fi

    status=$(http --print=h POST localhost:8001/default/routes \
        -- name=$route_name \
        paths:="[\"$route_path\"]" \
        methods:='["GET"]' \
        service:="{\"id\":\"$service_id\"}" | head -n 1 | awk '{print $2}')

    if [ "$status" != "201" ]; then
        echo "${lang}: failed to connect route: ${status}"
    else
        echo "${lang}: success in create route"
    fi
done
echo "========================"
echo ""

# プラグイン設定
echo "== set up plugin ========"
for lang in "${pg_langs[@]}"; do
    status=$(http --print=h POST "http://localhost:8001/default/routes/${lang}-route/plugins" -- name="${lang}-plugin" | head -n 1 | awk '{print $2}')
    if [ "$status" != "201" ]; then
        echo "${lang}: failed to connect route: ${status}"
    else
        echo "${lang}: success in set up a plugin"
    fi
done
echo "========================"
echo ""

# レスポンス返却時と実際に作成されるまで時差があるので待機
sleep 5

# 接続テスト
echo "== test route =========="
for lang in "${pg_langs[@]}"; do
    status=$(http --print=h "http://localhost:8000/api/${lang}/anything" | head -n 1 | awk '{print $2}')
    if [ "$status" != "200" ]; then
        echo "${lang}: failed to connect route: ${status}"
    else
        echo "${lang}: success in test"
    fi
done
echo "========================"
