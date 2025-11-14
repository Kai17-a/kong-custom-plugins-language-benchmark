#!/usr/bin/env python3
import os
import redis
import kong_pdk.pdk.kong as kong

Schema = (
    {
        "valkey_host": {"type": "string"},
    },
    {
        "valkey_port": {"type": "integer"},
    },
)

version = "0.1.0"
priority = 0


class Plugin(object):
    def __init__(self, config):
        self.config = config
        self.valkey_host = "172.27.70.77"
        self.valkey_port = 6379

    def access(self, kong: kong.kong):
        try:
            r = redis.Redis(host=self.valkey_host, port=self.valkey_port, db=0)

            new_value = r.incr("py-plugin")
            if not new_value:
                kong.response.exit(500, "Valkey INCR failed")

        except Exception as e:
            kong.log.err(e)
            kong.response.exit(500, "")


if __name__ == "__main__":
    from kong_pdk.cli import start_dedicated_server

    start_dedicated_server("py-plugin", Plugin, version, priority, Schema)
