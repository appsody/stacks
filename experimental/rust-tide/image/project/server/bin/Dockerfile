FROM rust:1.44.0-buster
# This file is used to publish the server as a base image.
# docker build -t docker.io/number9/rust-tide-base:v1.0.0 .
# docker push docker.io/number9/rust-tide-base:v1.0.0 .

WORKDIR "/project/server/bin"

COPY Cargo.toml ./

WORKDIR "/project/server/bin/src"

COPY src ./
