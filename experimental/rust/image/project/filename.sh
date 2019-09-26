#!/bin/bash
bin_name=$(awk '$0 == "[[bin]]" {i=1;next};i && i++ <= 1' Cargo.toml)

echo "$bin_name" | sed -e 's/name = "\(.*\)"/\1/'