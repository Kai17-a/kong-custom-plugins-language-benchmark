package main

import (
	"context"
	"fmt"

	"github.com/Kong/go-pdk"
	"github.com/Kong/go-pdk/server"
	"github.com/redis/go-redis/v9"
)

func main() {
	server.StartServer(New, Version, Priority)
}

var Version = "0.2"
var Priority = 1
var ctx = context.Background()

type Config struct {
	ValkeyHost string
	ValkeyPort int
}

func New() interface{} {
	return &Config{
		ValkeyHost: "172.27.70.77",
		ValkeyPort: 6379,
	}
}

func (conf Config) Access(kong *pdk.PDK) {
	rdb := redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:%d", conf.ValkeyHost, conf.ValkeyPort),
		DB:   0,
	})

	_, err := rdb.Incr(ctx, "go-plugin").Result()
	if err != nil {
		kong.Log.Err("Valkey INCR failed: %s", err)
		kong.Response.Exit(500, []byte("Valkey INCR failed"), nil)
		return
	}
}
