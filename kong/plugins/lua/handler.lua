local redis = require "resty.redis"

local plugin = {
  PRIORITY = 1000,
  VERSION = "0.1",
}

local function get_redis_connection(host, port)
  local red = redis:new()
  red:set_timeout(500)

  local ok, err = red:connect(host, port)
  if not ok then
    kong.log.err("failed to connect: ", err)
    return nil, err
  end

  return red
end

function plugin:access(plugin_conf)
  local red, err = get_redis_connection(plugin_conf.valkey_host, plugin_conf.valkey_port)
  if not red then
    return kong.response.exit(500, "Valkey connection failed")
  end

  local new_value, err = red:incr("lua-plugin")
  if not new_value then
    kong.log.err("Valkey INCR failed: ", err)
    return kong.response.exit(500, "Valkey INCR failed")
  end

  -- 接続をプールに戻す
  local ok, err = red:set_keepalive(10000, 100)
  if not ok then
    kong.log.err("failed to set keepalive: ", err)
  end
end

return plugin
