#!/bin/sh
exec socat -v -u UNIX-LISTEN:./.local/v.sock_52,fork FILE:/dev/null
