"use strict";

const valkey = require("@valkey/valkey-glide");
let valkeyClient;

class KongPlugin {
  constructor(config) {
    this.config = config;

    if (!valkeyClient) {
      valkeyClient = valkey.GlideClient.createClient({
        addresses: [
          {
            host: config.valkeyHost,
            port: config.valkeyPort,
          },
        ],
        requestTimeout: 5000,
        clientName: "test_standalone_client",
      });
    }
  }

  async access(kong) {
    try {
      await (await valkeyClient).incr("js-plugin").catch((err) => {
        throw err;
      });
    } catch (error) {
      const message = `Valkey INCR failed: ${error}`;
      await kong.log.err(message);
      await kong.response.exit(message);
    }
  }
}

module.exports = {
  Plugin: KongPlugin,
  Schema: [
    { valkeyHost: { type: "string", required: true, default: "172.27.70.77" } },
    { valkeyPort: { type: "number", required: true, default: 6379 } },
  ],
  Version: "0.1.0",
  Priority: 0,
};
