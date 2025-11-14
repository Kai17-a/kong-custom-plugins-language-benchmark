local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "lua-plugin"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    {
      config = {
        type = "record",
        fields = {
          {
            valkey_host = {
              type = "string",
              required = true,
              default = "172.27.70.77",
            }
          },
          {
            valkey_port = {
              type = "integer",
              required = true,
              default = 6379,
            }
          },
        },
      },
    },
  },
}

return schema
