FROM kong/kong-gateway:3.12.0.1

USER root

# カスタムプラグイン用言語インストール
# Node.js インストール
RUN apt-get update && apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node -v \
    && npm -v \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Python インストール
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository universe \
    && apt-get update \
    && apt-get install -y python3 python3-pip \
    && python3 --version \
    && pip3 --version \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# カスタムプラグイン設定
ENV KONG_PLUGINS=bundled,lua-plugin,go-plugin,py-plugin,js-plugin
ENV KONG_PLUGINSERVER_NAMES=go-plugin,py-plugin,js-plugin

# Lua プラグイン
COPY ./plugins/lua /usr/local/share/lua/5.1/kong/plugins/lua-plugin

# Go プラグイン
COPY ./plugins/go/go-plugin /usr/local/bin/go-plugin
ENV KONG_PLUGINSERVER_GO_PLUGIN_SOCKET=/usr/local/kong/go-plugin.socket
ENV KONG_PLUGINSERVER_GO_PLUGIN_START_CMD=/usr/local/bin/go-plugin
ENV KONG_PLUGINSERVER_GO_PLUGIN_QUERY_CMD="/usr/local/bin/go-plugin -dump"

# Pythonプラグイン
COPY ./plugins/py/py-plugin.py /path/to/py-plugin.py
RUN chmod +x /path/to/py-plugin.py
RUN pip3 install kong-pdk valkey-glide valkey-glide-sync --break-system-packages
ENV KONG_PLUGINSERVER_PY_PLUGIN_SOCKET=/usr/local/kong/py-plugin.sock
ENV KONG_PLUGINSERVER_PY_PLUGIN_START_CMD="/usr/local/bin/kong-python-pluginserver --plugins-directory /path/to --socket-name py-plugin.sock"
ENV KONG_PLUGINSERVER_PY_PLUGIN_QUERY_CMD="/usr/local/bin/kong-python-pluginserver --plugins-directory /path/to --dump-all-plugins"

# JS プラグイン
RUN npm install -g kong-pdk @valkey/valkey-glide
COPY ./plugins/js /usr/local/kong/js-plugin
RUN chmod +x /usr/local/kong/js-plugin/js-plugin.js
ENV KONG_PLUGINSERVER_JS_PLUGIN_SOCKET=/usr/local/kong/js-pluginserver.sock
ENV KONG_PLUGINSERVER_JS_PLUGIN_START_CMD="/usr/bin/kong-js-pluginserver --plugins-directory /usr/local/kong/js-plugin --sock-name js-pluginserver.sock"
ENV KONG_PLUGINSERVER_JS_PLUGIN_QUERY_CMD="/usr/bin/kong-js-pluginserver --plugins-directory /usr/local/kong/js-plugin --dump-all-plugins"

USER kong

# Run kong
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 8000 8443 8001 8444
STOPSIGNAL SIGQUIT
HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health
CMD ["kong", "docker-start"]