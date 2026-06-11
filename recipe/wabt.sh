#!/usr/bin/env sh
set -eu

: "${PREFIX:=.local}"

cd /tmp

if ! test -d wabt; then
  git clone --recursive https://github.com/WebAssembly/wabt
fi

cd wabt
git submodule update --init

mkdir -p build
cd build
cmake ..
cmake --build .

cd -
mkdir -p "$PREFIX/bin"
cp /tmp/wabt/bin/* "$PREFIX/bin"
