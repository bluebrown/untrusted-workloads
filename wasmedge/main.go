package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

func main() {
	b, err := os.ReadFile("test.txt")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("user (env):", os.Getenv("USER"))
	fmt.Println("data (dir):", strings.TrimSpace(string(b)))
	fmt.Println("args (cli):", strings.Join(os.Args[1:], " "))
}
