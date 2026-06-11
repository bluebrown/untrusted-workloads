#!/usr/bin/env sh
set -eu

: "${PREFIX:=.local}"

mkdir -p "$PREFIX/share/model"
curl -LO https://huggingface.co/second-state/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q5_K_M.gguf
mv Llama-3.2-1B-Instruct-Q5_K_M.gguf .local/share/model/

mkdir -p "$PREFIX/bin"
curl -LO https://github.com/second-state/LlamaEdge/releases/latest/download/llama-chat.wasm
mv llama-chat.wasm .local/bin/
