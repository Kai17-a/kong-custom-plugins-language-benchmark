#!/usr/bin/env python3
from glide_sync import GlideClientConfiguration, NodeAddress, GlideClient
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

valkey_client = None

class Plugin(object):
    def __init__(self, config):
        self.config = config
        self.valkey_host = config.get("valkey_host", "172.27.70.77")
        self.valkey_port = config.get("valkey_port", 6379)

        if valkey_client is None:
            addresses = [NodeAddress(self.valkey_host, self.valkey_port)]
            config = GlideClientConfiguration(addresses, request_timeout=5000)
            self.client = GlideClient.create(config)

    def access(self, kong: kong.kong):
        try:
            self.client.incr("py-plugin")
        except Exception as e:
            msg = f"Valkey INCR failed: {e}"
            kong.log.err(msg)
            kong.response.exit(500, msg)


if __name__ == "__main__":
    from kong_pdk.cli import start_dedicated_server
    start_dedicated_server("py-plugin", Plugin, version, priority, Schema)
