package p2p

import (
	"context"
	"fmt"
	"time"

	"github.com/libp2p/go-libp2p-core/host"
	"github.com/libp2p/go-libp2p-core/network"
	"github.com/libp2p/go-libp2p-core/peer"
	dht "github.com/libp2p/go-libp2p-kad-dht"
)

var discoverNow = make(chan bool)

// Discover starts up a DHT based discovery system finding and adding nodes with the same rendezvous string.
func Discover(ctx context.Context, h host.Host, dht *dht.IpfsDHT, peerTable map[string]peer.ID) {
	dur := time.Second * 1
	ticker := time.NewTicker(dur)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-discoverNow:
			dur = time.Second * 1
			// Immediately trigger discovery
			ticker.Reset(time.Millisecond * 1)
		case <-ticker.C:
			connectedToAny := false
			for nd, id := range peerTable {
				if h.Network().Connectedness(id) != network.Connected {
					addrs, err := dht.FindPeer(ctx, id)
					if err != nil {
						continue
					}
					conn, err := h.Network().DialPeer(ctx, addrs.ID)
					if err != nil {
						continue
					}
					fmt.Printf("[+] Connected to %s at %s\n", nd, conn.RemoteMultiaddr())
					connectedToAny = true
				} else {
					connectedToAny = true
				}
			}
			if !connectedToAny {
				fmt.Println("[!] Not connected to any peers, attempting to bootstrap again")
				Rebootstrap()
				dur = time.Second * 1
				ticker.Reset(dur)
			} else {
				dur = dur * 2
				if dur >= time.Second*60 {
					dur = time.Second * 60
				}
				ticker.Reset(dur)
			}
		}
	}
}

func Rediscover() {
	discoverNow <- true
}
