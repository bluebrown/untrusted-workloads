#!/usr/bin/env sh
exec wasmedge --env USER=john --dir /:./wasmedge/testdata wasmedge/main.wasm "$@"
