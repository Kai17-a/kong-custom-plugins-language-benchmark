"use strict";

const redis = require("redis");

class KongPlugin {
  constructor(config) {
    this.config = config;
  }

  async access(kong) {
    try {
      const valkeyHost = this.config.valkeyHost || "172.27.70.77";
      const valkeyPort = this.config.valkeyPort || 6379;

      const client = redis.createClient({
        url: `redis://${valkeyHost}:${valkeyPort}`,
      });

      client.on("error", async (err) => {
        return await kong.response.exit("Valkey Client Error:", err);
      });

      await client.connect();

      // let current = await client.get("js-plugin");

      // if (!current) {
      //   current = 0;
      // }

      new_value = await client.incr("js-plugin");
      if (!new_value) {
        await kong.response.exit("Valkey INCR failed");
      }

      // await kong.response.setHeader("X-Visited-Count", current.toString());
    } catch (error) {
      await kong.response.exit("exception error", err);
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
