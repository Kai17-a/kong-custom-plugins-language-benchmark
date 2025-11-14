local plugin = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}

function plugin:access(plugin_conf)
  local redis = require "resty.redis"
  local red = redis:new()

  red:set_timeout(1000)

  local ok, err = red:connect(plugin_conf.valkey_host, plugin_conf.valkey_port)
  if not ok then
    kong.log.err("failed to connect: ", err)
    return kong.response.exit(500, { message = "Valkey connection failed" })
  end
  
  local new_value, err = red:incr("lua-plugin")
  if not new_value then
    kong.log.err("Valkey INCR failed: ", err)
    return kong.response.exit(500, { message = "Valkey INCR failed" })
  end

  red:set_keepalive(10000, 100)

end

return plugin
