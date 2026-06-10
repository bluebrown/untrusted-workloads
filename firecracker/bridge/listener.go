package main

import (
	"fmt"
	"log"
	"net"
	"os"
)

const (
	info     = 4
	mtu      = 4096
	sockfile = ".local/v.sock_52"
)

func main() {
	os.Remove(sockfile)
	ln, err := net.Listen("unix", sockfile)
	if err != nil {
		log.Fatal(err)
	}
	defer ln.Close()

	conn, err := ln.Accept()
	if err != nil {
		log.Fatal(err)
	}

	defer conn.Close()

	fmt.Printf("conn addr: %s\n", conn.RemoteAddr())
	b := make([]byte, info+mtu)

	for {
		_, err := conn.Read(b)
		if err != nil {
			log.Fatal(err)
		}

		fmt.Printf("  dst: %s src: %s\n", smac(b[4:10]), smac(b[10:16]))
	}
}

func smac(buf []byte) string {
	return fmt.Sprintf("%02x:%02x:%02x:%02x:%02x:%02x",
		buf[0], buf[1], buf[2], buf[3], buf[4], buf[5])
}
