#!/usr/bin/env sh
export GOOS=wasip1
export GOARCH=wasm
exec go build -o wasmedge/main.wasm wasmedge/main.go
