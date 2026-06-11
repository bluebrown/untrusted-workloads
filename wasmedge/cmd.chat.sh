#!/usr/bin/env sh

exec wasmedge --dir .:"$PWD/.local/share/model/" \
  --nn-preload default:GGML:AUTO:.local/share/model/Llama-3.2-1B-Instruct-Q5_K_M.gguf \
  .local/bin/llama-chat.wasm -p llama-3-chat
