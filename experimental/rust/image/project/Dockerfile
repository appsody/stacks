FROM rust:1.39 as builder

# Install musl
RUN apt-get update && apt-get install -y musl-tools
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR "/project/user-app"

# copy dependency files 
COPY /user-app/Cargo.toml Cargo.toml

# get user application dependencies
RUN cargo fetch 

#copy user code
COPY /user-app/src ./src

# build for release
RUN cargo build --release --target x86_64-unknown-linux-musl \
 && cp $(find ./target/x86_64-unknown-linux-musl/release -maxdepth 1 -perm -111 -type f| head -n 1) ./target/app \
 && chmod 755 ./target/app

FROM scratch

WORKDIR "/project/user-app"

# get files and built binary from previous image
COPY --from=builder /project/user-app/target/app ./

ENV PORT 8000

EXPOSE 8000

CMD ["./app"]