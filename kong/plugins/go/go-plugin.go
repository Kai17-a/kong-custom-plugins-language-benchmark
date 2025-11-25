package main

import (
	"context"
	"fmt"
	"sync"

	"github.com/Kong/go-pdk"
	"github.com/Kong/go-pdk/server"
	glide "github.com/valkey-io/valkey-glide/go/v2"
	"github.com/valkey-io/valkey-glide/go/v2/config"
)

func main() {
	server.StartServer(New, Version, Priority)
}

var (
	Version  = "0.2"
	Priority = 1
	ctx      = context.Background()

	client   *glide.Client
	initOnce sync.Once
)

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

func initValkeyClient(conf Config, kong *pdk.PDK) {
	initOnce.Do(func() {
		cfg := config.NewClientConfiguration().
			WithAddress(&config.NodeAddress{Host: conf.ValkeyHost, Port: conf.ValkeyPort})

		var err error
		client, err = glide.NewClient(cfg)
		if err != nil {
			msg := fmt.Sprintf("Valkey client init failed: %v", err)
			kong.Log.Err(msg)
		}
	})
}

func (conf Config) Access(kong *pdk.PDK) {
	initValkeyClient(conf, kong)

	if client == nil {
		msg := "Valkey client not initialized"
		kong.Log.Err(msg)
		kong.Response.Exit(500, []byte(msg), nil)
		return
	}

	// ここからはグローバル client を使う
	_, err := client.Incr(ctx, "go-plugin")
	if err != nil {
		msg := fmt.Sprintf("Valkey INCR failed: %v", err)
		kong.Log.Err(msg)
		kong.Response.Exit(500, []byte(msg), nil)
		return
	}
}
