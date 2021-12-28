FROM rust:1.45.0-buster
# This file is used to publish the server as a base image.
# docker build -t docker.io/number9/rust-tide-base:v1.0.0 .
# docker push docker.io/number9/rust-tide-base:v1.0.0 .

WORKDIR "/project/server/bin"

COPY image/project/server/bin/Cargo.toml ./

WORKDIR "/project/server/bin/src"

COPY image/project/server/bin/src ./

# Create prebuild to warm compilation process

RUN mkdir -p /project/user-app

WORKDIR "/project/user-app"

COPY templates/default/Cargo.toml ./

WORKDIR "/project/user-app/src"

COPY templates/default/src ./

# RUN ls

# RUN cat Cargo.toml

WORKDIR "/project/server/bin"

RUN cargo build

RUN rm -fr /project/user-app
