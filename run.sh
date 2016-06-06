#!/bin/sh

port=$1
if [ -z $port ]; then
    port=8000
fi

open http://localhost:$port/ && python3 -m http.server $port
