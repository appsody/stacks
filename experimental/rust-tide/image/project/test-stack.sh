#!/bin/bash

cargo build --manifest-path ../server/bin/Cargo.toml
cargo run --manifest-path ../server/bin/Cargo.toml & 

until $(curl --output /dev/null --silent --head --fail http://127.0.0.1:8000); do 
    printf '.'; 
    sleep 0.2; 
done

cargo test --manifest-path ../server/bin/Cargo.toml -p rust-tide-default
kill -9 $(pidof rust-tide-server)